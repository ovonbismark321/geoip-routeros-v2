#!/usr/bin/env python3
#
# ============================================================
# GEOIP_RU Generator
# Extract IPv4 prefixes
# ============================================================

import ipaddress
import json
import sys


def error(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    sys.exit(1)


if len(sys.argv) != 3:
    error("Usage: extract_ipv4.py <input.json> <output.txt>")

json_file = sys.argv[1]
output_file = sys.argv[2]


#
# ----------------------------------------------------------------------
# Read JSON
# ----------------------------------------------------------------------
#

try:
    with open(json_file, "r", encoding="utf-8") as f:
        data = json.load(f)

except Exception as exc:
    error(f"Cannot read '{json_file}': {exc}")


#
# ----------------------------------------------------------------------
# Extract IPv4 prefixes
# ----------------------------------------------------------------------
#

prefixes = set()

for rule in data.get("rules", []):

    for prefix in rule.get("ip_cidr", []):

        if ":" in prefix:
            continue

        try:
            ipaddress.IPv4Network(prefix, strict=False)
            prefixes.add(prefix)

        except ValueError:
            continue


#
# ----------------------------------------------------------------------
# Write TXT
# ----------------------------------------------------------------------
#

try:

    with open(output_file, "w", encoding="utf-8", newline="\n") as f:

        for prefix in sorted(prefixes):
            f.write(prefix + "\n")

except Exception as exc:
    error(f"Cannot write '{output_file}': {exc}")


print(f"IPv4 prefixes extracted: {len(prefixes)}")
