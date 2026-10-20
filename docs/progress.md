# Progress

## Current milestone
M0 complete (2026-10-20). Next milestone: M1 — Database and sync function. Stop here; no M1 implementation or hosted deployment has started.

## Done
- Owner approved `com.gingobell.capturemoment`; current release is macOS, iOS and Windows. Android is deferred to M14.
- Owner approved public GitHub repository https://github.com/Gingobell/Capture-Moments-To-Diary. Repository initialized and pushed with the existing SSH identity; built-in GitHub connector also works. No extra CLI login needed.
- GitHub Actions enabled (repository settings inspected). Workflow uses read-only repository permissions and runs on every push/PR.
- Brief v1.66, handoff and setup documents reflect public visibility. Documents moved into docs; screenshot tool moved into tools; obsolete phase2-CLAUDE.md removed.
- 80 Phase 1 reference PNGs committed, including computed styles, source SHA and font evidence. Nunito 400/600 and Literata 400 explicitly loaded; broken images rejected. All images reviewed as contact sheets and full-size samples. Phase 1 HTML remains unchanged.
- Screenshot fixture now supplies a synthetic G avatar, fixing the supplied stub's broken avatar image. Records are synthetic; no AI provider or cloud database was called.
- Flutter three-platform bootstrap created with the exact approved bundle identifiers, pinned dependencies, lockfile, lint configuration and `app/env/example.json`. M0 has only a Day-background bootstrap; product screens begin at M2. No signing team configured.
- Supabase initialized with shared function and eval directories, empty migrations/seed, Deno UTF-8 stream smoke test and pgTAP environment tests. No hosted project linked.
- Local validation passed: Flutter analyze, widget test, Deno test, two pgTAP assertions, reference integrity audit and macOS debug build.
- CI on implementation/reference commit `5e7ea1c` passed all four jobs: Flutter analyze/tests/reference audit, Deno/database tests, macOS release build and Windows release build. Evidence: https://github.com/Gingobell/Capture-Moments-To-Diary/actions/runs/39488053892.
- Initial Ubuntu native-hook failure fixed by installing GTK 3, X11 and Xi development packages; no tests removed or skipped.
- Public commit audit passed for common credential patterns and ignored-file boundaries. Course PDF contains private chat references and remains local/git-ignored, along with secrets, private environment files and `.venv`.
- Local Supabase test stack stopped with data backed up to Docker volumes. Existing remote Docker context unchanged.

## Next
1. Owner creates a hosted Supabase project and completes login/linking setup in docs/01-setup-checklist.md before M1.
2. M1: implement tables, indexes, triggers, RLS, sync_push, tombstone purge and synthetic seed/tests per docs/02-backend-spec.md.
3. Stop at the M1 owner checkpoint before applying migrations to the hosted project.

## Open questions
- AI provider/model selection remains the M6 checkpoint.
- macOS build reports upstream HotKey conformance / legacy CocoaPods integration warnings; both local and CI builds pass. Revisit plugin upgrades only if needed.
- App signing, native login setup and real-device acceptance remain future owner checkpoints; M0 success does not validate product behavior or a distributed app.
- Android SDK is intentionally absent and does not block this release.

## Owner actions needed
- Before M1, create the Supabase project and complete local login/linking. Never paste service-role keys or AI keys into chat or tracked files.
- For local Supabase on this Mac, explicitly set `DOCKER_HOST=unix://$HOME/.docker/run/docker.sock`; the default Docker context is an unrelated remote environment.
