#!/usr/bin/env bash
# Single source of truth for app version: repo-root VERSION file.
#
# Usage:
#   ./scripts/app_version.sh print
#   ./scripts/app_version.sh build-name
#   ./scripts/app_version.sh build-number
#   ./scripts/app_version.sh flutter-args
#   ./scripts/app_version.sh sync                 # VERSION → pubspec.yaml
#   ./scripts/app_version.sh set 1.2.0+3          # write VERSION + sync pubspec
#   ./scripts/app_version.sh bump major|minor|patch|build
#
# Format: <semver>+<build>  e.g. 1.1.0+2
# Flutter: --build-name=<semver> --build-number=<build>
#
# Bump rules:
#   major  1.2.3+5 → 2.0.0+5   (build unchanged)
#   minor  1.2.3+5 → 1.3.0+5
#   patch  1.2.3+5 → 1.2.4+5
#   build  1.2.3+5 → 1.2.3+6   (only this bumps +N / Android versionCode)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSION_FILE="$PROJECT_ROOT/VERSION"
PUBSPEC_FILE="$PROJECT_ROOT/pubspec.yaml"

usage() {
  sed -n '2,22p' "$0"
}

read_raw_version() {
  if [[ ! -f "$VERSION_FILE" ]]; then
    echo "VERSION file not found: $VERSION_FILE" >&2
    exit 1
  fi
  local raw
  raw="$(tr -d '[:space:]' <"$VERSION_FILE")"
  if [[ -z "$raw" ]]; then
    echo "VERSION file is empty: $VERSION_FILE" >&2
    exit 1
  fi
  if [[ ! "$raw" =~ ^[0-9]+\.[0-9]+\.[0-9]+(\+[0-9]+)?$ ]]; then
    echo "Invalid VERSION '$raw' (expected x.y.z or x.y.z+build, e.g. 1.2.0+1)" >&2
    exit 1
  fi
  printf '%s' "$raw"
}

build_name_of() {
  local raw="$1"
  printf '%s' "${raw%%+*}"
}

build_number_of() {
  local raw="$1"
  if [[ "$raw" == *+* ]]; then
    printf '%s' "${raw#*+}"
  else
    printf '1'
  fi
}

normalized_version_of() {
  local raw="$1"
  local name number
  name="$(build_name_of "$raw")"
  number="$(build_number_of "$raw")"
  printf '%s+%s' "$name" "$number"
}

parse_semver_parts() {
  local name="$1"
  local major minor patch
  IFS='.' read -r major minor patch <<<"$name"
  printf '%s %s %s' "$major" "$minor" "$patch"
}

bump_version() {
  local part="$1"
  local raw name number major minor patch next_number next_name
  raw="$(read_raw_version)"
  name="$(build_name_of "$raw")"
  number="$(build_number_of "$raw")"
  read -r major minor patch <<<"$(parse_semver_parts "$name")"
  next_number="$number"
  next_name="$name"

  case "$part" in
    major)
      next_name="$((major + 1)).0.0"
      ;;
    minor)
      next_name="${major}.$((minor + 1)).0"
      ;;
    patch)
      next_name="${major}.${minor}.$((patch + 1))"
      ;;
    build)
      next_number=$((number + 1))
      ;;
    *)
      echo "Unknown bump part: $part (use major|minor|patch|build)" >&2
      exit 1
      ;;
  esac

  printf '%s+%s' "$next_name" "$next_number"
}

sync_pubspec() {
  local raw="$1"
  local normalized
  normalized="$(normalized_version_of "$raw")"
  if [[ ! -f "$PUBSPEC_FILE" ]]; then
    echo "pubspec.yaml not found: $PUBSPEC_FILE" >&2
    exit 1
  fi
  if ! grep -qE '^version:' "$PUBSPEC_FILE"; then
    echo "No 'version:' line in pubspec.yaml" >&2
    exit 1
  fi
  local tmp
  tmp="$(mktemp)"
  sed -E "s/^version:[[:space:]].*/version: ${normalized}/" "$PUBSPEC_FILE" >"$tmp"
  mv "$tmp" "$PUBSPEC_FILE"
  printf '%s' "$normalized"
}

write_version_file() {
  local raw="$1"
  local normalized
  normalized="$(normalized_version_of "$raw")"
  printf '%s\n' "$normalized" >"$VERSION_FILE"
  printf '%s' "$normalized"
}

apply_and_sync() {
  local next="$1"
  local previous written synced
  previous="$(normalized_version_of "$(read_raw_version)")"
  written="$(write_version_file "$next")"
  synced="$(sync_pubspec "$written")"
  echo "$previous → $synced"
}

cmd="${1:-print}"
case "$cmd" in
  -h|--help|help)
    usage
    ;;
  print)
    normalized_version_of "$(read_raw_version)"
    printf '\n'
    ;;
  build-name)
    build_name_of "$(read_raw_version)"
    printf '\n'
    ;;
  build-number)
    build_number_of "$(read_raw_version)"
    printf '\n'
    ;;
  flutter-args)
    raw="$(read_raw_version)"
    name="$(build_name_of "$raw")"
    number="$(build_number_of "$raw")"
    full="$(normalized_version_of "$raw")"
    printf -- '--build-name=%s --build-number=%s --dart-define=APP_VERSION=%s\n' \
      "$name" "$number" "$full"
    ;;
  sync)
    synced="$(sync_pubspec "$(read_raw_version)")"
    echo "Synced pubspec.yaml version → $synced"
    ;;
  set)
    if [[ $# -lt 2 ]]; then
      echo 'Usage: ./scripts/app_version.sh set <x.y.z[+build]>' >&2
      exit 1
    fi
    if [[ ! "$2" =~ ^[0-9]+\.[0-9]+\.[0-9]+(\+[0-9]+)?$ ]]; then
      echo "Invalid version '$2' (expected x.y.z or x.y.z+build, e.g. 1.2.0+1)" >&2
      exit 1
    fi
    apply_and_sync "$2"
    ;;
  bump)
    if [[ $# -lt 2 ]]; then
      echo 'Usage: ./scripts/app_version.sh bump major|minor|patch|build' >&2
      exit 1
    fi
    apply_and_sync "$(bump_version "$2")"
    ;;
  *)
    echo "Unknown command: $cmd" >&2
    usage >&2
    exit 1
    ;;
esac
