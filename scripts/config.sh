#!/usr/bin/env bash
#
# ============================================================
# GEOIP_RU Generator
# Configuration
# ============================================================

#
# Project directories
#

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

OUTPUT_DIR="${ROOT_DIR}/output"
TMP_DIR="${ROOT_DIR}/tmp"

#
# Source
#

SRS_URL="https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-ru.srs"

#
# Temporary files
#

SRS_FILE="${TMP_DIR}/geoip-ru.srs"
JSON_FILE="${TMP_DIR}/geoip-ru.json"

NEW_TXT="${OUTPUT_DIR}/geoip-ru_new.txt"

NEW_RSC="${OUTPUT_DIR}/geoip-ru_new.rsc"

NEW_ADD_TXT="${OUTPUT_DIR}/geoip-ru-add-new.txt"
NEW_DEL_TXT="${OUTPUT_DIR}/geoip-ru-del-new.txt"

NEW_ADD_RSC="${OUTPUT_DIR}/geoip-ru-add-new.rsc"
NEW_DEL_RSC="${OUTPUT_DIR}/geoip-ru-del-new.rsc"

#
# Production TXT
#

TXT_FILE="${OUTPUT_DIR}/geoip-ru.txt"

ADD_TXT="${OUTPUT_DIR}/geoip-ru-add.txt"
DEL_TXT="${OUTPUT_DIR}/geoip-ru-del.txt"

#
# Production RSC
#

RSC_FILE="${OUTPUT_DIR}/geoip-ru.rsc"

ADD_RSC="${OUTPUT_DIR}/geoip-ru-add.rsc"
DEL_RSC="${OUTPUT_DIR}/geoip-ru-del.rsc"

LOG_RSC="${OUTPUT_DIR}/geoip-ru-log.rsc"

#
# RouterOS
#

ADDRESS_LIST="GEOIP_RU"
COMMENT="GEOIP_RU_Auto"

#
# Validation
#

MIN_PREFIX_COUNT=5000

#
# Workflow state file
#

STATE_FILE="${TMP_DIR}/workflow.state"

#
# Update modes
#

MODE_FIRST="FIRST"
MODE_NO_CHANGES="NO_CHANGES"
MODE_UPDATED="UPDATED"
