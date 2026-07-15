#!/usr/bin/env bash

###############################################################################
# GEOIP RouterOS Builder
# Common library
###############################################################################

set -euo pipefail

###############################################################################
# Load configuration
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/config.sh"

###############################################################################
# Logging
###############################################################################

timestamp() {

    date -u +"%Y-%m-%dT%H:%M:%SZ"

}

info() {

    echo "[INFO ] $(timestamp) $*"

}

warn() {

    echo "[WARN ] $(timestamp) $*" >&2

}

error() {

    echo "[ERROR] $(timestamp) $*" >&2

}

die() {

    error "$*"

    exit 1

}

###############################################################################
# File helpers
###############################################################################

file_exists() {

    [[ -f "$1" ]]

}

directory_exists() {

    [[ -d "$1" ]]

}

require_file() {

    file_exists "$1" || die "File not found: $1"

}

require_directory() {

    directory_exists "$1" || die "Directory not found: $1"

}

ensure_directory() {

    mkdir -p "$1"

}

safe_remove() {

    rm -f "$@"

}

move_file() {

    local SRC="$1"
    local DST="$2"

    mv "$SRC" "$DST"

}

copy_file() {

    local SRC="$1"
    local DST="$2"

    cp "$SRC" "$DST"

}

files_equal() {

    local FILE1="$1"
    local FILE2="$2"

    cmp -s "$FILE1" "$FILE2"

}

count_lines() {

    local FILE="$1"

    require_file "$FILE"

    wc -l < "$FILE"

}

###############################################################################
# Temporary directory
###############################################################################

clean_tmp() {

    require_directory "$TMP_DIR"

    info "Cleaning temporary directory"

    find "$TMP_DIR" \
        -mindepth 1 \
        ! -name ".gitkeep" \
        -delete

}

###############################################################################
# Validation
###############################################################################

validate_json() {

    require_file "$JSON_FILE"

    jq -e '.version' "$JSON_FILE" >/dev/null \
        || die "Invalid JSON."

}

check_txt_prefix_count() {

    require_file "$CURRENT_TXT"

    local COUNT

    COUNT="$(count_lines "$CURRENT_TXT")"

    info "IPv4 prefixes: ${COUNT}"

    if [[ "$COUNT" -lt "$MIN_PREFIXES" ]]
    then
        die "Too few IPv4 prefixes (${COUNT})"
    fi

}

###############################################################################
# RouterOS header/footer
###############################################################################

write_ros_header() {

    local COUNT="$1"

    local BUILD_TIME

    BUILD_TIME="$(timestamp)"

    cat <<EOF
:log info "${ADDRESS_LIST_NAME}: build ${BUILD_TIME} (${COUNT} IPv4 prefixes)"
:log info "${ADDRESS_LIST_NAME}: update started"

/ip firewall address-list

EOF

}

write_ros_footer() {

    local COUNT="$1"

    cat <<EOF

:log info "${ADDRESS_LIST_NAME}: update completed (${COUNT} IPv4 prefixes)"
EOF

}

###############################################################################
# IPv4 TXT generation
###############################################################################

generate_ipv4_txt() {

    require_file "$JSON_FILE"

    info "Generating IPv4 TXT"

    jq -r '
        .rules[]
        | select(.ip_cidr != null)
        | .ip_cidr[]
        | select(test(":") | not)
    ' "$JSON_FILE" \
    | sort -u > "$CURRENT_TXT"

    require_file "$CURRENT_TXT"

}

###############################################################################
# TXT validation
###############################################################################

validate_txt() {

    require_file "$CURRENT_TXT"

    info "Validating IPv4 TXT"

    if grep -q ':' "$CURRENT_TXT"
    then
        die "IPv6 prefixes found in IPv4 TXT."
    fi

    sort -c "$CURRENT_TXT" \
        || die "TXT file is not sorted."

}

###############################################################################
# Difference calculation
###############################################################################

generate_add_txt() {

    require_file "$TXT_FILE"

    require_file "$CURRENT_TXT"

    info "Calculating added prefixes"

    comm -13 \
        "$TXT_FILE" \
        "$CURRENT_TXT" \
        > "$ADD_TXT"

}

generate_del_txt() {

    require_file "$TXT_FILE"

    require_file "$CURRENT_TXT"

    info "Calculating removed prefixes"

    comm -23 \
        "$TXT_FILE" \
        "$CURRENT_TXT" \
        > "$DEL_TXT"

}

###############################################################################
# Difference statistics
###############################################################################

count_add() {

    if file_exists "$ADD_TXT"
    then
        count_lines "$ADD_TXT"
    else
        echo 0
    fi

}

count_del() {

    if file_exists "$DEL_TXT"
    then
        count_lines "$DEL_TXT"
    else
        echo 0
    fi

}

###############################################################################
# Output validation
###############################################################################

validate_add_txt() {

    require_file "$ADD_TXT"

    sort -c "$ADD_TXT" \
        || die "ADD TXT is not sorted."

}

validate_del_txt() {

    require_file "$DEL_TXT"

    sort -c "$DEL_TXT" \
        || die "DEL TXT is not sorted."

}

###############################################################################
# Statistics
###############################################################################

print_statistics() {

    local CURRENT_COUNT
    local ADD_COUNT
    local DEL_COUNT

    CURRENT_COUNT="$(count_lines "$CURRENT_TXT")"
    ADD_COUNT="$(count_add)"
    DEL_COUNT="$(count_del)"

    echo
    echo "=================================================="
    echo "Country      : ${COUNTRY^^}"
    echo "IPv4 prefixes: ${CURRENT_COUNT}"
    echo "Added        : ${ADD_COUNT}"
    echo "Removed      : ${DEL_COUNT}"
    echo "=================================================="
    echo

}

###############################################################################
# RouterOS generation
###############################################################################

generate_add_rsc() {

    {

        write_ros_header

        while IFS= read -r PREFIX
        do
            [[ -z "$PREFIX" ]] && continue

            printf 'add list=%s address=%s comment="%s"\n' \
                "$ADDRESS_LIST_NAME" \
                "$PREFIX" \
                "$ADDRESS_COMMENT"

        done < "$ADD_TXT"

        write_ros_footer

    } > "$ADD_RSC"

}

generate_del_rsc() {

    {

        write_ros_header

        while IFS= read -r PREFIX
        do
            [[ -z "$PREFIX" ]] && continue

            printf 'remove [find list="%s" address="%s" comment="%s"]\n' \
                "$ADDRESS_LIST_NAME" \
                "$PREFIX" \
                "$ADDRESS_COMMENT"

        done < "$DEL_TXT"

        write_ros_footer

    } > "$DEL_RSC"

}

###############################################################################
# Output validation
###############################################################################

validate_full_rsc() {

    require_file "$FULL_RSC"

    local COUNT
    local GENERATED

    COUNT="$(count_lines "$CURRENT_TXT")"

    GENERATED="$(grep -c '^add ' "$FULL_RSC")"

    [[ "$COUNT" -eq "$GENERATED" ]] \
        || die "FULL_RSC validation failed."

}

validate_add_rsc() {

    file_exists "$ADD_RSC" || return 0

    grep -q '^add ' "$ADD_RSC" \
        || warn "ADD script contains no add commands."

}

validate_del_rsc() {

    file_exists "$DEL_RSC" || return 0

    grep -q '^remove ' "$DEL_RSC" \
        || warn "DEL script contains no remove commands."

}

###############################################################################
# Checksums
###############################################################################

print_sha256() {

    local FILE="$1"

    require_file "$FILE"

    echo
    sha256sum "$FILE"
    echo

}

###############################################################################
# Finish
###############################################################################

finish() {

    clean_tmp

}

trap finish EXIT
