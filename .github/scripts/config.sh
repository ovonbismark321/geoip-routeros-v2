#!/usr/bin/env bash

###############################################################################
# GEOIP RouterOS Builder
# Global configuration
###############################################################################

###############################################################################
# Country
###############################################################################

# ISO 3166-1 alpha-2 country code
COUNTRY="ru"

###############################################################################
# Source
###############################################################################

SOURCE_NAME="SagerNet sing-geoip"

SRS_URL="https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set/geoip-${COUNTRY}.srs"

###############################################################################
# RouterOS
###############################################################################

ADDRESS_LIST_NAME="GEOIP_RU"

ADDRESS_COMMENT="${ADDRESS_LIST_NAME}_Auto"

###############################################################################
# sing-box
###############################################################################

SINGBOX_VERSION="1.12.0"

SINGBOX_ARCH="linux-amd64"

SINGBOX_DIR="sing-box-${SINGBOX_VERSION}-${SINGBOX_ARCH}"

SINGBOX_BINARY="./${SINGBOX_DIR}/sing-box"

SINGBOX_URL="https://github.com/SagerNet/sing-box/releases/download/v${SINGBOX_VERSION}/${SINGBOX_DIR}.tar.gz"

###############################################################################
# Directories
###############################################################################

ROOT_DIR="$(pwd)"

SCRIPT_DIR="${ROOT_DIR}/scripts"

OUTPUT_DIR="${ROOT_DIR}/output"

TMP_DIR="${ROOT_DIR}/tmp"

###############################################################################
# File name prefix
###############################################################################

SCRIPT_NAME_PREFIX="geoip-${COUNTRY}"

###############################################################################
# Temporary files
###############################################################################

SRS_FILE="${TMP_DIR}/${SCRIPT_NAME_PREFIX}.srs"

JSON_FILE="${TMP_DIR}/${SCRIPT_NAME_PREFIX}.json"

CURRENT_TXT="${TMP_DIR}/${SCRIPT_NAME_PREFIX}-ipv4.current"

ADD_TXT="${TMP_DIR}/${SCRIPT_NAME_PREFIX}-ipv4.add"

DEL_TXT="${TMP_DIR}/${SCRIPT_NAME_PREFIX}-ipv4.del"

###############################################################################
# Output files
###############################################################################

TXT_FILE="${OUTPUT_DIR}/${SCRIPT_NAME_PREFIX}-ipv4.txt"

FULL_RSC="${OUTPUT_DIR}/${SCRIPT_NAME_PREFIX}.rsc"

ADD_RSC="${OUTPUT_DIR}/${SCRIPT_NAME_PREFIX}-add.rsc"

DEL_RSC="${OUTPUT_DIR}/${SCRIPT_NAME_PREFIX}-del.rsc"

###############################################################################
# Validation
###############################################################################

# Minimum acceptable number of IPv4 prefixes
MIN_PREFIXES=5000

###############################################################################
# Logging
###############################################################################

LOG_PREFIX="GEOIP"
