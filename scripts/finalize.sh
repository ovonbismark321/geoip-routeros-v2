#!/usr/bin/env bash
#
# ============================================================
# GEOIP_RU Generator
# Finalize update
# ============================================================

set -Eeuo pipefail
set -x

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

info "=== Finalize update ==="

ensure_directories

#
# ------------------------------------------------------------
# Load workflow state
# ------------------------------------------------------------
#

load_state

#
# ------------------------------------------------------------
# Verify generated files
# ------------------------------------------------------------
#

require_file "${NEW_TXT}"
require_file "${NEW_RSC}"

require_file "${NEW_ADD_TXT}"
require_file "${NEW_DEL_TXT}"

require_file "${NEW_ADD_RSC}"
require_file "${NEW_DEL_RSC}"

#
# ------------------------------------------------------------
# Generate RouterOS log script
# ------------------------------------------------------------
#

info "Generating geoip-ru-log.rsc..."

UTC_TIME="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"

{
    echo ":local msg"

    case "${MODE}" in

        FIRST)

            echo ":set msg \"${ADDRESS_LIST}: full list created (${UTC_TIME})\""
            ;;

        NO_CHANGES)

            echo ":set msg \"${ADDRESS_LIST}: no changes (${UTC_TIME})\""
            ;;

        UPDATED)

            echo ":set msg \"${ADDRESS_LIST}: +${ADD_COUNT} -${DEL_COUNT} (${UTC_TIME})\""
            ;;

        *)

            error_exit "Unknown workflow mode: ${MODE}"
            ;;

    esac

    echo ':log info $msg'

} > "${LOG_RSC}"

require_file "${LOG_RSC}"

#
# ------------------------------------------------------------
# Replace TXT files
# ------------------------------------------------------------
#

info "Replacing TXT files..."

remove_file "${TXT_FILE}"
remove_file "${ADD_TXT}"
remove_file "${DEL_TXT}"

mv -f "${NEW_TXT}" "${TXT_FILE}"
mv -f "${NEW_ADD_TXT}" "${ADD_TXT}"
mv -f "${NEW_DEL_TXT}" "${DEL_TXT}"

require_file "${TXT_FILE}"
require_file "${ADD_TXT}"
require_file "${DEL_TXT}"

#
# ------------------------------------------------------------
# Replace RSC files
# ------------------------------------------------------------
#

info "Replacing RSC files..."

remove_file "${RSC_FILE}"
remove_file "${ADD_RSC}"
remove_file "${DEL_RSC}"

mv -f "${NEW_RSC}" "${RSC_FILE}"
mv -f "${NEW_ADD_RSC}" "${ADD_RSC}"
mv -f "${NEW_DEL_RSC}" "${DEL_RSC}"

require_file "${RSC_FILE}"
require_file "${ADD_RSC}"
require_file "${DEL_RSC}"

#
# ------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------
#

cleanup_tmp

info "Finalize completed successfully."
