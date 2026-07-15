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

require_file "$TXT_FILE"
require_file "$CURRENT_TXT"

###############################################################################
# Generate TXT differences
###############################################################################

generate_add_txt
generate_del_txt

validate_add_txt
validate_del_txt

ADD_COUNT="$(count_add)"
DEL_COUNT="$(count_del)"

###############################################################################
# Generate ADD script
###############################################################################

if [[ "$ADD_COUNT" -gt 0 ]]
then

    info "Generating ADD script (${ADD_COUNT} prefixes)"

    generate_add_rsc

    validate_add_rsc

else

    info "No added prefixes"

    safe_remove "$ADD_RSC"

fi

###############################################################################
# Generate DEL script
###############################################################################

if [[ "$DEL_COUNT" -gt 0 ]]
then

    info "Generating DEL script (${DEL_COUNT} prefixes)"

    generate_del_rsc

    validate_del_rsc

else

    info "No removed prefixes"

    safe_remove "$DEL_RSC"

fi

###############################################################################
# Replace current TXT
###############################################################################

move_file "$CURRENT_TXT" "$TXT_FILE"

###############################################################################
# Statistics
###############################################################################

print_statistics
