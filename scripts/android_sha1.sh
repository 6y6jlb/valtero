#!/usr/bin/env bash
# Prints SHA-1 certificate fingerprint for Google Cloud Android OAuth client.
#
# Usage:
#   ./scripts/android_sha1.sh              # debug keystore (default)
#   ./scripts/android_sha1.sh debug
#   ./scripts/android_sha1.sh release \
#     --keystore /path/to/upload.jks \
#     --alias upload \
#     --storepass '…' \
#     [--keypass '…']
#
# Make:
#   make android-sha1
#   make android-sha1-release KEYSTORE=… ALIAS=… STOREPASS=…

set -euo pipefail

MODE="${1:-debug}"
shift || true

KEYSTORE=""
ALIAS=""
STOREPASS=""
KEYPASS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --keystore) KEYSTORE="${2:?}"; shift 2 ;;
    --alias) ALIAS="${2:?}"; shift 2 ;;
    --storepass) STOREPASS="${2:?}"; shift 2 ;;
    --keypass) KEYPASS="${2:?}"; shift 2 ;;
    -h|--help)
      sed -n '2,18p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if ! command -v keytool >/dev/null 2>&1; then
  echo 'keytool not found (install a JDK and ensure keytool is on PATH).' >&2
  exit 1
fi

case "$MODE" in
  debug)
    KEYSTORE="${KEYSTORE:-$HOME/.android/debug.keystore}"
    ALIAS="${ALIAS:-androiddebugkey}"
    STOREPASS="${STOREPASS:-android}"
    KEYPASS="${KEYPASS:-android}"
    ;;
  release)
    if [[ -z "$KEYSTORE" || -z "$ALIAS" || -z "$STOREPASS" ]]; then
      echo 'release mode requires --keystore, --alias, and --storepass' >&2
      echo '(or Make: KEYSTORE=… ALIAS=… STOREPASS=…)' >&2
      exit 1
    fi
    KEYPASS="${KEYPASS:-$STOREPASS}"
    ;;
  *)
    echo "Unknown mode: $MODE (use debug or release)" >&2
    exit 1
    ;;
esac

if [[ ! -f "$KEYSTORE" ]]; then
  echo "Keystore not found: $KEYSTORE" >&2
  if [[ "$MODE" == debug ]]; then
    echo 'Run an Android build once (flutter run -d android) to create the debug keystore.' >&2
  fi
  exit 1
fi

echo "Keystore: $KEYSTORE"
echo "Alias:    $ALIAS"
echo ''

# Prefer SHA1 line from -list -v; fall back to -printcert parsing.
if OUT="$(keytool -list -v -keystore "$KEYSTORE" -alias "$ALIAS" \
  -storepass "$STOREPASS" -keypass "$KEYPASS" 2>/dev/null)"; then
  echo "$OUT" | awk '
    BEGIN { IGNORECASE=1 }
    /^[[:space:]]*SHA1:/ {
      sub(/^[[:space:]]*SHA1:[[:space:]]*/, "")
      print
      found=1
      exit
    }
    END { if (!found) exit 1 }
  ' && exit 0
fi

echo 'Could not read certificate with keytool -list -v.' >&2
exit 1
