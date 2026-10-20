# 04 — Milestones

Work top to bottom. Each milestone lists its tasks, what "done" means, and any **owner checkpoint** (stop, report, wait for the owner). Record progress in `docs/progress.md`. Setup steps the owner must do first are in `01-setup-checklist.md`; if one is missing, stop and name it.

**Every milestone that builds or changes screens (M2, M4–M8, M10, M11) has one more "Done when" item:** the visual check in `05-design-system.md` §9 passes for its screens, with screenshots saved under `docs/progress/screens/<milestone>/`.

Speed: M1 (backend) and M2–M5 (app screens with local data) don't depend on each other and can run in parallel in two sessions. M6 needs M1 and M2.

## M0 — Repository and Phase 1 reference
The repository root is `CS6983/project1/` (it already holds `AGENTS.md`, the brief, `capture-moment.html` and the `phase2-*` docs).
- `git init` in `CS6983/project1/` (if not already) and connect the owner's GitHub repo. `.gitignore`: build outputs, `.dart_tool/`, `app/env/*.json` except `example.json`, `supabase/functions/.env`, `supabase/.temp/`, keystores, `*.p8`, `*.jks`, `.DS_Store`, `node_modules/`, Python caches.
- Move the docs into place: `phase2-00-handoff.md` → `docs/00-handoff.md`, `phase2-01-setup-checklist.md` → `docs/01-setup-checklist.md`, likewise `02` to `05` (drop the `phase2-` prefix); `phase2-tools-phase1-screens.py` → `tools/phase1-screens/capture.py`. Delete `phase2-CLAUDE.md`. Update the brief's header line that names these files.
- Create `docs/progress.md` (sections: Current milestone, Done, Next, Open questions, Owner actions needed) and `docs/decisions-log.md` (a table: date, question, choice, why).
- Run `python tools/phase1-screens/capture.py`. Check that `docs/reference/screens/` has 80 images, `computed-styles.json` and `phase1-version.txt` exist, and the screenshots show real Nunito and Literata fonts (the script needs internet for Google Fonts). Commit them.
- `flutter create app --org com.gingobell --platforms macos,windows,ios --project-name capture_moment --empty` (then ensure iOS/macOS bundle IDs are exactly `com.gingobell.capturemoment`, since Flutter generates camel case); add the packages from port doc §1; `flutter_lints` and `analysis_options.yaml`; `app/env/example.json`.
- `supabase init` at the root; `supabase/functions/_shared/`; `tools/eval/`.
- GitHub Actions: on every push run `flutter analyze`, `flutter test`, `deno test`, and `supabase test db` (Ubuntu with the Supabase CLI); a Windows job running `flutter build windows`; a macOS job running `flutter build macos`.

**Done when:** the layout matches brief §18 (with `CS6983/project1/` as the root), the reference screenshots and computed styles are committed, CI is green on the empty app, and `docs/progress.md` says M1 is next.

## M1 — Database and sync function
- Migrations for backend spec §2: tables, indexes, triggers, RLS policies, Realtime publication, `sync_push`, the daily tombstone purge (`pg_cron`).
- `supabase/seed.sql`: two test users with a few moments, a diary and a chat each.
- pgTAP tests from §2.6.

**Done when:** `supabase db reset` and `supabase test db` pass locally and in CI.
**Owner checkpoint:** before `supabase db push` to the real project — confirm the project is linked.

## M2 — App shell, sign-in, design tokens, window prototype
- `CmTokens` (Day/Night/Auto) and fonts; `GlassSurface`, glass pills, inset field, sheet, toast (port doc §5).
- go_router with the three tabs and the tab bar (selected tab light), Settings route, Day view route.
- Sign-in screen and flows (port doc §4) against the local Supabase; session restore on launch; sign out.
- Desktop prototype: register ⌥⇧D / Alt+Shift+D, show/hide the window at 450 px on the right, Esc hides, hide returns focus.
- Golden tests for the empty Home in Day and Night.

**Done when:** a new user can sign in with email code locally, sees an empty Home in the right colors and fonts, and on macOS the shortcut toggles the window.
**Owner checkpoint:** the owner tries the shortcut on the Mac and signs in with Apple and Google against the real project (needs the checklist's sign-in setup).

## M3 — Local data layer
- Drift tables, outbox and meta (port doc §3, backend spec §2.2); one database file per user.
- Repositories for moments, diaries, chats, drafts and settings: watch streams, writes that go to the table and outbox in one transaction, soft deletes.
- `core/`: the 4 AM app day, date lines, ids (v4, diary v5), moment date limits, change-signal computation.
- Unit and repository tests (port doc §11).

**Done when:** tests pass; records survive an app restart; nothing touches the network yet.

## M4 — Home and capture
Port brief §5 "Home" fully: header, the jar (candies, melting syrup from the 8th, glowing water when empty, wiggle, How it works pop-up), capture card (field auto-saved as a draft, Talk with me and Save moment pills, Cmd/Ctrl+Enter), the save flight and candy drop, starters, the Today line with the Make diary pill, Lucky diary bubble (sheet comes in M7), Unfinished, privacy footer and sync status line.

**Done when:** the Home widget tests and goldens pass, and a moment saved on Home shows the full animation at 60 fps on the Mac.

## M5 — Moments and Day view
Port brief §5 "Moments" and "Day view": day groups, moment editor sheet (text, date, delete with confirmation), + Add a moment sheet with its draft, search, day header links (Make/Update/Read diary), the Day view with diary actions, Moments (N), "Not in diary yet", the change signal and notices.

**Done when:** widget tests for editing, moving a moment to another date (both days' diaries flagged) and deleting pass.

## M6 — AI functions and Talk with me
- `_shared/provider.ts` (OpenAI-compatible, streaming, JSON mode), `_shared/prompts.ts` ported verbatim from Phase 1, `_shared/limits.ts`; functions `chat-turn`, `draft-moments`, `write-diary`, `delete-account` (backend spec §4–§5); Deno tests with a mocked provider.
- The eval runner and cases (backend spec §5.4).
- App: `ai/` client with SSE parsing; Talk with me sheet exactly as brief §5 (greeting, streaming bubbles, typing dots, one question at a time, Make it a moment, quick replies, draft cards, Add to earlier moment, Past chats, Pick up your last chat, Chat kept for later, full chat, the safety line); first-AI-use note with the new copy; offline and error messages (port doc §10).

**Done when:** function tests pass; a full chat works against the local functions with a real provider key; the eval report is written for each configured provider.
**Owner checkpoint:** the owner sets the provider secrets, reads `tools/eval/report-*.md`, and picks the provider and models. If outputs break the diary rules, adjust only the provider-specific wrapper (e.g. system vs user role, temperature), never the rules themselves, and re-run; report what changed.

## M7 — Diaries
Make diary sheet (four styles, moment checklist, defaults), streamed writing into the Day view with incomplete/Try again/Stop writing, one diary at a time, regenerate confirmation; the Diary tab: month title, clothesline (notes, clips, layout math, scrolling past 7, faded edges, candy page dots, hover preview and sway on desktop, swing-in, opening at the newest), the three-level date picker, search, Make today's diary card, the month list; Lucky diary sheet.

**Done when:** clothesline layout tests pass for 1, 7, 8 and 31 diaries at 320, 390 and 450 px; Diary goldens pass; a diary streams end to end.

## M8 — Settings, Chinese, tours, records, accounts
- Settings: profile, Your name, Theme, Language, Your records (Download my diary, Import from the web version), Tips, Account (Sign out, Delete account), Privacy, Developer (debug only).
- Chinese: ARB files from Phase 1's dictionary; every screen checked in Chinese.
- First-time tours exactly as brief §5 (hand, caption placement scoring, tour order, tips stored in settings).
- Phase 1 import (backend spec §6.2) with its tests.
- Write the Phase 1 export change as a short spec in `docs/phase1-export.md` (button, file format from §6.1).

**Done when:** tests pass; an export fixture imports correctly twice without duplicates; deleting an account removes the server data and the local database.
**Owner checkpoint:** the owner applies the Phase 1 export change in the Phase 1 project (by saying "update" there with `docs/phase1-export.md`), exports their own Phase 1 data and imports it.

## M9 — Sync
Push, pull, Realtime and the status line (backend spec §3); a sync trigger on launch, reconnect and coming to the front.

**Done when:** tests with two simulated devices pass (edit on both while offline, reconnect, both converge; deletes propagate; a diary written for the same day on both ends up as one).
**Owner checkpoint:** the owner runs the Mac app and an iOS simulator (or phone) on the same account and checks that a moment saved on one appears on the other within a few seconds.

## M10 — Desktop finish
Port doc §8 in full: saved size and place per monitor, over full-screen apps and all Spaces, keep on top, close hides, menu bar/tray menu, launch at login, Settings → Shortcut with conflict message, first-run sheet; the two-column wide layout; voice on macOS and Windows.

**Done when:** the window shows within 150 ms of the key press on the Mac.
**Owner checkpoint:** the owner uses the shortcut for a day of normal work on the Mac.

## M11 — iOS
Native Apple and Google sign-in, share sheet for downloads, keyboard behavior, voice permissions and copy, app icons and launch screens, performance check of glass blur on a real iPhone.

**Done when:** iOS builds in CI without signing; the iOS visual check passes.
**Owner checkpoint:** the owner signs and uploads the first TestFlight build and tests it on an iPhone.

## M12 — Windows
CI produces a Windows build artifact (zip, or MSIX if simple); installer note for testers about SmartScreen.

**Owner checkpoint:** the owner (or a classmate) tests the shortcut window, sign-in and sync on a Windows PC.

## M13 — Ready for testers
Privacy policy draft (from backend spec §7) for the owner to publish; About screen with the version; an accessibility pass (labels, focus, contrast); error and offline states reviewed; a tester guide adapting brief §16's walkthrough to Phase 2 (sign-in, the shortcut, import).

**Owner checkpoint:** the owner publishes the policy, invites testers, and runs the first session.

## M14 — Later (not needed for the course release)
Android support (deferred by owner approval on 2026-10-20): Android SDK/tooling, platform scaffold, OAuth, permissions, signing, CI build, APK distribution and real-device visual/performance tests. These do not block M0–M13.

Home-screen and lock-screen widgets; capture from the share sheet; a Linux build.
