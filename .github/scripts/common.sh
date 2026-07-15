#!/usr/bin/env bash

###############################################################################
# Common library
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/config.sh"

###############################################################################
# Console messages
###############################################################################

info() {
    echo
    echo "==> $*"
}

warn() {
    echo
    echo "WARNING: $*"
}

die() {
    echo
    echo "ERROR: $*"
    exit 1
}

###############################################################################
# File checks
###############################################################################

require_file() {

    local FILE="$1"

    [[ -f "$FILE" ]] || die "File not found: $FILE"

}

require_directory() {

    local DIR="$1"

    [[ -d "$DIR" ]] || die "Directory not found: $DIR"

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

ensure_directory() {

    mkdir -p "$1"

}

files_equal() {

    local FILE1="$1"
    local FILE2="$2"

    cmp -s "$FILE1" "$FILE2"

}

copy_if_exists() {

    local SRC="$1"
    local DST="$2"

    file_exists "$SRC" && cp "$SRC" "$DST"

}

move_file() {

    local SRC="$1"
    local DST="$2"

    mv "$SRC" "$DST"

}

###############################################################################
# RouterOS helpers
###############################################################################

ros_log() {

    echo ":log info \"$*\""

}

write_ros_header() {

    ros_log "${LOG_PREFIX}: ${SOURCE_NAME} build ${BUILD_TIME} (${COUNT} IPv4 prefixes)"
    ros_log "${LOG_PREFIX}: update started"

    echo
    echo "/ip firewall address-list"
    echo

}

write_ros_footer() {

    echo

    ros_log "${LOG_PREFIX}: update completed (${COUNT} IPv4 prefixes)"

}

###############################################################################
# JSON validation
###############################################################################

validate_json() {

    jq -e '.rules[0].ip_cidr' "$JSON_FILE" >/dev/null \
        || die "Invalid JSON structure."

}

###############################################################################
# TXT validation
###############################################################################

check_txt_prefix_count() {

    require_file "$NEW_TXT"

    COUNT="$(count_lines "$NEW_TXT")"

    info "IPv4 prefixes: ${COUNT}"

    if [[ "${COUNT}" -lt "${MIN_PREFIXES}" ]]
    then
        die "Too few IPv4 prefixes (${COUNT})."
    fi

}

###############################################################################
# IPv4 processing
###############################################################################

count_ipv4() {

    jq '
        [
            .rules[0].ip_cidr[]
            | select(test(":") | not)
        ]
        | length
    ' "$JSON_FILE"

}

check_prefix_count() {

    COUNT="$(count_ipv4)"

    info "IPv4 prefixes: ${COUNT}"

    if [[ "${COUNT}" -lt "${MIN_PREFIXES}" ]]
    then
        die "Too few IPv4 prefixes (${COUNT})."
    fi

}

generate_ipv4_txt() {

    jq -r '
        .rules[0].ip_cidr[]
        | select(test(":") | not)
    ' "$JSON_FILE" \
    | LC_ALL=C sort -u \
    > "$NEW_TXT"

}

###############################################################################
# Diff helpers
###############################################################################

generate_add_txt() {

    if [[ ! -f "$TXT_FILE" ]]
    then
        : > "$ADD_TXT"
        return
    fi

    comm -13 "$TXT_FILE" "$NEW_TXT" > "$ADD_TXT"

}

generate_del_txt() {

    if [[ ! -f "$TXT_FILE" ]]
    then
        : > "$DEL_TXT"
        return
    fi

    comm -23 "$TXT_FILE" "$NEW_TXT" > "$DEL_TXT"

}

###############################################################################
# Statistics
###############################################################################

count_lines() {

    local FILE="$1"

    if [[ -f "$FILE" ]]
    then
        wc -l < "$FILE"
    else
        echo 0
    fi

}

###############################################################################
# Temporary files
###############################################################################

cleanup() {

    rm -f "$ADD_TXT"
    rm -f "$DEL_TXT"

}

trap cleanup EXIT
