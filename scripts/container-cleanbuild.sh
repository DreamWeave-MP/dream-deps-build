#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
IMAGE_NAME="openmw-deps"
OUTPUT_DIR="${OUTPUT_DIR:-$REPO_ROOT}"
CONTAINER_ENGINE="${CONTAINER_ENGINE:-podman}"

cd "$REPO_ROOT"

rm -f "$OUTPUT_DIR/vcpkg-x64-linux-dynamic.7z"

echo "=== Building image ($CONTAINER_ENGINE) ==="
$CONTAINER_ENGINE build -t "$IMAGE_NAME" .

echo "=== Copying deps archive from container ==="
$CONTAINER_ENGINE run --rm -v "$OUTPUT_DIR":/host:Z "$IMAGE_NAME" cp /out/vcpkg-x64-linux-dynamic.7z /host/

echo "=== Cleaning up image ==="
$CONTAINER_ENGINE rmi "$IMAGE_NAME"

echo ""
echo "Output: $OUTPUT_DIR/vcpkg-x64-linux-dynamic.7z"
