#!/usr/bin/env bash
#
# ============================================================
# GEOIP_RU Generator
# Generate TXT
# ============================================================

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

info "=== Generate TXT ==="

ensure_directories

#
# ------------------------------------------------------------------
# Download SRS
# ------------------------------------------------------------------
#

info "Downloading geoip-ru.srs..."

wget -q -O "${SRS_FILE}" "${SRS_URL}"

require_file "${SRS_FILE}"

#
# ------------------------------------------------------------------
# Decompile
# ------------------------------------------------------------------
#

info "Decompiling rule-set..."

sing-box rule-set decompile \
    --output "${JSON_FILE}" \
    "${SRS_FILE}"

require_file "${JSON_FILE}"

#
# ------------------------------------------------------------------
# Extract IPv4 prefixes
# ------------------------------------------------------------------
#

info "Extracting IPv4 prefixes..."

python3 "${SCRIPT_DIR}/extract_ipv4.py" \
    "${JSON_FILE}" \
    "${NEW_TXT}"

require_file "${NEW_TXT}"

if [[ ! -s "${NEW_TXT}" ]]; then
    error_exit "Generated TXT file is empty."
fi

#
# ------------------------------------------------------------------
# Normalize
# ------------------------------------------------------------------
#

info "Normalizing..."

normalize_txt "${NEW_TXT}"

#
# ------------------------------------------------------------------
# Sort / Remove duplicates
# ------------------------------------------------------------------
#

sort -u "${NEW_TXT}" -o "${NEW_TXT}"

#
# ------------------------------------------------------------------
# Validation
# ------------------------------------------------------------------
#

validate_prefix_count "${NEW_TXT}"

info "TXT generation completed successfully."
