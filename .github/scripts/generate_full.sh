#!/usr/bin/env bash

###############################################################################
# Generate full RouterOS script
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/common.sh"

###############################################################################
# Checks
###############################################################################

require_file "$NEW_TXT"

mkdir -p "$OUTPUT_DIR"

COUNT="$(count_lines "$NEW_TXT")"

BUILD_TIME="$(timestamp)"

info "Generating ${FULL_RSC}"

###############################################################################
# Generate
###############################################################################

{

    write_ros_header

    echo "remove [find list=\"${ADDRESS_LIST_NAME}\" comment=\"${ADDRESS_COMMENT}\"]"
    echo

    while IFS= read -r PREFIX
    do

        [[ -z "$PREFIX" ]] && continue

        printf 'add list=%s address=%s comment="%s"\n' \
            "$ADDRESS_LIST_NAME" \
            "$PREFIX" \
            "$ADDRESS_COMMENT"

    done < "$NEW_TXT"

    write_ros_footer

} > "$FULL_RSC"

###############################################################################
# Statistics
###############################################################################

LINES="$(count_lines "$FULL_RSC")"

info "Generated ${FULL_RSC}"

info "IPv4 prefixes : ${COUNT}"

info "RouterOS lines: ${LINES}"
