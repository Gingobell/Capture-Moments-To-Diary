# 03 — Porting Phase 1 to Flutter

Phase 1 (`capture-moment.html`, described in brief §1–§17) is the spec for what people see and do. This file says how its web-specific parts become Flutter, and lists every deliberate change. Anything not mentioned here behaves exactly as in Phase 1.

## 1. Packages
`flutter_riverpod` (state), `go_router` (navigation), `drift` + `sqlite3_flutter_libs` (local database), `supabase_flutter` (auth, database, Realtime), `http` (streaming calls to the AI functions), `uuid` (v4 and v5), `intl` + `flutter_localizations` (dates, ARB strings), `flutter_svg` (icons), `connectivity_plus`, `file_selector` (save files on desktop), `share_plus` (share files on phones), `speech_to_text` (voice), `sign_in_with_apple`, `google_sign_in`, `app_links` (sign-in redirects). Desktop only: `hotkey_manager`, `window_manager`, `tray_manager`, `launch_at_startup`, `screen_retriever`. Pin exact versions in `pubspec.yaml` and record them in `docs/decisions-log.md`.

## 2. Structure and state
Folder layout as in brief §18 "Project structure". Each feature folder holds its screens, widgets and Riverpod providers. Repositories (`data/repos/`) are the only code that touches the database; they expose `Stream`s that screens watch, so every screen updates when local data changes (from the person or from a sync pull). Pure logic (the 4 AM day, date lines, change signal, clothesline layout math, flag parsing, card mapping) lives in `core/` as plain Dart functions with unit tests.

## 3. Local data
- One SQLite database **per signed-in person**: `capture_moment_<user_id>.sqlite` in the app support folder. Signing out closes it; signing in as someone else opens theirs. Two people sharing a computer never see each other's records (Phase 1's shared-browser rule).
- Drift tables mirror the server tables (backend spec §2.2) with the same columns, plus: `outbox(id autoincrement, table_name, row_id, payload json, created_at)` and `meta(key, value)` (last pull time per table).
- Deletes set `deleted_at` locally too; every query filters `deleted_at is null`.
- Device-only settings live in a small key-value file, not in the synced `settings` table: shortcut key, window frame, keep on top, launch at login, last-used Auto theme check.
- No `localStorage` mirror, no boot/device stores: those existed only because of the artifact.

## 4. Sign-in (new screen)
Shown on first launch and after signing out; the app requires an account once, then works offline.
- Same look as Home's header and capture card: the title "Capture moments to diary", subline "One line now. A diary later.", then three glass pills stacked: **Continue with Apple**, **Continue with Google**, **Continue with email**. Below them, the privacy footer line.
- Email: an inset field "Your email" and **Send code**; then a 6-digit code field and **Sign in** ("We sent a code to x@y.com."). Codes avoid magic links opening on a different device. The emailed message also contains a link, which works too.
- Apple appears on every platform (on Windows it uses Supabase's web OAuth flow); Google uses native sign-in on iOS and the web flow on desktop. Redirect scheme from the setup checklist.
- After sign-in: create the `settings` row if missing, run the first pull, then open Home. First launch on desktop also shows a one-time sheet: "Press ⌥⇧D anytime to open this window." (Windows: "Alt+Shift+D") with **Open at login** (on by default) and **Done**.
- The name shown defaults to the account's first name (`full_name` from Google, the name Apple gives on first sign-in, else nothing). Avatar from Google; otherwise a circle with the first letter on `--accent-soft`.

## 5. Design system
- **Tokens:** one `ThemeExtension` (`CmTokens`) holding every token in `05-design-system.md` §2, Day and Night, with the exact measured colors. Auto switches by the clock (Night 6 PM–6 AM), rechecked every minute. Both themes are light; `Brightness.light` always.
- **Fonts:** Nunito 400/600 and Literata 400 bundled as assets (offline), with the fallbacks from §10 (`PingFang SC`, `Noto Sans SC`, `Songti SC`, `Noto Serif SC`) for Chinese.
- **Glass:** `ClipRRect` + `BackdropFilter(blur)` + the fill, rim, inset bevel and drop from `05-design-system.md` (inset shadows need the custom `InsetShadowPainter` described there). Build it once as `GlassSurface` and reuse it for pills, cards, sheets, the jar, notes and tip captions. Frosted glass only; Apple's native Liquid Glass is not used (owner decision, see `05` §6). Keep blurred layers to what's on screen; if a device drops frames (check on iOS and Windows; Android testing deferred to M14), fall back to the same fill at 93% opacity without blur.
- **Lights under glass** (`--halo`, `--corner`): `DecoratedBox` with blurred radial gradients behind the surface.
- **Motion:** every duration and curve in §5/§10 kept. Use `AnimationController`s and implicit animations; the save slip flight uses an `Overlay` entry flying from the field to the jar. The clothesline springs keep Phase 1's constants (stiffness, damping, push) in a ticker. When `MediaQuery.disableAnimations` is true, follow Phase 1's reduced-motion rules.
- **Icons:** copy each inline SVG from Phase 1 into `assets/icons/` and draw with `flutter_svg` (1.75px rounded strokes).

## 6. Layout
- The Phase 1 single column (max 560px, centered) is the layout for phones and the shortcut window.
- When the window is at least 900 logical px wide, Moments and Diary may show two columns (list or line on the left, the Day view on the right). Home stays one column. This is an addition; build it last (M10).
- Safe areas and the keyboard: Flutter's `SafeArea` and `viewInsets`; on phones the capture field and Save stay above the keyboard and the tab bar hides while it's open (as in Phase 1).

## 7. Web → Flutter mapping
| Phase 1 (web) | Phase 2 (Flutter) |
|---|---|
| CSS variables, `data-theme` | `CmTokens` theme extension |
| `backdrop-filter`, box shadows | `GlassSurface` (§5) |
| hover preview and sway on notes (mouse only) | `MouseRegion`, only when the pointer is a mouse; tap opens everywhere |
| clothesline faded edges (CSS mask) | `ShaderMask` with a linear gradient |
| sideways scroll with mouse drag | `ScrollConfiguration` with mouse in `dragDevices`; same 4px tap threshold |
| `aria-live` announcements | `SemanticsService.announce` |
| focus ring, keyboard navigation | `FocusableActionDetector` with the 2px `--accent-strong` ring |
| Cmd/Ctrl+Enter to save | `Shortcuts`/`Actions` on the capture field |
| `db` + `onSnapshot`, `localStorage` mirror | drift streams + sync (backend spec §3) |
| `sample` / `sample.json` | `ai/` client calling the Edge Functions with `http` (SSE parsed by hand: `event:` / `data:` lines), using the session's access token |
| platform AI consent prompt | only the first-AI-use note (new copy below) |
| `user.me()` name and avatar | account metadata (§4) |
| `downloads` (Markdown file) | desktop: `file_selector` save dialog; phones: `share_plus` share sheet with the file |
| `window.confirm` replaced by sheets | the same in-app sheets |
| Chinese via `MutationObserver` dictionary | ARB files (`app_en.arb`, `app_zh.arb`); extract every English string and its Chinese from Phase 1's dictionary; dates with `intl` (`zh_CN`) |
| page hidden → flush drafts | `AppLifecycleListener` (inactive/hidden/paused) and window blur on desktop |
| owner-only Dev mode | a Developer section that exists only in debug builds (`kDebugMode`) |
| voice deferred (§7) | voice built: `speech_to_text` on the capture field and chat reply box, following brief §7 (audio never stored, `source: voice`, visible recording state, live text saved as a draft) |

## 8. The desktop shortcut window (macOS and Windows)
- **Default shortcut:** ⌥⇧D on macOS, Alt+Shift+D on Windows; changeable in Settings → **Shortcut** (press the new keys). If registering fails (another app owns it), Settings says "This shortcut is taken by another app. Try another." and the menu bar/tray item still opens the window.
- **Toggle:** pressing the shortcut when the window is hidden or behind other windows shows it on the monitor where the pointer is, at its saved size and place, in front, with Home's capture field focused. Pressing it while the window is in front hides it. Esc closes an open sheet first; with none open, Esc hides the window.
- **Window:** default 450 px wide and the screen height minus 80 px, 16 px from the right edge; minimum 380×560; resizable; size and place remembered per monitor. macOS: hidden title bar with the traffic lights; shows over full-screen apps and on every Space (`setVisibleOnAllWorkspaces(true, visibleOnFullScreen: true)`). Windows: standard frame.
- **Hiding returns focus** to the app the person was using (macOS: hide the app, not just the window).
- **Keep on top:** off by default; a setting turns it on.
- **Closing** the window hides it; the app keeps running in the menu bar (macOS) or tray (Windows) with **Open (⌥⇧D)**, **Settings**, **Quit**. The Dock/taskbar icon stays.
- **Launch at login:** on by default after the first-run sheet; a setting turns it off.
- Created at launch and kept alive, so showing it is instant (target: visible within 150 ms of the key press).
- Sync pulls when the window comes to the front.

## 9. Phones
- Same app, same layout. iOS is the current phone target; Android is deferred to M14, including its sign-in, share sheet and keyboard adaptation.
- Home-screen and lock-screen widgets (tap → app opens on Home with the field focused) come after the first phone release (M14).

## 10. Deliberate changes from Phase 1
1. **Sign-in screen** and account section (§4; Settings → Account: the sign-in method and email, **Sign out**, **Delete account** with a confirmation sheet "Delete your account? All your moments, diaries and chats will be removed from every device. This can't be undone." **Delete account** / Cancel).
2. **The AI is no longer Claude**, so copy names "AI" instead (Chinese in brackets):
   - Footer: "Private to you. Only the text you choose is sent to AI." (只属于你。只有你选择的文字会发给 AI。)
   - First-AI-use note title "Before you use AI help" (使用 AI 帮助之前); body "This sends the text you choose to an AI service to help you write. Your moments stay private to you." (这会把你选择的文字发给 AI 服务来帮你写。你的瞬间仍然只属于你。) with **Continue**.
   - Settings privacy paragraph: "…the text you choose is sent to an AI service to help you write." plus a **Privacy policy** link.
   - Errors: "Couldn't reach the AI. Your moments are safe — try again in a moment." · "The AI is busy right now. Your moments are safe — try again in a moment." · "That's more text than the AI can take at once. Try choosing fewer moments."
   - New, for `limit_reached`: "You've used today's AI help. Your moments are safe, and you can still capture and browse. It resets tomorrow." (今天的 AI 帮助已经用完了。你的瞬间都在，仍然可以记录和浏览。明天会重置。)
   - Typing indicator label "Typing" (正在输入); moment label "With Claude" → "From a chat" (来自聊天); Past chats empty "No past chats yet. Your conversations will be kept here."; Unfinished chat line "Chat, [time]".
   - Profile: "Signed in with Apple / Google / email. Your diary is private to you."; Your name hint ends "Leave it empty to use your account name."
   Any other string containing "Claude" follows the same pattern; list each in `docs/decisions-log.md`.
3. **Offline AI:** Talk with me and Make diary stay visible; tapping them offline shows "You're offline. AI help needs a connection; your moments are saved." (AI is never "off" in Phase 2, so Phase 1's "AI features are off" line is only used if the server reports AI disabled.)
4. **Settings additions:** Account (above); Your records → **Import from the web version** (backend spec §6.2); desktop only → **Shortcut**, **Open at login**, **Keep on top**.
5. **Voice** is built (§7 table).
6. **Two-column wide layout** (§6) is new and optional.
7. **Phase 2 release scope revision (owner approved 2026-10-20):** macOS, iOS and Windows only for the course release. Android moves to M14; Android SDK, OAuth, signing, builds and device testing are deferred. Flutter remains the shared codebase; Phase 1 behavior and appearance are unchanged.

8. **Repository visibility (owner approved 2026-10-20):** public source repository; secrets, private environment configuration and personal records stay excluded. No product behavior changes.

## 11. Tests
- Unit (`test/core/`): the 4 AM day, date lines ("Today"/"Yesterday"), moment date limits, change-signal counts, clothesline layout math (1–7 notes fit and shrink; 8+ scroll at the 7-across size; brief §5 formulas), jar candy/syrup math, `cleanReply`/`replyFlags`, draft-card mapping and fallbacks, Phase 1 import mapping, UUIDv5 ids.
- Repositories and sync (`test/data/`): in-memory drift with a fake server — outbox survives restart, last write wins both ways, tombstones propagate, the 5-minute overlap is harmless, Realtime triggers a pull.
- Widget tests (`test/features/`): save a moment (field clears, candy added, "Moment saved" announced); a typed draft survives a restart and shows under Unfinished; a chat with a fake AI drafts cards and saves; Make diary streams and marks incomplete when stopped; the change signal appears after editing a source moment; every tour tip appears once and tapping anywhere moves on.
- Golden tests: Home, Moments, Diary, Day view, Talk with me and Settings in Day and Night at 390×844 (phone) and 450×900 (shortcut window), English and Chinese.
- Manual, by the owner: the shortcut window on macOS and Windows; sign-in on each platform; voice; real-device performance.
