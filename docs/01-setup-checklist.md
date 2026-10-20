# 01 — Setup checklist (owner only)

These steps need a person: they involve accounts, payment, signing identities or secrets. An AI building the app must not attempt them; when one is missing it stops and names the step. Tick each box and fill in the values table at the end (never paste secret keys into this file; the table only says where each secret is stored).

Steps are grouped by the milestone that first needs them, so you can start building before everything is done.

## Before M0 (start)
- [x] **Tools on the Mac (verified 2026-10-20; Android deferred):** Xcode (from the App Store, then open it once to install components), Homebrew, Flutter (stable channel; run `flutter doctor` until macOS and iOS show no errors), Docker Desktop (for the local Supabase stack), Supabase CLI (`brew install supabase/tap/supabase`), Deno (`brew install deno`), Python 3 with Playwright (`pip install playwright && python -m playwright install chromium`, for the Phase 1 reference screenshots), Git, and Codex.
- [x] **GitHub:** public `Gingobell/Capture-Moments-To-Diary` (owner approved 2026-10-20, superseding private-repository requirement). Actions settings verified: all actions and reusable workflows allowed; default token read-only. The repository is the `CS6983/project1/` folder itself (it already holds the brief and Phase 1). Windows builds will run on GitHub Actions (a Mac can't build Windows apps), so Actions must be enabled.
- [x] **App identifier:** `com.gingobell.capturemoment` (confirmed by the owner on 2026-10-20). Used for iOS, macOS and sign-in redirects; Android later.

## Before M1 (backend)
- [x] **Supabase project:** owner created `capture-moment`; CLI verified `ACTIVE_HEALTHY` on 2026-10-20. Project ref: `xzefyvrgkrzgtqfvzqmt`; region: `us-east-1`; PostgreSQL 17. Owner reported following the creation settings: Data API enabled, automatic table exposure disabled, automatic RLS enabled (dashboard settings not independently verified).
- [x] Owner completed `supabase login`; linked this repository with `supabase link --project-ref xzefyvrgkrzgtqfvzqmt` on 2026-10-20. M1 migration `20261021000000` deployed on 2026-10-20 after explicit owner approval and all four CI checks passed; no seed uploaded. App public-key configuration is still pending before app sign-in integration; no service-role key is needed for this setup.

## Before M6 (AI)
- [ ] **AI provider key.** Recommended: **Google Gemini API** with **billing turned on** (Google AI Studio → Get API key → set up billing). On Google's free tier, prompts may be used to improve Google's products, which isn't acceptable for private diaries; the paid tier doesn't, and its cheapest models cost fractions of a cent per call. Optional second key: DeepSeek (very cheap and strong in Chinese, but data is processed in China; decide after the quality check in M6).
- [ ] **Spending guard at the provider:** a monthly budget with alerts (Google Cloud Billing → Budgets & alerts), e.g. US$10.
- [ ] Store keys as Supabase secrets (the AI will tell you the exact command, e.g. `supabase secrets set AI_API_KEY=...`). Type it yourself; don't paste keys into chat.

## Before M2 (sign-in)
- [ ] **Apple Developer Program** (US$99/year), needed for Sign in with Apple, TestFlight and a notarized Mac app. In the developer portal: enable Sign in with Apple for the App ID; create a Services ID and a key for Supabase's Apple provider; enter them in Supabase → Authentication → Providers → Apple.
- [ ] **Google sign-in:** in Google Cloud Console create an OAuth consent screen (External, testing mode, add tester emails) and OAuth client IDs: Web (for Supabase), iOS, macOS (uses the iOS type). Android OAuth configuration is deferred to M14. Enter the Web client ID and secret in Supabase → Providers → Google.
- [ ] **Email sign-in:** Supabase → Authentication → Email: turn on email OTP. For more than a handful of testers, connect your own SMTP sender (e.g. Resend, free tier), because Supabase's built-in sender is heavily rate limited.
- [ ] **Redirect URL:** add `capturemoment://login-callback` (or the scheme you pick) under Supabase → Authentication → URL Configuration.

## Before M11 (iOS) and M12 (Windows)
- [ ] **iOS:** in App Store Connect create the app record (same identifier) so TestFlight builds can be uploaded; add testers by email.
- [ ] **Deferred to M14 — Android (not a current release prerequisite):** install Android Studio/SDK, configure Android OAuth, and create an upload keystore (the AI gives the `keytool` command; you keep the file and passwords outside the repo). Optional: Google Play Console (US$25 once) for internal testing; otherwise testers install the APK directly.
- [ ] **macOS distribution:** a Developer ID certificate in Xcode for notarization, so testers can open the app without a warning.
- [ ] **Windows:** nothing required. Unsigned builds show a SmartScreen warning ("More info → Run anyway"); a code-signing certificate is optional and costs money.

## Before testers (M13)
- [ ] **Privacy policy** page at a public URL (GitHub Pages is fine). The AI drafts it from `docs/02-backend-spec.md`; you review and publish. App Store review requires it.
- [ ] **Phase 1 export:** say "update" in the Phase 1 project so the artifact gains its export button (see M8), then tell Phase 1 testers how to move.

## Values (no secrets here)
| Item | Value or where it's kept |
|---|---|
| App identifier | `com.gingobell.capturemoment` |
| Supabase project URL | https://xzefyvrgkrzgtqfvzqmt.supabase.co |
| Supabase anon key | Pending app configuration; intended location: git-ignored `app/env/dev.json` |
| Supabase service role key | Supabase dashboard only |
| AI provider and key | Supabase secret `AI_API_KEY` |
| Apple Team ID | |
| Google OAuth Web client ID | |
| Redirect scheme | |
| Privacy policy URL | |
