# AGENTS.md — Capture Moment to Diary, Phase 2

You are building the full-stack version of **Capture Moment to Diary**: one Flutter app for macOS, Windows and iOS (Android deferred to M14 by owner approval on 2026-10-20), with a Supabase backend. Everything about what to build has already been decided and written down. Your job is to implement it faithfully, one milestone at a time, and keep the documents true.

**This folder (`CS6983/project1/`) is the repository root.** It also holds Phase 1 (the finished web app) and the product brief, which you will read constantly.

## Start of every session (do this before anything else)
1. Read this file to the end.
2. Read `docs/progress.md` (before M0 it doesn't exist: you are at M0). It says which milestone and task are next and what was left open.
3. Read `docs/00-handoff.md` sections 1–5 if you haven't in this session (product, experience, rules, preferences, decisions).
4. Open the milestone in `docs/04-milestones.md` and every document it points to for the task at hand.
5. If `capture-moment.html` changed since `docs/reference/phase1-version.txt` (compare its SHA-256), re-run `.venv/bin/python tools/phase1-screens/capture.py` and update that file first: Phase 1 is the visual truth and may have been updated.
6. Say in one or two lines what you will do this session, then start.

## Where everything is
| You need | Read |
|---|---|
| What the product is, the experience, rules, owner preferences, decisions not to undo, every feature, every edge case | `docs/00-handoff.md` |
| Exact behavior, screens, copy, AI rules, design values of every feature | `capture-moment-build-brief.md` §1–§17 (product truth) |
| Phase 2 decisions and architecture summary | `capture-moment-build-brief.md` §18 |
| Owner-only setup (accounts, keys, signing) | `docs/01-setup-checklist.md` |
| Database, sync, AI functions, limits, import, account deletion | `docs/02-backend-spec.md` |
| How each web behavior becomes Flutter; deliberate changes from Phase 1 | `docs/03-flutter-port.md` |
| Build order, tasks, done-when, owner checkpoints | `docs/04-milestones.md` |
| Colors, type, glass, shadows, motion: exact values and how to port them | `docs/05-design-system.md` |
| Phase 1 source code (prompts, Chinese strings, exact CSS and behavior) | `capture-moment.html` |
| What Phase 1 looks like, screen by screen | `docs/reference/screens/*.png` |
| Final computed style of every Phase 1 component | `docs/reference/computed-styles.json` |
| Where you left off | `docs/progress.md` |
| Small decisions you made and why | `docs/decisions-log.md` |
| Background research (interviews, user stories, PRD) | `Project1_Capture_Moment_to_Diary.pdf` |

Before M0 the docs sit at the root as `phase2-00-handoff.md`, `phase2-01-…` to `phase2-05-…` and `phase2-tools-phase1-screens.py`; M0 moves them to the paths above.

## Order of authority when sources disagree
1. The owner's latest instruction in the session.
2. `capture-moment-build-brief.md` §18 and `docs/01`–`docs/05` for technology and for the deliberate changes they list.
3. `capture-moment-build-brief.md` §1–§17 for product behavior, copy and design.
4. `capture-moment.html` and `docs/reference/` for exact values and anything the brief doesn't spell out.
If they still conflict or none of them answers, see "Decide or stop?".

## Rules you must not break
- **Never invent design.** Every color, size, radius, shadow, blur, font, icon, duration and curve comes from `docs/05-design-system.md`, `docs/reference/computed-styles.json`, the brief §10, or `capture-moment.html`. If a screen needs something none of them has, reuse the closest existing Phase 1 component and log it. No new colors, no new component styles, no Material or Cupertino default look showing through (no ripples, no default AppBar, no default dialogs, no blue).
- **Never change product behavior or copy** from Phase 1 unless `docs/03-flutter-port.md` §10 lists the change. Copy is used word for word (English, and Chinese from Phase 1's dictionary).
- **Never undo a decision** listed in `docs/00-handoff.md` §5 or the brief's §17/§18, even if you think another way is better. Propose it to the owner instead.
- **Prompts are ported word for word** from `capture-moment.html`. Never edit their rules.
- **Two themes only, both light** (Day lemon, Night lavender). No dark backgrounds anywhere, ever.
- **Privacy:** no AI provider calls from the app; never log prompt or diary text; never store audio; secrets only in Supabase secrets or git-ignored env files.
- **Tests:** write them with the code; never skip or delete one to get green.

## How to work
- One milestone at a time, tasks in order. A milestone is done only when every "Done when" item passes, including the **visual check**: put your Flutter screen next to the matching `docs/reference/screens/` image at the same size, theme and language, and fix every visible difference you can (spacing, color, size, shadow, font weight). Save your screenshots to `docs/progress/screens/<milestone>/` so the owner can compare.
- Commit after each completed task with a clear message (`M4: jar candies and syrup`). Run `flutter analyze` and the tests before every commit.
- Keep functions small and named after the brief's terms (jar, candy, syrup, clothesline, note, clip, Today line, Unfinished, change signal, app day).

## Decide or stop?
**Decide yourself** (then log it in `docs/decisions-log.md`: date, question, choice, why, and keep going) when it is technical (package choice, file layout, algorithm) or a tiny product detail none of the sources covers. Pick what keeps the app closest to Phase 1; then the simplest option.

**Stop and ask the owner** when it involves: money or paid services; privacy, what data leaves the device, or deleting data; signing, store submission, or anything in `docs/01-setup-checklist.md`; a visual or behavior that would differ from Phase 1; or changing any written decision. Also stop at every **Owner checkpoint** in the milestones. When you stop, say exactly what you need in one or two sentences.

## Keeping the documents true
- **After every task:** update `docs/progress.md` (done, next, open issues, anything the owner must do).
- **When you make a technical decision:** append to `docs/decisions-log.md`.
- **When the owner approves a product, design or copy change:** update the brief — the relevant section, bump the version in its title (v1.62 → v1.63), and add a dated line at the top of its changelog — and, if it's a Phase 2-only change, add it to `docs/03-flutter-port.md` §10. Then change the code and tests.
- **When a contract changes** (a table, a function's request or response, a limit): update `docs/02-backend-spec.md` in the same commit.
- Never let code and documents disagree at the end of a session.

## End of every session
1. Run analyze and all tests; commit.
2. Update `docs/progress.md`: the milestone and task you reached, what's next, open questions, owner actions needed.
3. Reply to the owner briefly, in Chinese: what changed, what's next, anything they must do.

## Commands
- App: `cd app && flutter pub get`, `flutter analyze`, `flutter test`, `flutter run -d macos` (or `windows`, an iOS simulator; Android later). Generated code: `dart run build_runner build --delete-conflicting-outputs`. Config: `--dart-define-from-file=env/dev.json` (Supabase URL and anon key only; `env/example.json` is the template).
- Backend: `supabase start` (needs Docker), `supabase db reset`, `supabase test db`, `supabase functions serve`, `deno test supabase/functions`.
- Phase 1 reference: `.venv/bin/python tools/phase1-screens/capture.py` (needs `pip install playwright && python -m playwright install chromium`).
- AI quality check: `deno run -A tools/eval/run.ts --provider gemini`.

## Never
- Commit secrets, keystores, `.env` files or `app/env/*.json` (except `example.json`).
- Edit `capture-moment.html` (Phase 1 is maintained separately, in Claude).
- Delete or rewrite the brief's history (changelog, §17).
