# Valtero

Multi-currency personal expense tracker (Flutter). Primary target: Linux; also Windows desktop and Android.

**App version (single source of truth):** [`VERSION`](VERSION) (`x.y.z+build`).  
`make` / release scripts sync it into `pubspec.yaml` and pass `--build-name` / `--build-number` / `--dart-define=APP_VERSION=…` so Linux, Windows, and Android (and the in-app label in Settings) all get the same value.

```bash
make version                     # show
make version-major               # 1.2.3+5 → 2.0.0+5
make version-minor               # 1.2.3+5 → 1.3.0+5
make version-patch               # 1.2.3+5 → 1.2.4+5
make version-build               # 1.2.3+5 → 1.2.3+6  (Android versionCode)
make version VERSION=1.2.0+3     # set exact + sync pubspec
make sync-version                # VERSION → pubspec.yaml only
```

## Requirements

| Tool | Constraint (`pubspec.yaml`) | Notes |
|------|-----------------------------|--------|
| **Flutter** | `>=3.41.0 <4.0.0` | Required |
| **Dart** | `^3.11.4` | Bundled with Flutter (do not install Dart separately) |
| **Make** | GNU Make 3.81+ | Optional; wraps `flutter` / release scripts via [`Makefile`](Makefile) |

Download Flutter: [https://docs.flutter.dev/install](https://docs.flutter.dev/install)  
Official docs also cover Linux and Windows setup: [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)

### Install Make

**Ubuntu / Debian**

```bash
sudo apt update && sudo apt install -y make
make --version
```

**Fedora**

```bash
sudo dnf install -y make
```

**macOS** — Xcode Command Line Tools include `make`:

```bash
xcode-select --install
make --version
```

**Windows** — native `cmd` / PowerShell do **not** ship GNU Make. Pick one:

| Option | How |
|--------|-----|
| [Chocolatey](https://chocolatey.org/) | `choco install make` |
| [Scoop](https://scoop.sh/) | `scoop install make` |
| [Winget](https://learn.microsoft.com/windows/package-manager/winget/) | `winget install ezwinports.make` (or another GNU Make package) |
| WSL2 (Ubuntu) | `sudo apt install make` inside WSL; run Linux/Android targets there |

After install, open a **new** terminal and check:

```powershell
make --version
```

Notes for Windows + Make:

- Prefer **PowerShell** or **cmd** with Make on PATH (Chocolatey/Scoop). Git Bash may also work if `make` is on PATH.
- `make release-windows` calls PowerShell and only works on a Windows host with the VS C++ toolchain.
- `make release-linux` / `make release-android` need a Unix shell (`bash`) for the `.sh` scripts — use WSL/Ubuntu for those, or call the scripts directly from Git Bash if bash is available.

### Install Flutter — Linux

1. Install git and curl if missing: `sudo apt update && sudo apt install -y git curl unzip xz-utils zip libglu1-mesa`
2. Clone the stable SDK (or extract a release archive from the install page):

```bash
git clone https://github.com/flutter/flutter.git -b stable ~/flutter
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

3. Check the toolchain and accept Android licenses if you need Android:

```bash
flutter --version   # expect Flutter >= 3.41
flutter doctor
flutter doctor --android-licenses   # optional, for Android
```

4. Linux desktop also needs: `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev` (see `flutter doctor` for exact packages).

### Install Flutter — Windows

1. Download the Windows Flutter SDK zip from [https://docs.flutter.dev/install/windows](https://docs.flutter.dev/install/windows) (or clone `https://github.com/flutter/flutter.git` with branch `stable`).
2. Unpack to a path **without spaces** (e.g. `C:\src\flutter`).
3. Add `C:\src\flutter\bin` to the user **PATH**.
4. Open a new terminal and run:

```powershell
flutter --version   # expect Flutter >= 3.41
flutter doctor
```

5. For Windows desktop builds, install [Visual Studio 2022 Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/) with workload **Desktop development with C++** (MSVC + Windows SDK).
6. For Android builds, install [Android Studio](https://developer.android.com/studio) (Android SDK + emulator or a USB device) and run `flutter doctor --android-licenses`.

### Project setup (both platforms)

```bash
git clone <repo-url>
cd valtero
flutter pub get
# or: make pub-get
make codegen          # Drift code generation (required after clone / schema changes)
make run-linux        # or run-windows / run-android
```

### Make targets

```bash
make help
make pub-get
make codegen
make doctor
make run-linux          # or run-windows / run-android
make build-linux        # or build-windows / build-android
make release-linux      # or release-windows / release-android
make release-linux FOLDER_STYLE=Version
make release-android TARGET_PLATFORM=android-arm64
```

## Linux

Prerequisites: Flutter (see [Requirements](#requirements)), Linux desktop toolchain (clang, cmake, ninja, GTK), optional Make.

```bash
flutter run -d linux
flutter build linux --release
# or: make run-linux / make build-linux
```

Release bundle via script / Make (copies into `dist/linux/` with version/timestamp, e.g. `Valtero-1.0.0+1_2026-07-19_133045`):

```bash
make release-linux
make release-linux FOLDER_STYLE=Version      # Valtero-1.0.0+1
make release-linux FOLDER_STYLE=Date         # Valtero-2026-07-19_133045
make release-linux FOLDER_STYLE=VersionDate  # default

# equivalent:
./scripts/build_linux_release.sh
./scripts/build_linux_release.sh --folder-style Version
```

Distribute the **whole** folder (not only `valtero` — keep `lib/` and `data/` next to it).

## Windows

Prerequisites: Flutter + VS 2022 C++ workload (see [Requirements](#requirements)), optional GNU Make (see [Install Make](#install-make)).

```powershell
flutter run -d windows
flutter build windows --release
# or: make run-windows / make build-windows
```

Release bundle via script / Make (copies into `dist\windows\` with version/timestamp, e.g. `Valtero-1.0.0+1_2026-07-19_133045`):

```powershell
make release-windows
make release-windows FOLDER_STYLE=Version      # Valtero-1.0.0+1
make release-windows FOLDER_STYLE=Date         # Valtero-2026-07-19_133045
make release-windows FOLDER_STYLE=VersionDate  # default

# equivalent:
.\scripts\build_windows_release.ps1
.\scripts\build_windows_release.ps1 -FolderStyle Version
```

Distribute the **whole** folder (not only `valtero.exe` — keep DLLs and `data\` next to it).

## Android

Prerequisites: Flutter + Android SDK / Android Studio (see [Requirements](#requirements)), optional Make + bash (Ubuntu/WSL or Git Bash). App id: `com.valtero.valtero`.

```bash
flutter run -d android
flutter build apk --debug
flutter build apk --release
# or: make run-android / make build-android
```

Release APK via script / Make (copies into `dist/android/` as a single `.apk`, e.g. `Valtero-1.0.0+1_2026-07-19_133045.apk`):

```bash
make release-android
make release-android FOLDER_STYLE=Version      # Valtero-1.0.0+1.apk
make release-android FOLDER_STYLE=Date         # Valtero-2026-07-19_133045.apk
make release-android FOLDER_STYLE=VersionDate  # default
make release-android TARGET_PLATFORM=android-arm64

# equivalent:
./scripts/build_android_release.sh
./scripts/build_android_release.sh --folder-style Version
./scripts/build_android_release.sh --target-platform android-arm64
```

Install with `adb install -r dist/android/<file>.apk`. Replace debug signing in Gradle before publishing to a store.

## Architecture

Light Feature-Sliced Design. See [AGENTS.md](AGENTS.md).

Tool-agnostic agent rules live in `docs/agent-rules/`. Cursor-specific `.cursor/rules/*.mdc` is gitignored and can be generated from those files (see AGENTS.md).
