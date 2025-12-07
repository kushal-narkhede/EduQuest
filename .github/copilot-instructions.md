<!-- Copilot instructions for EduQuest repository -->
# EduQuest — Guidance for AI coding agents

This file contains concise, actionable guidance for code-writing agents working in this repository. Use it to make safe, focused edits that respect project conventions and integration points.

1) Big picture
- Frontend: Flutter app under `lib/` (single app: `main.dart` is the central entrypoint). UI screens live in `lib/screens/`.
- Local persistence: SQLite via `lib/helpers/database_helper.dart` (singleton, current DB version = 4).
- Optional backend: Node + Express in `server/` implementing the `RemoteApiClient` contract (see `lib/helpers/remote_api_client.dart`).
- AI/chat: BLoC pattern in `lib/ai/bloc/` (`ChatBloc`) and repo code in `lib/ai/repos/`.
- FRQ tooling: `lib/helpers/frq_manager.dart` parses canonical answers in `assets/`.

2) Why things are structured this way (concise)
- The app supports offline-first UX: local SQLite is primary; `AppConfig.useRemoteDb` toggles remote usage and `DatabaseHelper` falls back to local on remote failures.
- `RemoteApiClient` mirrors the backend endpoints described in `server/README.md` so the app can switch to Mongo/Atlas without UI changes.
- AI interactions are centralized in `ChatBloc` and seeded from `assets/prompts/setUpAi.txt` for consistent model context.

3) Important integration points & files to read first
- `lib/utils/config.dart` — `AppConfig.baseUrl` and `useRemoteDb` toggle (use `--dart-define=API_BASE_URL` to override).
- `lib/helpers/remote_api_client.dart` — remote HTTP contract and error-handling expectations.
- `lib/helpers/database_helper.dart` — DB schema, migrations (`_onCreate`, `_onUpgrade`) and fallback rules.
- `lib/ai/bloc/chat_bloc.dart` & `lib/ai/repos/` — how messages are composed and where system prompts come from.
- `server/README.md` — list of backend endpoints and dev notes (Android emulator uses `10.0.2.2`).

4) Developer workflows (exact commands / examples)
- Install Flutter deps:
```
flutter pub get
```
- Run app (point to dev backend if needed):
```
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```
- Backend (PowerShell on Windows):
```
cd server
npm install
copy .env.example .env   # then edit .env to set MONGODB_URI
npm run dev
```
- Run tests (Flutter):
```
flutter test
```

5) Project-specific conventions and gotchas
- Network host: Android emulator -> host machine uses `http://10.0.2.2:3000` (handled in `AppConfig.baseUrl`). Always prefer overriding with `--dart-define` for reproducible runs.
- Remote fallback: `DatabaseHelper.authenticateUser` tries remote login when `AppConfig.useRemoteDb == true` and falls back to SQLite — when changing auth flows update both RemoteApiClient and local DB logic.
- HTTP handling: `RemoteApiClient` uses `Dio` with `validateStatus: (_) => true` — it does not throw for non-2xx; callers must check status codes and data shape.
- DB schema: current version is 4. If you alter tables, bump the version in `_initDatabase` and implement a compatible `_onUpgrade` migration.
- Assets-driven prompts/data: `assets/prompts/setUpAi.txt`, `assets/apcs_2024_frq_answers.txt`, and `assets/apfrq/APCompSciA2024.txt` are parsed at runtime — keep formatting stable when modifying.

6) Examples of safe, focused edits
- Fix a bug in AI chat generation: modify `lib/ai/repos/*` or `ChatBloc` only, run `flutter test` and manual smoke test via UI.
- Add a new study set: add files under `lib/data/` / `assets/` and update `PremadeStudySetsRepository` used by `database_helper`.
- Change backend schema: update `server/` code, then update `RemoteApiClient` *and* `DatabaseHelper` migration logic.

7) Common patterns to follow
- Keep changes small and local to one subsystem (UI, DB, AI, server). The repo mixes local and remote implementations — always run an integration smoke test if touching both.
- Prefer using `AppConfig.baseUrl` and `--dart-define` for endpoint changes rather than hardcoding URLs.
- Preserve existing log messages and migration steps when changing DB schema — the app relies on verbose debug prints during upgrades.

8) Where to look for more context
- High-level: `README.md` and `.kiro/docs/KIRO_USAGE_WRITEUP.md` (Kiro-generated steering docs).
- Backend specifics: `server/README.md` and `server/src` for endpoint behavior.
- Runtime wiring: `lib/main.dart` (app entry), `lib/utils/config.dart`, `lib/helpers/*`.

If anything above is unclear or you want me to expand examples (e.g., add commands for CI or step-by-step migration templates), tell me which parts to iterate on.
