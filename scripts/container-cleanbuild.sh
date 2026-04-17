#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=lib/config.sh
source "$SCRIPT_DIR/lib/config.sh"

TRIPLET="${TRIPLET:-$DEFAULT_TRIPLET}"
IMAGE_NAME="openmw-deps-${PROFILE}"
OUTPUT_DIR="${OUTPUT_DIR:-$REPO_ROOT}"
CONTAINER_ENGINE="${CONTAINER_ENGINE:-podman}"

cd "$REPO_ROOT"

rm -f "$OUTPUT_DIR/vcpkg-$TRIPLET.7z"

echo "=== Building image ($CONTAINER_ENGINE) ==="
$CONTAINER_ENGINE build --build-arg BASE_IMAGE="$BUILD_IMAGE" -t "$IMAGE_NAME" .

echo "=== Running clean build inside container ==="
$CONTAINER_ENGINE run --rm \
    -e PROFILE="$PROFILE" \
    -e TRIPLET="$TRIPLET" \
    -e OUTPUT_DIR=/out \
    -v "$OUTPUT_DIR":/out:Z \
    "$IMAGE_NAME" \
    bash -e scripts/build-all.sh

echo "=== Cleaning up image ==="
$CONTAINER_ENGINE rmi "$IMAGE_NAME"

echo ""
echo "Output: $OUTPUT_DIR/vcpkg-$TRIPLET.7z"
