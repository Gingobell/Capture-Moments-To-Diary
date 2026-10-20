# Phase 1 reference evidence

Captured on 2026-10-20 with Playwright 1.64.0 / Chromium 156.0.8078.4 on macOS.

- 80 screenshots: 10 screens × 2 viewports × 2 themes × 2 languages.
- Phone: 390×844 CSS pixels; shortcut window: 450×900; device scale factor 2.
- Reduced motion enabled. Moments, diaries and account avatar are synthetic fixtures; no cloud database or AI provider is called.
- Script requires Nunito 400/600 and Literata 400 to load and rejects broken images. `font-check.json` records a separate successful font probe.
- `computed-styles.json` records actual rendered component styles in both themes. `phase1-version.txt` identifies the unchanged source HTML.
- All 80 images reviewed as contact sheets; full-size Home and Diary samples inspected. This is Phase 1 reference QA, not Flutter screen acceptance (starts M2).
- Dates/times follow capture time and Lucky diary color may vary, matching the source runtime.

Run `.venv/bin/python tools/phase1-screens/capture.py` to regenerate, and `python3 tools/phase1-screens/verify.py` to check completeness. Keep the source HTML unchanged.
