# Progress

## Current milestone
M0 in progress — repository, references and scaffold implemented; validation and first CI run pending.

## Done
- 2026-10-20: Owner confirmed app identifier `com.gingobell.capturemoment`.
- Owner supplied repository: https://github.com/Gingobell/Capture-Moments-To-Diary.git. Built-in GitHub connector verified as Gingobell with admin/push permissions. Owner approved PUBLIC visibility. Actions enabled (settings verified), local Git initialized and existing SSH identity works.
- Flutter 3.47.7 stable and CocoaPods 1.17.0 verified. Flutter doctor passed Xcode 26.2 for iOS/macOS and detected the iOS simulator.
- Owner approved macOS, iOS and Windows for the course release; Android deferred to M14. Brief updated to v1.65; entry instructions, handoff, setup checklist, port, milestones and design testing scope aligned. Phase 1 source unchanged.
- Docker CLI and local Docker Desktop engine 29.1.3 verified via explicit `desktop-linux` context on 2026-10-20. Existing images/containers and default context unchanged.

- Deno 2.9.7 stable verified on 2026-10-20. Homebrew Python 3.13.16 and pip 26.2.1 verified. Xcode Python remains installed separately; project `.venv` now has Playwright 1.64.0. Chromium 156.0.8078.4 launched and saved a local 800x500 PNG successfully (2026-10-20). This verifies tooling only, not the Phase 1 reference capture.

## Next
- Complete reference QA, local Supabase test and CI across Ubuntu, macOS and Windows.
- M1 only after M0 is complete and the owner supplies hosted Supabase setup.

## Open questions
- Local Docker default context is remote; use explicit DOCKER_HOST for local Supabase.
- Course PDF retained locally, excluded from public repository because it contains private chat references.
- Android deferred; no Android SDK needed.

## Owner actions needed
- None for ongoing M0 work. Hosted Supabase project and linking are needed before M1.

## M0 work completed so far
- Documents moved to docs; screenshot script moved to tools; obsolete phase2-CLAUDE.md removed.
- Three-platform scaffold, exact dependency pins, corrected bundle identifiers, environment template, Supabase init and CI workflow created.
- Flutter analyze and widget test pass; Deno streaming smoke test passes; local macOS debug build succeeds.
- All 80 references captured with synthetic avatar and strict font/image checks; contact-sheet review covered all 80. PNG dimensions, source SHA and styles passed automated audit.
- Local Supabase stack is healthy; pgTAP bootstrap tests passed (2 assertions).
- First GitHub Actions run started: https://github.com/Gingobell/Capture-Moments-To-Diary/actions/runs/39487611251; Ubuntu native dependency failure diagnosed and fixed in workflow; rerun pending.
