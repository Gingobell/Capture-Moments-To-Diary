# Decisions log

| Date | Question | Choice | Why |
|---|---|---|---|
| 2026-10-20 | Application identity | Owner chose `com.gingobell.capturemoment`. | Stable identity for the app and platform configuration. |
| 2026-10-20 | Course release platforms | Owner approved macOS, iOS and Windows; Android deferred to M14. | Current testers primarily use Apple devices or Windows; defer Android setup and validation until needed. |
| 2026-10-20 | Docker inspection target | Use explicit local `desktop-linux` context; preserve the default remote context. | This project needs local Supabase without affecting existing remote projects. |
| 2026-10-20 | Screenshot tooling environment | Use Homebrew Python 3.13 with project `.venv`; invoke `.venv/bin/python` explicitly. Ignore `.venv/` in Git during M0. | Isolate screenshot dependencies and avoid ambiguity with Xcode Python. |
| 2026-10-20 | Repository visibility | Owner approved public repository; GitHub Actions enabled, verified through repository settings. | Supersedes the original private-repository requirement. |
| 2026-10-20 | M0 bootstrap | Empty Day-colored widget, no Material demo or backend initialization; product UI begins at M2. | Keep M0 strictly scaffold-only. |
| 2026-10-20 | App identity | Correct Flutter-generated camel-case identifier to `com.gingobell.capturemoment`; leave developer team unset. | Match owner identity exactly; signing setup is deferred. |
| 2026-10-20 | Git transport | Existing GitHub SSH identity verified; use SSH origin. | No extra CLI login or new credentials needed. |
| 2026-10-20 | Bootstrap commit order | Group repository/docs/reference tasks with scaffold validation for the first commit. | There is no Flutter app to analyze before scaffold creation; all subsequent commits run analyze and tests. |

## M0 direct dependency pins

```yaml
name: capture_moment
description: "Capture small moments and bring them together into a diary."
publish_to: 'none'
version: 0.1.0+1

environment:
  sdk: 3.13.5

dependencies:
  app_links: 7.2.2
  connectivity_plus: 7.3.2
  drift: 2.35.2
  file_selector: 1.1.0
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_riverpod: 3.4.3
  flutter_svg: 2.3.0
  go_router: 18.1.1
  google_sign_in: 7.2.0
  hotkey_manager: 0.2.3
  http: 1.6.0
  intl: 0.20.3
  launch_at_startup: 0.5.1
  screen_retriever: 0.3.0
  share_plus: 12.0.2
  sign_in_with_apple: 8.2.0
  speech_to_text: 7.5.0
  sqlite3_flutter_libs: 0.6.0+eol
  supabase_flutter: 2.18.3
  tray_manager: 0.8.0
  uuid: 4.6.0
  window_manager: 0.2.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: 6.0.0
  drift_dev: 2.35.1
  build_runner: 2.16.2

flutter:
  uses-material-design: false
```
| 2026-10-20 | Reference avatar fixture | Supply a synthetic G avatar in the runtime stub and reject broken images; explicitly load and check all reference fonts. | The supplied stub omitted avatarUrl, creating broken-image icons; Phase 1 HTML remains unchanged. |
| 2026-10-20 | Course PDF publication | Keep the original PDF local and git-ignored. | It includes private conversation references; product implementation does not require publishing the submission. |
