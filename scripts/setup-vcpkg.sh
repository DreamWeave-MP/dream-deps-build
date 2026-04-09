#!/usr/bin/env bash
set -euo pipefail

VCPKG_DIR="${VCPKG_DIR:-/opt/vcpkg}"

# Read the pinned revision from the workflow file
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VCPKG_REVISION="${VCPKG_REVISION:-$(grep 'VCPKG_REVISION:' "$REPO_ROOT/.github/workflows/build.yaml" | head -1 | awk '{print $2}')}"

if [ -z "$VCPKG_REVISION" ]; then
    echo "ERROR: Could not determine VCPKG_REVISION" >&2
    exit 1
fi

echo "Setting up vcpkg at revision $VCPKG_REVISION in $VCPKG_DIR"

if [ -d "$VCPKG_DIR/.git" ]; then
    cd "$VCPKG_DIR"
    git fetch
    git checkout "$VCPKG_REVISION"
else
    git clone https://github.com/microsoft/vcpkg.git "$VCPKG_DIR"
    cd "$VCPKG_DIR"
    git checkout "$VCPKG_REVISION"
fi

source /opt/rh/gcc-toolset-13/enable
./bootstrap-vcpkg.sh -disableMetrics

echo ""
echo "vcpkg is ready at $VCPKG_DIR"
echo "Add it to your PATH:  export PATH=\"$VCPKG_DIR:\$PATH\""
