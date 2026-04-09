#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TRIPLET="${TRIPLET:-x64-linux-dynamic}"
VCPKG_DIR="${VCPKG_DIR:-/opt/vcpkg}"
OUTPUT_DIR="${OUTPUT_DIR:-$REPO_ROOT}"

export VCPKG_DIR

echo "=== Installing system dependencies ==="
sudo bash -e "$SCRIPT_DIR/install-system-deps.sh"

echo -e "\n=== Setting up vcpkg ==="
sudo bash -e "$SCRIPT_DIR/setup-vcpkg.sh"
sudo chown -R "$(id -u):$(id -g)" "$VCPKG_DIR"

echo -e "\n=== Building deps (triplet=$TRIPLET) ==="
TRIPLET="$TRIPLET" bash -e "$SCRIPT_DIR/build-deps.sh"

echo -e "\n=== Exporting ==="
source /opt/rh/gcc-toolset-13/enable
export PATH="$VCPKG_DIR:$PATH"
cd "$REPO_ROOT"
vcpkg export \
    --x-all-installed \
    --7zip \
    --output-dir "$OUTPUT_DIR" \
    --output "vcpkg-$TRIPLET"

echo ""
echo "=== Done ==="
echo "Output: $OUTPUT_DIR/vcpkg-$TRIPLET.7z"
