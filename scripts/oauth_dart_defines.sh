#!/usr/bin/env bash
# Prints Flutter --dart-define flags from a local KEY=VALUE env file.
# Missing file or empty values → prints nothing (exit 0).
#
# Usage:
#   ./scripts/oauth_dart_defines.sh              # reads ./local.oauth.env
#   ./scripts/oauth_dart_defines.sh path/to.env
#
# Allowed keys (others are ignored):
#   GOOGLE_OAUTH_CLIENT_ID_DESKTOP
#   GOOGLE_OAUTH_CLIENT_SECRET_DESKTOP
#   GOOGLE_OAUTH_CLIENT_ID_ANDROID
#   GOOGLE_OAUTH_CLIENT_ID          (legacy fallback for any platform)

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${1:-$ROOT/local.oauth.env}"

if [[ ! -f "$ENV_FILE" ]]; then
  exit 0
fi

allowed=(
  GOOGLE_OAUTH_CLIENT_ID_DESKTOP
  GOOGLE_OAUTH_CLIENT_SECRET_DESKTOP
  GOOGLE_OAUTH_CLIENT_ID_ANDROID
  GOOGLE_OAUTH_CLIENT_ID
)

is_allowed() {
  local key="$1"
  local a
  for a in "${allowed[@]}"; do
    [[ "$a" == "$key" ]] && return 0
  done
  return 1
}

trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

strip_quotes() {
  local s="$1"
  if [[ ${#s} -ge 2 ]]; then
    local first="${s:0:1}"
    local last="${s: -1}"
    if [[ "$first" == '"' && "$last" == '"' ]] || [[ "$first" == "'" && "$last" == "'" ]]; then
      s="${s:1:-1}"
    fi
  fi
  printf '%s' "$s"
}

defines=()
while IFS= read -r line || [[ -n "$line" ]]; do
  line="$(trim "$line")"
  [[ -z "$line" ]] && continue
  [[ "$line" == \#* ]] && continue
  [[ "$line" != *=* ]] && continue

  key="$(trim "${line%%=*}")"
  val="$(trim "${line#*=}")"
  val="$(strip_quotes "$val")"

  is_allowed "$key" || continue
  [[ -z "$val" ]] && continue

  defines+=("--dart-define=${key}=${val}")
done < "$ENV_FILE"

if [[ ${#defines[@]} -gt 0 ]]; then
  printf '%s' "${defines[*]}"
fi
