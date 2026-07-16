#!/usr/bin/env bash
#
# ============================================================
# GEOIP_RU Generator
# Generate DIFF
# ============================================================

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

info "=== Generate DIFF ==="

ensure_directories

require_file "${NEW_TXT}"

#
# ------------------------------------------------------------
# First run
# ------------------------------------------------------------
#

if [[ ! -f "${TXT_FILE}" ]]; then

    info "First run detected."

    : > "${NEW_ADD_TXT}"
    : > "${NEW_DEL_TXT}"

    write_state "${MODE_FIRST}" 0 0

    info "DIFF generation completed successfully."

    exit 0

fi

#
# ------------------------------------------------------------
# Prepare files
# ------------------------------------------------------------
#

require_file "${TXT_FILE}"

info "Normalizing TXT files..."

normalize_txt "${TXT_FILE}"
normalize_txt "${NEW_TXT}"

sort -u "${TXT_FILE}" -o "${TXT_FILE}"
sort -u "${NEW_TXT}" -o "${NEW_TXT}"

#
# ------------------------------------------------------------
# Compare lists
# ------------------------------------------------------------
#

info "Comparing lists..."

comm -23 \
    "${NEW_TXT}" \
    "${TXT_FILE}" \
    > "${NEW_ADD_TXT}"

comm -13 \
    "${NEW_TXT}" \
    "${TXT_FILE}" \
    > "${NEW_DEL_TXT}"

#
# ------------------------------------------------------------
# Count changes
# ------------------------------------------------------------
#

ADD_COUNT=$(line_count "${NEW_ADD_TXT}")
DEL_COUNT=$(line_count "${NEW_DEL_TXT}")

info "Added prefixes   : ${ADD_COUNT}"
info "Deleted prefixes : ${DEL_COUNT}"

#
# ------------------------------------------------------------
# Save workflow state
# ------------------------------------------------------------
#

if (( ADD_COUNT == 0 && DEL_COUNT == 0 )); then

    write_state \
        "${MODE_NO_CHANGES}" \
        "${ADD_COUNT}" \
        "${DEL_COUNT}"

    info "No changes detected."

else

    write_state \
        "${MODE_UPDATED}" \
        "${ADD_COUNT}" \
        "${DEL_COUNT}"

    info "Changes detected."

fi

info "DIFF generation completed successfully."
