#!/usr/bin/env bash

set -euo pipefail

echo "=== System Information ==="

echo "Current user: $(id -un)"
echo "Effective UID: $(id -u)"

echo "Hostname: $(uname -n)"
echo "Kernel release: $(uname -r)"

echo "System date: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"

echo
echo "=== Disk Usage ==="
df -h /

echo
echo "=== Memory Usage ==="
if command -v free >/dev/null 2>&1; then
    free -h
else
    echo "Memory information unavailable: 'free' command not found"
fi

echo
echo "=== Docker Daemon ==="
if docker info >/dev/null 2>&1; then
    echo "Docker daemon: running"
else
    echo "Docker daemon: not running or unavailable"
fi
