# Tooling & environment

Agents must use the **host / project tooling as installed**, not invent local copies of SDKs or toolchains inside the repo.

## Hard ban — never copy toolchains into the workspace

Do **not** copy, rsync, clone, vendor, or symlink into the project (or any path under the workspace) things like:

- Flutter / Dart SDK
- Android SDK / NDK / emulator images
- Node, JVM, Python, Rust toolchains
- Full copies of `/opt/flutter`, `~/flutter`, or similar system installs
- Writable “shadow” SDK trees (e.g. `.tools/flutter`, `flutter_local`, vendored `bin/cache`) to bypass permission errors

Also do **not**:

- `chmod` / rewrite files under a system Flutter install to “make tests work”
- Bind-mount or overlay a second Flutter tree into the repo
- Commit or leave multi‑hundred‑MB / GB toolchain trees next to app code

These belong on the **machine**, managed by the user (distro packages, `snap`, official Flutter install, CI image) — never as a project workaround.

## When `flutter` / `dart` / build tools fail

Typical agent-session failures: running as root, read-only `/opt/flutter/bin/cache`, missing `engine.stamp` write, sandbox network limits.

**Allowed responses (in order):**

1. Prefer a **lighter command that already works** for the immediate need (e.g. `dart analyze` on touched files; manual ARB → generated l10n edit only if `flutter gen-l10n` is blocked and you can keep files consistent).
2. Report the **exact error** and what you could / could not verify (tests not run, l10n not regenerated).
3. Ask the user to run the blocked command on their normal user session (`flutter test`, `flutter gen-l10n`, `make …`), or to fix environment permissions.

**Forbidden responses:**

- Copying the SDK into the repo “so cache is writable”
- Installing a second Flutter under the project to unblock yourself
- Expanding scope into environment surgery unrelated to the user’s feature request

## Related

- Tests still require full `flutter test` before calling a plan done when the environment allows it — see [testing.md](testing.md). If the suite cannot run, say so; do not fake a green gate with a local SDK copy.
- New pub packages still need approve — [dependencies.md](dependencies.md). That is separate from this ban on copying SDKs.
