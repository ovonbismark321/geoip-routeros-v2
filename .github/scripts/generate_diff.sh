#!/usr/bin/env bash

###############################################################################
# Generate incremental RouterOS scripts
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

BUILD_TIME="$(timestamp)"

###############################################################################
# First run
###############################################################################

if ! file_exists "$TXT_FILE"
then

    info "First run detected."

    move_file "$CURRENT_TXT" "$TXT_FILE"

    rm -f "$ADD_RSC"
    rm -f "$DEL_RSC"

    info "Initial TXT created."

    exit 0

fi

###############################################################################
# Calculate differences
###############################################################################

generate_add_txt
generate_del_txt

ADD_COUNT="$(count_lines "$ADD_TXT")"
DEL_COUNT="$(count_lines "$DEL_TXT")"

info "ADD prefixes : ${ADD_COUNT}"
info "DEL prefixes : ${DEL_COUNT}"

###############################################################################
# Nothing changed
###############################################################################

if [[ "$ADD_COUNT" -eq 0 && "$DEL_COUNT" -eq 0 ]]
then

    info "No changes detected."

    rm -f "$ADD_RSC"
    rm -f "$DEL_RSC"

    move_file "$CURRENT_TXT" "$TXT_FILE"

    exit 0

fi

###############################################################################
# Generate ADD script
###############################################################################

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

###############################################################################
# Generate DEL script
###############################################################################

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

###############################################################################
# Publish new TXT
###############################################################################

move_file "$CURRENT_TXT" "$TXT_FILE"

###############################################################################
# Statistics
###############################################################################

info "Incremental scripts generated."

info "ADD : ${ADD_COUNT}"

info "DEL : ${DEL_COUNT}"
