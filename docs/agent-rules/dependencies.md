# New dependencies

Do **not** add a package to `pubspec.yaml` (or otherwise pull a new third-party library) without an explicit user approve.

## Before proposing a dependency

1. **Need** — Can the feature be done with existing project code (utils, services, widgets) without a new package?
2. **Overlap** — Does `pubspec.yaml` already include a package (or transitive stack) that covers the same job? Prefer reusing or extending what is already there.
3. **Fit** — If several options exist, say briefly why this one is better for *this* project (API fit, Linux/Android/Windows support, size, maintenance, conflict risk with current pins).
4. **Health** — Confirm the package is still maintained and actively developed (recent pub.dev / GitHub activity, Flutter/Dart SDK compatibility, no abandoned status). Prefer packages with clear ownership and ongoing releases over one-off or stale ones.

## Approval gate

- Present the checklist answers to the user and **wait for explicit approve** before editing `pubspec.yaml`, running `flutter pub add`, or committing lockfile changes that introduce the package.
- User must approve the **specific package name** (and ideally the version constraint). Vague “add whatever you need” is not enough for a new dependency.
- Exception: the user already named the package and asked to add it in the same request — still verify need / overlap / health and flag risks before applying.

## After approve

- Add the smallest useful constraint; resolve version conflicts with existing deps before finishing.
- Prefer dependencies that support the project’s platforms (Linux primary; Android and Windows as supported).
- Document non-obvious choice in the PR/commit message or a short note if it affects architecture.
