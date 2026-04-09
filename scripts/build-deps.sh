#!/usr/bin/env bash
set -euo pipefail

VCPKG_DIR="${VCPKG_DIR:-/opt/vcpkg}"
TRIPLET="${TRIPLET:-x64-linux-dynamic}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

export PATH="$VCPKG_DIR:$PATH"

source /opt/rh/gcc-toolset-13/enable

echo "Building deps with triplet=$TRIPLET"

cd "$REPO_ROOT"
vcpkg install \
    --overlay-ports="$REPO_ROOT/ports" \
    --overlay-triplets="$REPO_ROOT/triplets" \
    --triplet "$TRIPLET" \
    --host-triplet "$TRIPLET"

echo ""
echo "Done. To export:"
echo "  vcpkg export --x-all-installed --7zip --output-dir ./ --output vcpkg-$TRIPLET"
