# Capture Moment to Diary

Flutter course project for macOS, iOS and Windows, with Supabase. Android is deferred.

## Status

M0 bootstrap: no product screens or live backend integration yet. See [progress](docs/progress.md), [milestones](docs/04-milestones.md) and [build brief](capture-moment-build-brief.md).

## Local checks

```sh
cd app
flutter pub get
flutter analyze
flutter test
```

```sh
deno test supabase/functions
```

For local Supabase on this Mac, explicitly target Docker Desktop (the user's default context may be remote):

```sh
DOCKER_HOST=unix://$HOME/.docker/run/docker.sock supabase start
DOCKER_HOST=unix://$HOME/.docker/run/docker.sock supabase test db
```

Do not link or deploy to a hosted project until the M1 owner checkpoint.

## Phase 1 references

```sh
python3.13 -m venv .venv
.venv/bin/python -m pip install -r tools/phase1-screens/requirements.txt
.venv/bin/python -m playwright install chromium
.venv/bin/python tools/phase1-screens/capture.py
```

Google Fonts network access is required. The reference fixture is synthetic; no provider or cloud database is called. `capture-moment.html` is maintained separately and must not be edited here.

## Public repository

The owner explicitly approved public source on 2026-10-20. Never commit private records, credentials, signing keys or local environment files. Only `app/env/example.json` is tracked. The app identifier is `com.gingobell.capturemoment`; signing is configured later by the owner.
