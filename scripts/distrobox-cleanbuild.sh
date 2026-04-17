#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/fail.sh
source "$SCRIPT_DIR/lib/fail.sh"
openmw_init_error_trap
# shellcheck source=lib/config.sh
source "$SCRIPT_DIR/lib/config.sh"

TRIPLET="${TRIPLET:-$DEFAULT_TRIPLET}"
OUTPUT_DIR="${OUTPUT_DIR:-$OPENMW_DEPS_REPO_ROOT}"
BOX_NAME="${BOX_NAME:-openmw-deps-${PROFILE}}"

echo "=== Running preflight doctor (distrobox mode) ==="
MODE=distrobox TRIPLET="$TRIPLET" OUTPUT_DIR="$OUTPUT_DIR" PROFILE="$PROFILE" bash -e "$SCRIPT_DIR/doctor.sh"

echo "=== Creating fresh $BOX_NAME ==="
distrobox create --name "$BOX_NAME" --image "$BUILD_IMAGE"

echo "=== Running build-all.sh inside $BOX_NAME ==="
distrobox enter "$BOX_NAME" -- env \
    PROFILE="$PROFILE" \
    TRIPLET="$TRIPLET" \
    OUTPUT_DIR="$OUTPUT_DIR" \
    OPENMW_DEPS_SKIP_DOCTOR=1 \
    bash -e "$SCRIPT_DIR/build-all.sh"

echo "=== Deleting $BOX_NAME ==="
distrobox rm --force "$BOX_NAME" 2>/dev/null || true
