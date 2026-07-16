#!/usr/bin/env bash
#
# ============================================================
# GEOIP_RU Generator
# Generate RouterOS RSC files
# ============================================================

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

info "=== Generate RouterOS RSC files ==="

ensure_directories

#
# ------------------------------------------------------------
# Required files
# ------------------------------------------------------------
#

require_file "${NEW_TXT}"
require_file "${NEW_ADD_TXT}"
require_file "${NEW_DEL_TXT}"

#
# ------------------------------------------------------------
# Generate full RSC
# ------------------------------------------------------------
#

info "Generating geoip-ru_new.rsc..."

generate_rsc \
    "${NEW_TXT}" \
    "${NEW_RSC}"

require_file "${NEW_RSC}"

#
# ------------------------------------------------------------
# Generate ADD RSC
# ------------------------------------------------------------
#

info "Generating geoip-ru-add-new.rsc..."

generate_rsc \
    "${NEW_ADD_TXT}" \
    "${NEW_ADD_RSC}"

require_file "${NEW_ADD_RSC}"

#
# ------------------------------------------------------------
# Generate DEL RSC
# ------------------------------------------------------------
#

info "Generating geoip-ru-del-new.rsc..."

generate_rsc \
    "${NEW_DEL_TXT}" \
    "${NEW_DEL_RSC}"

require_file "${NEW_DEL_RSC}"

info "RouterOS RSC generation completed successfully."
