#!/usr/bin/env bash
# Builds a runnable Linux Release bundle and copies it to
# dist/linux/<folder>/ for distribution.
#
# Version SSOT: ./VERSION (synced to pubspec.yaml; passed as --build-name/--build-number).
#
# Folder naming (default: version + build date/time):
#   ./scripts/build_linux_release.sh
#   ./scripts/build_linux_release.sh --folder-style Version      # Valtero-<VERSION>
#   ./scripts/build_linux_release.sh --folder-style Date         # Valtero-2026-07-19_133045
#   ./scripts/build_linux_release.sh --folder-style VersionDate  # Valtero-<VERSION>_2026-07-19_133045
#
# Prerequisites: Flutter SDK, Linux desktop toolchain (clang, cmake, ninja, GTK).

set -euo pipefail

FOLDER_STYLE='VersionDate'

while [[ $# -gt 0 ]]; do
  case "$1" in
    --folder-style)
      FOLDER_STYLE="${2:?--folder-style requires Version|Date|VersionDate}"
      shift 2
      ;;
    -h|--help)
      sed -n '2,14p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

case "$FOLDER_STYLE" in
  Version|Date|VersionDate) ;;
  *)
    echo "Invalid --folder-style: $FOLDER_STYLE (use Version, Date, or VersionDate)" >&2
    exit 1
    ;;
esac

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"
VERSION_SCRIPT="$PROJECT_ROOT/scripts/app_version.sh"

if ! command -v flutter >/dev/null 2>&1; then
  echo 'flutter not found. Install Flutter or add it to PATH.' >&2
  exit 1
fi

case "$(uname -m)" in
  x86_64) ARCH='x64' ;;
  aarch64|arm64) ARCH='arm64' ;;
  *)
    echo "Unsupported Linux arch: $(uname -m)" >&2
    exit 1
    ;;
esac

dist_folder_name() {
  local style="$1"
  local app_version="$2"
  local stamp
  stamp="$(date +'%Y-%m-%d_%H%M%S')"
  case "$style" in
    Version) printf 'Valtero-%s' "$app_version" ;;
    Date) printf 'Valtero-%s' "$stamp" ;;
    VersionDate) printf 'Valtero-%s_%s' "$app_version" "$stamp" ;;
  esac
}

"$VERSION_SCRIPT" sync
APP_VERSION="$("$VERSION_SCRIPT" print)"
# shellcheck disable=SC2046
read -r -a FLUTTER_VERSION_ARGS < <("$VERSION_SCRIPT" flutter-args)
OAUTH_DEFINES="$("$PROJECT_ROOT/scripts/oauth_dart_defines.sh" "$PROJECT_ROOT/local.oauth.env" || true)"
# shellcheck disable=SC2206
OAUTH_ARGS=( $OAUTH_DEFINES )

DIST_FOLDER_NAME="$(dist_folder_name "$FOLDER_STYLE" "$APP_VERSION")"
DIST_ROOT="$PROJECT_ROOT/dist/linux"
DIST_DIR="$DIST_ROOT/$DIST_FOLDER_NAME"
RELEASE_DIR="$PROJECT_ROOT/build/linux/$ARCH/release/bundle"
BINARY_PATH="$RELEASE_DIR/valtero"

echo "Using Flutter: $(command -v flutter)"
echo "App version: $APP_VERSION (from VERSION)"
echo "Folder style: $FOLDER_STYLE"
echo "Linux arch: $ARCH"
echo "Running: flutter build linux --release ${FLUTTER_VERSION_ARGS[*]} ${OAUTH_ARGS[*]}"

# Flutter may skip creating this when no package ships Dart FFI native assets;
# CMake still expects the path unless linux/CMakeLists.txt guards with EXISTS.
mkdir -p "$PROJECT_ROOT/build/native_assets/linux"

flutter build linux --release "${FLUTTER_VERSION_ARGS[@]}" ${OAUTH_ARGS[@]+"${OAUTH_ARGS[@]}"}

if [[ ! -x "$BINARY_PATH" ]]; then
  echo "Build finished but executable not found at: $BINARY_PATH" >&2
  exit 1
fi

mkdir -p "$DIST_ROOT"
rm -rf "$DIST_DIR"

echo "Copying release bundle to: $DIST_DIR"
cp -a "$RELEASE_DIR" "$DIST_DIR"

DIST_BINARY="$DIST_DIR/valtero"
if [[ ! -x "$DIST_BINARY" ]]; then
  echo "Copy finished but executable not found at: $DIST_BINARY" >&2
  exit 1
fi

echo
echo 'Release build ready.'
echo "Executable: $DIST_BINARY"
echo "Distribute the entire folder: $DIST_DIR"
echo '(valtero alone is not enough — keep lib/ and data/ next to it.)'
