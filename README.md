# README

Valtero — multi-currency personal expense tracker (Flutter).

## Platforms

- Linux (primary)
- Android
- Windows

## Architecture

Light Feature-Sliced Design. See [AGENTS.md](AGENTS.md).

## Run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d linux
```

## Agent rules

Tool-agnostic rules live in `docs/agent-rules/`. Cursor-specific `.cursor/rules/*.mdc` is gitignored and can be generated from those files (see AGENTS.md).
