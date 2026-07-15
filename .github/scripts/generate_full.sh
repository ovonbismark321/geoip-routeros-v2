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

require_file "$CURRENT_TXT"

ensure_directory "$OUTPUT_DIR"

COUNT="$(count_lines "$CURRENT_TXT")"

info "Generating full RouterOS script"

###############################################################################
# Generate
###############################################################################

{

    write_ros_header "$COUNT"

    echo "remove [find list=\"${ADDRESS_LIST_NAME}\" comment=\"${ADDRESS_COMMENT}\"]"

    echo

    while IFS= read -r PREFIX
    do

        [[ -z "$PREFIX" ]] && continue

        printf 'add list=%s address=%s comment="%s"\n' \
            "$ADDRESS_LIST_NAME" \
            "$PREFIX" \
            "$ADDRESS_COMMENT"

    done < "$CURRENT_TXT"

    write_ros_footer "$COUNT"

} > "$FULL_RSC"

###############################################################################
# Validation
###############################################################################

validate_full_rsc

###############################################################################
# Statistics
###############################################################################

info "Generated ${FULL_RSC}"

info "IPv4 prefixes : ${COUNT}"

print_sha256 "$FULL_RSC"
