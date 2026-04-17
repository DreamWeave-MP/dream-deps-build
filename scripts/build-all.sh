#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/config.sh
source "$SCRIPT_DIR/lib/config.sh"
REPO_ROOT="${OPENMW_DEPS_REPO_ROOT}"

run_as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        echo "ERROR: Need root privileges to run '$*' and sudo is not available" >&2
        exit 1
    fi
}

TRIPLET="${TRIPLET:-$DEFAULT_TRIPLET}"
VCPKG_DIR="${VCPKG_DIR:-/opt/vcpkg}"
OUTPUT_DIR="${OUTPUT_DIR:-$REPO_ROOT}"

export VCPKG_DIR
export PROFILE

echo "Running full dependency build"
echo "  profile: $PROFILE"
echo "  triplet: $TRIPLET"
echo "  image: $BUILD_IMAGE"
echo "  vcpkg revision: $VCPKG_REVISION"
echo "  output dir: $OUTPUT_DIR"

echo "=== Installing system dependencies ==="
run_as_root bash -e "$SCRIPT_DIR/install-system-deps.sh"

echo -e "\n=== Setting up vcpkg ==="
run_as_root bash -e "$SCRIPT_DIR/setup-vcpkg.sh"
run_as_root chown -R "$(id -u):$(id -g)" "$VCPKG_DIR"

echo -e "\n=== Building deps (triplet=$TRIPLET) ==="
TRIPLET="$TRIPLET" bash -e "$SCRIPT_DIR/build-deps.sh"

echo -e "\n=== Exporting ==="
source "$BUILD_TOOLSET_ENABLE"
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
