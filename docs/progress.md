# Progress

## Current milestone
M1 complete and deployed to the hosted capture-moment project after explicit owner approval (2026-10-20). All four CI jobs passed. Next: M2 owner sign-in setup; M2 implementation has not started.

## Done
- Owner approved `com.gingobell.capturemoment`; current release is macOS, iOS and Windows. Android is deferred to M14.
- Owner approved public GitHub repository https://github.com/Gingobell/Capture-Moments-To-Diary. Repository initialized and pushed with the existing SSH identity; built-in GitHub connector also works. No extra CLI login needed.
- GitHub Actions enabled (repository settings inspected). Workflow uses read-only repository permissions and runs on every push/PR.
- Brief v1.66, handoff and setup documents reflect public visibility. Documents moved into docs; screenshot tool moved into tools; obsolete phase2-CLAUDE.md removed.
- 80 Phase 1 reference PNGs committed, including computed styles, source SHA and font evidence. Nunito 400/600 and Literata 400 explicitly loaded; broken images rejected. All images reviewed as contact sheets and full-size samples. Phase 1 HTML remains unchanged.
- Screenshot fixture now supplies a synthetic G avatar, fixing the supplied stub's broken avatar image. Records are synthetic; no AI provider or cloud database was called.
- Flutter three-platform bootstrap created with the exact approved bundle identifiers, pinned dependencies, lockfile, lint configuration and `app/env/example.json`. M0 has only a Day-background bootstrap; product screens begin at M2. No signing team configured.
- Supabase initialized with shared function and eval directories, empty migrations/seed, Deno UTF-8 stream smoke test and pgTAP environment tests. Hosted project linked during subsequent M1 setup (see below).
- Local validation passed: Flutter analyze, widget test, Deno test, two pgTAP assertions, reference integrity audit and macOS debug build.
- CI on implementation/reference commit `5e7ea1c` passed all four jobs: Flutter analyze/tests/reference audit, Deno/database tests, macOS release build and Windows release build. Evidence: https://github.com/Gingobell/Capture-Moments-To-Diary/actions/runs/39488053892.
- Initial Ubuntu native-hook failure fixed by installing GTK 3, X11 and Xi development packages; no tests removed or skipped.
- Public commit audit passed for common credential patterns and ignored-file boundaries. Course PDF contains private chat references and remains local/git-ignored, along with secrets, private environment files and `.venv`.
- Local Supabase test stack stopped with data backed up to Docker volumes. Existing remote Docker context unchanged.

## M1 completed locally
- Added six tables, sync indexes, owner-only RLS, explicit role grants and five-table Realtime publication.
- Added server sync timestamps, content clearing on tombstone insert/update, canonical per-account/day diary IDs, and private daily 90-day tombstone purge.
- Added atomic `sync_push` with full-row last-write-wins semantics, defaults, stale/equal detection, authenticated ownership and 200-item limit.
- Seed contains only two synthetic accounts and synthetic moments, diaries, chats, drafts, settings and usage fixtures; local/CI only.
- Local `supabase db reset --local` passed; database suite passed 131 assertions. Deno smoke test and all 80 reference integrity checks passed. Flutter analyze and widget tests passed before commit; database function lint found no errors.
- CI now explicitly performs `supabase db reset --local` before database tests. Hosted migration was subsequently deployed with owner approval (see below); synthetic seed was not uploaded. M1 has no UI changes or visual screenshot requirement.

- Local test containers stopped after validation, with data backed up in Docker volumes. No unrelated remote Docker environment was touched.

## Hosted deployment verified
- Owner explicitly authorized deployment after all CI checks passed, with no test data upload.
- All four jobs passed on `fd42219`: backend, Flutter, macOS release and Windows release. Evidence: https://github.com/Gingobell/Capture-Moments-To-Diary/actions/runs/39493862797.
- Confirmed linked target `capture-moment`, project ref `xzefyvrgkrzgtqfvzqmt`.
- Dry run listed only `20261021000000_m1_database.sql`; `supabase db push --linked --yes` applied it successfully, without `--include-seed` or custom roles.
- Read-back migration list confirms matching local and remote migration version. Cloud table statistics report zero estimated rows in all six business tables. No seed or test suite was run against the hosted database.

## Next
1. Guide owner through M2 sign-in prerequisites in docs/01-setup-checklist.md: Apple developer membership status, Google OAuth, email sign-in and redirect configuration. Do not purchase services or configure credentials without the owner's participation.
2. Configure git-ignored app environment with project URL and public key when needed.
3. Implement M2 app shell, login, design tokens and desktop shortcut, then stop for the owner's visual/shortcut and real-provider sign-in checkpoint.

## Open questions
- AI provider/model selection remains the M6 checkpoint.
- macOS build reports upstream HotKey conformance / legacy CocoaPods integration warnings; both local and CI builds pass. Revisit plugin upgrades only if needed.
- App signing, native login setup and real-device acceptance remain future owner checkpoints; M0 success does not validate product behavior or a distributed app.
- Android SDK is intentionally absent and does not block this release.

## Owner actions needed
- M1 is deployed. Next owner step: confirm Apple developer membership status before guiding sign-in provider setup. App public-key configuration remains pending for app integration. Never paste service-role keys or AI keys into chat or tracked files.
- For local Supabase on this Mac, explicitly set `DOCKER_HOST=unix://$HOME/.docker/run/docker.sock`; the default Docker context is an unrelated remote environment.
