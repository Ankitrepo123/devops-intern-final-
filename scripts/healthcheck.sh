#!/usr/bin/env bash

set -euo pipefail

TARGET_URL="${1:-http://localhost:8080}"

echo "Checking application: ${TARGET_URL}"

if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl is required but was not found"
    exit 1
fi

HTTP_STATUS="$(curl -sS -o /dev/null -w '%{http_code}' "${TARGET_URL}")"

if [ "${HTTP_STATUS}" = "200" ]; then
    echo "Healthcheck passed: HTTP ${HTTP_STATUS}"
    exit 0
fi

echo "Healthcheck failed: expected HTTP 200, received HTTP ${HTTP_STATUS}"
exit 1
