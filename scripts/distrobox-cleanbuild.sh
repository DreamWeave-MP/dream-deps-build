#!/usr/bin/env bash
set -euo pipefail

BOX_NAME="${BOX_NAME:-alma8-deps}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Creating fresh $BOX_NAME ==="
distrobox create --name "$BOX_NAME" --image almalinux:8

echo "=== Running build-all.sh inside $BOX_NAME ==="
distrobox enter "$BOX_NAME" -- bash -e "$SCRIPT_DIR/build-all.sh"

echo "=== Deleting $BOX_NAME ==="
distrobox rm --force "$BOX_NAME" 2>/dev/null || true
