# Convenience targets wrapping Flutter and platform release scripts.
#
# Usage:
#   make help
#   make version / make version-major|minor|patch|build
#   make version VERSION=1.2.0+3
#   make pub-get / make codegen
#   make run-linux | run-windows | run-android
#   make build-linux | build-windows | build-android
#   make release-linux | release-windows | release-android
#
# Optional:
#   make release-linux FOLDER_STYLE=Version
#   make release-android TARGET_PLATFORM=android-arm64
#   make release-windows FOLDER_STYLE=Date
#
# App version SSOT: ./VERSION  (synced into pubspec.yaml on build/run)

.DEFAULT_GOAL := help

FOLDER_STYLE ?= VersionDate
TARGET_PLATFORM ?=
VERSION ?=
VERSION_SCRIPT := ./scripts/app_version.sh

.PHONY: help version version-major version-minor version-patch version-build sync-version \
	pub-get doctor codegen \
	run-linux run-windows run-android \
	build-linux build-windows build-android \
	release-linux release-windows release-android

help:
	@echo 'Valtero make targets'
	@echo ''
	@echo '  make version                 show VERSION (SSOT)'
	@echo '  make version VERSION=1.2.0+3 set exact VERSION + sync pubspec'
	@echo '  make version-major           bump major  (1.2.3+5 → 2.0.0+5)'
	@echo '  make version-minor           bump minor  (1.2.3+5 → 1.3.0+5)'
	@echo '  make version-patch           bump patch  (1.2.3+5 → 1.2.4+5)'
	@echo '  make version-build           bump build  (1.2.3+5 → 1.2.3+6)'
	@echo '  make sync-version            VERSION → pubspec.yaml'
	@echo '  make pub-get                 flutter pub get'
	@echo '  make codegen                 dart run build_runner (Drift)'
	@echo '  make doctor                  flutter doctor'
	@echo '  make run-linux               flutter run -d linux (+ version flags)'
	@echo '  make run-windows             flutter run -d windows (+ version flags)'
	@echo '  make run-android             flutter run -d android (+ version flags)'
	@echo '  make build-linux             flutter build linux --release (+ version)'
	@echo '  make build-windows           flutter build windows --release (+ version)'
	@echo '  make build-android           flutter build apk --release (+ version)'
	@echo '  make release-linux           scripts/build_linux_release.sh -> dist/linux/'
	@echo '  make release-windows         scripts/build_windows_release.ps1 -> dist/windows/'
	@echo '  make release-android         scripts/build_android_release.sh -> dist/android/'
	@echo ''
	@echo 'Variables:'
	@echo '  VERSION=1.2.0+3                     (with make version)'
	@echo '  FOLDER_STYLE=Version|Date|VersionDate   (default: VersionDate)'
	@echo '  TARGET_PLATFORM=android-arm64           (android release only)'
	@echo ''
	@echo "Current app version: $$($(VERSION_SCRIPT) print)"

version:
ifeq ($(VERSION),)
	@$(VERSION_SCRIPT) print
else
	@$(VERSION_SCRIPT) set $(VERSION)
endif

version-major:
	@$(VERSION_SCRIPT) bump major

version-minor:
	@$(VERSION_SCRIPT) bump minor

version-patch:
	@$(VERSION_SCRIPT) bump patch

version-build:
	@$(VERSION_SCRIPT) bump build

sync-version:
	@$(VERSION_SCRIPT) sync

pub-get:
	flutter pub get

doctor:
	flutter doctor

codegen:
	dart run build_runner build --delete-conflicting-outputs

run-linux: sync-version
	flutter run -d linux $$($(VERSION_SCRIPT) flutter-args)

run-windows: sync-version
	flutter run -d windows $$($(VERSION_SCRIPT) flutter-args)

run-android: sync-version
	flutter run -d android $$($(VERSION_SCRIPT) flutter-args)

build-linux: sync-version
	flutter build linux --release $$($(VERSION_SCRIPT) flutter-args)

build-windows: sync-version
	flutter build windows --release $$($(VERSION_SCRIPT) flutter-args)

build-android: sync-version
	flutter build apk --release $$($(VERSION_SCRIPT) flutter-args)

release-linux:
	./scripts/build_linux_release.sh --folder-style $(FOLDER_STYLE)

release-windows:
ifeq ($(OS),Windows_NT)
	powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./scripts/build_windows_release.ps1 -FolderStyle $(FOLDER_STYLE)
else
	@echo 'release-windows must be run on Windows (PowerShell + VS C++ toolchain).' >&2
	@exit 1
endif

release-android:
ifeq ($(TARGET_PLATFORM),)
	./scripts/build_android_release.sh --folder-style $(FOLDER_STYLE)
else
	./scripts/build_android_release.sh --folder-style $(FOLDER_STYLE) --target-platform $(TARGET_PLATFORM)
endif
