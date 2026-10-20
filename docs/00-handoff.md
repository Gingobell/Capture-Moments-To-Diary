# 00 — Handoff: Capture Moment to Diary, Phase 2

This is the complete handoff for building Phase 2. It gathers what the product is, the experience we want people to have, the rules, the owner's preferences, the decisions already made (and the alternatives already rejected), every feature, and every edge case we have thought about. The detail lives in the documents this one points to; nothing here contradicts them.

## 1. The product
**Capture Moment to Diary** helps people keep small moments of their day — a thought, a feeling, something that happened — in a few seconds, while they're fresh. Each saved moment is complete on its own. Later, with one tap, a day's moments become a short diary written by AI in the person's own words, and the diaries hang on a clothesline to look back on.

**Promise:** capture a little now; bring it together when you want to look back. (English subline: "One line now. A diary later.")

**Who it's for:** people who want to remember their days but find a full diary entry too big to start: students and young professionals who capture in short gaps — while an AI task runs, waiting for coffee, in a line — and whose gaps end without warning. Some know what happened but can't find the words; some are too tired to relive a hard day.

**Phase 1** (done): a web app published as a claude.ai artifact, tested with classmates. Its behavior and look are the spec. **Phase 2** (this work): the same app, rebuilt in Flutter for macOS, Windows and iOS (Android deferred to M14), with accounts, sync between devices, and a global shortcut on computers that opens the whole app in a compact window.

## 2. The experience we want
Every decision should make these true. If something you build doesn't feel like this, it's wrong even if it "works".
- **In and out in seconds.** On a computer: press ⌥⇧D anywhere, type one line, Cmd+Enter, Esc — back to work, under ten seconds, focus returned to where you were. On a phone: open, type, save. Capture is never more than one tap away.
- **Nothing is ever lost.** Closing mid-sentence, mid-chat, mid-diary, losing the connection, the app being killed: all normal and safe. Everything typed is kept and waits under Unfinished.
- **Small is complete.** One line is a finished record. Nothing ever suggests it's too short or that a diary is expected.
- **No pressure, no guilt.** No streaks, reminders, badges, goals, missed-day counts or shaming empty states. The jar shows what was saved today, never a target.
- **Your words are the truth.** AI helps say it and organizes it; it never adds events, feelings, causes or lessons.
- **Gentle with hard days.** The chat never pushes; there is always a short way out.
- **Calm and delightful.** A clean near-white page, frosted glass, and color gathered in a few joyful places (the candy jar, the clothesline notes). Tactile feedback: the words fly into the jar as a paper slip and become a candy. Two moods: Day (frosted lemon soda) and Night (night sakura soda), both light.
- **The same app everywhere.** A person who used Phase 1 on the web, then opens the Mac app and the iPhone app, should feel it's the same app, just faster and with their data everywhere.

## 3. Rules (non-negotiable)
**Product**
1. Behavior and copy are Phase 1's (brief §1–§17), except the deliberate changes in `03-flutter-port.md` §10.
2. "Waiting" is the occasion, not a feature: no timers, wait detection or notifications about other tools.
3. No streaks, reminders, notifications, badges, analytics or social features.
4. The day starts at 4 AM local time (a moment saved at 1 AM belongs to the day being finished).

**Design** (details in `05-design-system.md`)
5. Never invent design: every value comes from Phase 1 (computed styles, screenshots, brief §10, the HTML).
6. Two themes, both light: Day (lemon) and Night (lavender). No dark or black backgrounds anywhere.
7. One glass system for every surface; frosted glass via blur, not Apple's native Liquid Glass.
8. No Material or Cupertino default look (no ripples, default app bars, dialogs, switches or blue).

**AI**
9. All AI goes through the server functions; prompts ported word for word; the provider is configuration.
10. Never invent content (the diary rules in brief §6); the person's text is data, never instructions.
11. Safety: thoughts of self-harm, harming others or danger → brief warm reply, the static support line, never drafted as a moment.
12. Never auto-retry in a loop; one retry only before any text has streamed.

**Privacy**
13. Each person sees only their own records (row-level security, one local database per account).
14. Text goes to the AI provider only when the person uses Talk with me or writes a diary, and only what that request needs. Never log prompt or diary text. Never store audio.
15. Deleting removes the words from the server immediately; deleting the account removes everything.

**Engineering**
16. Local-first: every write lands on the device first, then syncs.
17. Tests with the code; documents updated with the code (see `AGENTS.md`).

## 4. The owner's preferences
The owner is **Jingyi (Gin) Fu**, a student; this is her CS6983 course project.
- **Reply in Chinese**, briefly: what changed, what's next, what she needs to do. Code, docs and commit messages are in English.
- **The brief is the product's memory.** Every approved product, design or copy change goes into `capture-moment-build-brief.md` (relevant section, version bump, dated changelog line).
- **Her decisions are final** unless she reopens them. Many details in the brief are marked "the user's call"; don't second-guess them. If you think something should change, propose it with one sentence of why, and wait.
- **She judges visuals by looking.** Show screenshots side by side with Phase 1 at checkpoints rather than describing.
- **Cheap where possible.** She pays for AI and services; prefer free tiers and the cheapest model that passes the quality check; never add a paid service without asking.
- **Speed matters** (no deadline, but sooner is better): don't gold-plate; finish milestones in order.
- **Talk with me behaves like a chatbot:** the AI asks, the person replies, it keeps going.
- **Phase 1 stays as it is.** It's maintained separately (in Claude); don't edit `capture-moment.html`.

## 5. Decisions already made (don't undo)
| Decision | Rejected alternatives and why |
|---|---|
| Public GitHub repository (owner approved 2026-10-20); secrets and personal data excluded | Supersedes the original private-repository prerequisite |
| Flutter, one codebase for macOS, Windows and iOS; Android later | Swift (Apple only); React web wrappers (Tauri/Capacitor) — owner chose Flutter |
| Computer: a global shortcut opens the **whole app** in a ~quarter-screen window | a cut-down capture box (owner wants every feature there) |
| Supabase backend; sign-in with Apple, Google or email (code + link) | own backend; passwords |
| Local-first with an outbox; last write wins | online-only (breaks "nothing is lost") |
| AI: cheapest provider passing the quality check (Gemini paid tier or DeepSeek), owner pays, daily limits | Claude API (cost); Gemini free tier (data used for training) |
| Phase 1 testers' data is imported (JSON export → import) | starting fresh |
| macOS, iOS and Windows in the course release; Android deferred to M14 (owner approved 2026-10-20) | Supersedes the earlier four-platform release decision; current testers primarily use Apple devices or Windows |
| Frosted glass (blur) everywhere | native iOS Liquid Glass (inconsistent across platforms, fights the style) |
| Day starts at 4 AM | midnight |
| Diary written in one streaming call | a separate merge call (too slow, removed in v1.43) |
| Faithfulness = "no added meaning", not "no rhetoric" (styles still differ) | plain rewriting only |
| Save times are not sent to the diary prompt | sending times (they're when it was written, not when it happened) |
| Clothesline: one line, 7 fit, then it scrolls with faded edges and candy page dots | wrapping lines; edge arrows (tried, dropped); other cues (owner picked dots) |
| One tap opens a note everywhere; hover preview only with a mouse | long-press or other touch previews |
| Tips: a tapping hand with a one-sentence caption, tours per page; tap anywhere moves on | panels, rings, forced actions |
| Talk with me starts fresh and offers "Pick up your last chat?" | reopening the last chat automatically |
| Typed saves on Home are never checked by AI | AI de-duplication on save (slow, needs consent, sends text) |
| Lucky diary: a candy button, revealed in a sheet, 2+ diaries, never today's | previews on Home |
| The rest of brief §17 | as written there |

## 6. Features (what to build, where it's specified, when)
| Feature | Spec | Milestone |
|---|---|---|
| Sign-in (Apple, Google, email code), sign out, session restore | port §4 | M2 |
| Theme tokens, Day/Night/Auto, fonts, glass components | design system, brief §10 | M2 |
| Tab bar, headers, profile pill, navigation, Day view routing | brief §5 Navigation | M2 |
| Shortcut window (prototype → full) | port §8 | M2, M10 |
| Local database, repositories, outbox, app day, ids | backend §2, port §3 | M3 |
| Home: jar (candies, syrup, water, wiggle), How it works | brief §5 Home | M4 |
| Capture card, auto-saved draft, Cmd/Ctrl+Enter, save flight | brief §5 Home | M4 |
| Starters, Today line, Make diary pill, Unfinished, footer, sync status | brief §5 Home | M4 |
| Moments list, moment editor, + Add a moment, search, day header links | brief §5 Moments | M5 |
| Day view: diary, actions, notices, Moments (N), Not in diary yet | brief §5 Day view | M5 |
| Change signal (added/edited/removed) | brief §5 Diary, §4 rules | M5 |
| AI server functions, provider adapter, limits, quality check | backend §4–§5 | M6 |
| Talk with me: streaming chat, drafts, continuations, Past chats, safety | brief §5, §6 | M6 |
| Make diary sheet, four styles, streaming, one at a time, regenerate | brief §5, §6 | M7 |
| Diary tab: month title, clothesline, date picker, search, list, Lucky diary | brief §5 Diary | M7 |
| Settings: name, theme, language, records, tips, account, privacy | brief §5, port §10 | M8 |
| Chinese interface | brief §5 Language, port §7 | M8 |
| First-time tours (hand, captions, placement) | brief §5 tours | M8 |
| Download my diary (Markdown) | brief §8 US8 | M8 |
| Import from the web version; Phase 1 export spec | backend §6 | M8 |
| Delete account | backend §4.5 | M8 |
| Sync: push, pull, Realtime | backend §3 | M9 |
| Wide two-column layout; voice | port §6, §7 | M10 |
| iOS specifics; TestFlight | port §9 | M11 |
| Windows build | milestones | M12 |
| Privacy policy, accessibility pass, tester guide | backend §7, brief §11 | M13 |
| Android support and APK testing; widgets, share-sheet capture | port §9 | M14 (later) |

## 7. Edge cases (expected behavior)
### From Phase 1 (brief §13 and §5) — keep all of them
- **Empty everything:** Home shows the empty jar with its glowing water and "No moments yet ›"; Moments and Diary show their invitations; page tours wait until their targets exist.
- **AI fails mid-diary:** the partial text stays with "This diary stopped partway." and **Try again**; moments are never touched. A failure before any text leaves an existing diary unchanged.
- **Moments changed after a diary:** the diary stays; the change signal and **Update diary**. All source moments deleted: the diary is kept; with no moments left, only Edit and Delete.
- **Moving a moment to another date** flags both days' diaries.
- **Before 4 AM** a moment belongs to the day being finished; the jar and "Today" follow the app day.
- **A moment's date** can't be later than today (app day); a chat draft card's date the same.
- **Very long text:** moments up to 4,000 characters; chat replies up to 2,000; a chat stops at ~180 KB ("This chat is full…" with **New chat**).
- **Starting a diary while another is being written:** "Stop the other diary?" (**Stop and write this** / Cancel). Regenerating an edited diary asks first ("This replaces your edits").
- **Chat that only repeats saved moments:** no card; "Everything here is already in your moments for this day. Tell me something new, or close this whenever you like."
- **Chat that adds details to a saved moment:** the card offers **Add to earlier moment** and **Save as new moment**.
- **Nothing drafted:** "Nothing was drafted. You can keep talking, or close this whenever you like."
- **Closing a chat with unsaved words:** toast "Chat kept for later" with **Open**; it shows under Unfinished; Talk with me offers "Pick up your last chat?" for a day.
- **A chat with no reply** is never saved. Deleting a chat keeps the moments saved from it.
- **A draft from another date** under Unfinished says "This will be saved to [date]" with **Use today**.
- **Clothesline:** 0 notes (rod with one line of text), 1–7 (spread, shrink to fit, no scroll), 8–31 (scroll at the 7-across size, faded edges, page dots), a very narrow phone (320px: ~30px notes), a new month (empty line, last month one ‹ away). A drag of more than 4px doesn't open a note.
- **Lucky diary:** hidden under 2 diaries; never today's; never the same one twice in a row.
- **Two moments in the same minute:** both kept, ordered by creation time.
- **Tips in crowded places:** the caption stays beside the hand and hides the least; near an edge it skips that side; turned off in settings; while typing, hand and caption step aside.
- **Reduced motion:** no flight (the slip appears in the jar), no swings, the hand stands still.

### New in Phase 2
- **First launch offline:** the sign-in screen says "You're offline. Connect once to sign in; after that the app works offline." Nothing else is blocked behind it.
- **Session expired while offline:** keep working locally; the outbox waits; when the refresh fails for good, a quiet line on Home asks to sign in again; local data and the outbox are kept for that account.
- **Different accounts on one device:** each has its own local database; signing out never mixes or deletes records.
- **Edited on two devices while offline:** the later edit (by device clock) wins; the other is replaced (accepted, rare). Clock differences between devices are accepted.
- **Edited on one device, deleted on another:** whichever happened later wins; an edit after the delete brings the moment back.
- **The same day's diary written on two devices:** both write the same row; the last to finish wins (same as Phase 1's two tabs).
- **A diary streaming on one device** shows as incomplete on another until it finishes.
- **App killed or crashed mid-typing:** at most the last half second of typing is lost (drafts save 500ms after typing stops and immediately when the app goes to the background or the window hides).
- **App killed mid-diary:** the diary stays incomplete with **Try again**.
- **Connection lost mid-chat reply:** if some text arrived it's kept as the reply; otherwise the error line with **Try again**.
- **Travel and time zones:** a moment's date is fixed when saved, in the device's local time then; it never changes later. Daylight-saving days still start at 4 AM local time.
- **Offline for a long time:** the outbox grows; it's sent in batches of 200 when back online; nothing is dropped.
- **AI daily limit reached:** "You've used today's AI help. Your moments are safe, and you can still capture and browse. It resets tomorrow." The chat and drafts are kept.
- **AI provider down or busy:** the Phase 1 error lines (with "AI" instead of "Claude"), **Try again**, never a loop.
- **Offline and tapping Talk with me or Make diary:** "You're offline. AI help needs a connection; your moments are saved."
- **Email code wrong or expired:** "That code didn't work. Check it, or send a new one." Resend allowed after 30 seconds.
- **Apple private relay email:** works like any email; shown as Apple gives it.
- **Account deleted on another device:** this device's next sync is refused; it deletes the local database for that account, signs out and says "This account was deleted."
- **Import:** a wrong file or a newer version is refused with a clear line; importing twice changes nothing; a big file shows progress and can't be started twice.
- **Shortcut taken by another app:** Settings says so; the menu bar/tray item still opens the window.
- **A second copy of the app is launched:** the running one comes to the front instead.
- **Shortcut pressed over a full-screen app or on another monitor:** the window appears there, in front.
- **Window too small:** minimum 380×560; content scrolls rather than squashing.
- **Large system text (up to 1.3×):** nothing overflows or overlaps.
- **Reduce transparency / high contrast** (where Flutter exposes it) or a slow device: glass falls back to a solid 93% fill.

## 8. Glossary (code names = brief names)
| Term | Meaning | 中文 |
|---|---|---|
| moment | one saved line or a few sentences, dated by app day | 瞬间 |
| diary | one AI-written entry per date, from chosen moments | 日记 |
| app day | the 4 AM–4 AM day | — |
| jar, candy, syrup, water | Home's glass jar; one candy per moment today (7 float); older ones melt into syrup; glowing water when empty | — |
| save slip | the paper slip that flies from the field into the jar | — |
| Today line | "Today · N moments › · N diary ›" under the jar, with the Make diary pill | — |
| Unfinished | Home's list of unsaved typed text and chats | — |
| Talk with me | the guided chat | 陪我聊聊 |
| draft card | an editable proposed moment inside the chat | — |
| continuation | a draft that adds details to a moment already saved that day | — |
| clothesline, note, clip, page dots | the Diary tab's month line, a diary's tag on it, its candy clip, the scroll cue | — |
| change signal | the "changed since written" notice and Update diary | — |
| Lucky diary | the random past diary candy | 幸运日记 |
| tour, tip, hand, caption | first-time guidance | — |
| styles | Plain, Playful, Poetic, Film | 朴素、俏皮、诗意、电影 |
| shortcut window | the compact computer window opened by ⌥⇧D / Alt+Shift+D | — |
| outbox | local queue of changes waiting to sync | — |

## 9. Open questions for the owner (don't block on them)
- **Provider and models:** decided at the M6 quality check.
