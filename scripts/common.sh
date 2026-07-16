#!/usr/bin/env bash
#
# ============================================================
# GEOIP_RU Generator
# Common library
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

#
# ------------------------------------------------------------
# Logging
# ------------------------------------------------------------
#

info() {
    echo "[INFO] $*"
}

warning() {
    echo "[WARNING] $*" >&2
}

error_exit() {
    echo "[ERROR] $*" >&2
    exit 1
}

#
# ------------------------------------------------------------
# Directory management
# ------------------------------------------------------------
#

ensure_directories() {
    mkdir -p "${OUTPUT_DIR}"
    mkdir -p "${TMP_DIR}"
}

#
# ------------------------------------------------------------
# File management
# ------------------------------------------------------------
#

file_exists() {
    [[ -f "$1" ]]
}

require_file() {
    file_exists "$1" || error_exit "File not found: $1"
}

remove_file() {
    local file="$1"

    if [[ -f "$file" ]]; then
        rm -f "$file"
    fi

    return 0
}

#
# ------------------------------------------------------------
# Validation
# ------------------------------------------------------------
#

line_count() {
    local file="$1"

    require_file "$file"

    wc -l < "$file"
}

validate_prefix_count() {
    local file="$1"

    local count
    count=$(line_count "$file")

    if (( count < MIN_PREFIX_COUNT )); then
        error_exit "Too few IPv4 prefixes (${count} < ${MIN_PREFIX_COUNT})"
    fi

    info "IPv4 prefixes: ${count}"
}

#
# ------------------------------------------------------------
# TXT normalization
# ------------------------------------------------------------
#

normalize_txt() {
    local file="$1"

    require_file "$file"

    # CRLF -> LF
    sed -i 's/\r$//' "$file"

    # Remove empty lines
    sed -i '/^[[:space:]]*$/d' "$file"
}

#
# ------------------------------------------------------------
# Workflow state
# ------------------------------------------------------------
#

clear_state() {
    remove_file "${STATE_FILE}"
}

write_state() {

    local mode="$1"
    local add_count="$2"
    local del_count="$3"

    cat > "${STATE_FILE}" <<EOF
MODE="${mode}"
ADD_COUNT="${add_count}"
DEL_COUNT="${del_count}"
TIMESTAMP="$(date -u '+%Y-%m-%d %H:%M UTC')"
EOF

}

load_state() {

    require_file "${STATE_FILE}"

    # shellcheck disable=SC1090
    source "${STATE_FILE}"
}

#
# ------------------------------------------------------------
# RouterOS RSC generation
# ------------------------------------------------------------
#

generate_rsc() {

    local input_file="$1"
    local output_file="$2"

    require_file "${input_file}"

    {
        echo "/ip firewall address-list"

        while IFS= read -r prefix; do
            [[ -z "${prefix}" ]] && continue

            echo "add list=${ADDRESS_LIST} address=${prefix} comment=${COMMENT}"
        done < "${input_file}"

    } > "${output_file}"

}

#
# ------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------
#

cleanup_tmp() {
    clear_state
}
