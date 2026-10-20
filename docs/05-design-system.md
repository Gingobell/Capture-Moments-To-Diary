# 05 — Design system: carry Phase 1 over exactly

The owner already approved how Phase 1 looks. Phase 2 must look the same on every platform: same colors, same glass, same type, same spacing, same motion. **Nothing is redesigned and nothing is invented.** This document gives you the exact values, where to find any value not listed, and how to translate CSS into Flutter without drift.

## 1. Where values come from (in this order)
1. **`docs/reference/computed-styles.json`** — the final style of every Phase 1 component, measured in a real browser, per theme (keys like `button.btn-primary`, `div.capture.entry`, `button.note`, with `size`, colors, shadows, radius, font, padding, `first_seen_on` = the screen it appears on). This is the most reliable source.
2. **The tokens below** (also measured, Day and Night).
3. **Brief §10** (intent and rules) and §5 (sizes and timings stated in words).
4. **`capture-moment.html`** CSS and JS for anything else (animations, layout math, SVG icons).

**About the HTML's stylesheet:** since v1.63 every design token is defined once, in one Day block (`:root`) and one Night block (`:root[data-theme="night"]`) at the top, and no rule repeats a property for the same selector. Component rules still build on each other in version order (a later, more specific rule like `.entry .btn-primary` refines `.btn-primary`), so for a component's final look use `computed-styles.json`, or read every rule that applies, not just the first.

**Reference screenshots:** `docs/reference/screens/<phone|window>-<day|night>-<en|zh>-<screen>.png` for home-empty, how-it-works, home, talk-with-me, make-diary-sheet, moments, diary, date-picker, day-view and settings. Re-generate with `tools/phase1-screens/capture.py` whenever `capture-moment.html` changes.

## 2. Tokens (measured)
| Token | Day | Night |
|---|---|---|
| `bg` (page) | `#FBFBF7` | `#F9F9FC` |
| `ink` | `#3D4350` | `#424057` |
| `ink-muted` | `#6A707E` | `#6C6981` |
| `accent` | `#FFEB7A` | `#E7E0FC` |
| `on-accent` | `#4D4210` | `#3D346E` |
| `accent-strong` (indicators only, never text) | `#A88214` | `#7B68C4` |
| `accent-soft` | `#FFF7CF` | `#F1EDFD` |
| `danger` | `#9E4440` | `#9E4440` |
| `line` | `rgba(61,67,80,.09)` | `rgba(66,64,87,.09)` |
| `shadow-dark` / `shadow-light` | `#EBEFF3` / `#FFFFFF` | `#ECECF3` / `#FFFFFF` |
| `gl` (clear glass fill) | `rgba(255,255,255,.62)` | same |
| `glass` (frosted surfaces) | `rgba(255,255,255,.66)` | same |
| `glass-sh` | `rgba(110,130,150,.22)` | `rgba(120,120,170,.22)` |
| `rim` (glass hairline) | `rgba(160,150,110,.16)` | `rgba(130,125,180,.16)` |
| `drop` (glass shadow) | `rgba(120,108,60,.22)` | `rgba(90,84,140,.22)` |
| `halo` (light under glass) | `rgba(255,222,70,.5)` | `rgba(180,160,255,.42)` |
| `corner` (lower-left light) | `rgba(255,222,70,.26)` | `rgba(180,160,255,.26)` |
| `save` (primary glass) | `rgba(255,232,96,.62)` | `rgba(214,202,255,.7)` |
| `save-glow` | `rgba(230,190,40,.4)` | `rgba(140,118,230,.32)` |
| `accent-grad` | `#FFFDF1 → #FFF2C6` (top → bottom) | `#FBFAFF → #ECE7FD` |
| `accent-glow` | `rgba(230,200,90,.45)` | `rgba(150,130,230,.42)` |
| `c1`…`c5` (candies, notes, clips, day dots) | `#F8F04E` `#B3F23C` `#6EF0D8` `#D2B4FF` `#FF9AD6` | `#C7B6FF` `#FFB0D4` `#A8D6FF` `#E3C4FF` `#F6E3A0` |
| `syrup-op` | `.36` | `.62` |
| `sd1`…`sd3` (starter dots) | `#F7D531` `#FF9FB8` `#86CFF5` | `#B9A8F5` `#FFA9CC` `#8EC6F5` |
| `tab-dot` | `#F2C82B` | `#B9A8F5` |
| `tip-glow` | `#FFE24A` | `#C7B6FF` |
| `tip-ring` | `rgba(232,200,60,.75)` | `rgba(160,140,230,.6)` |
| `raised` (pills, buttons) | inset `0 1px 0 #fff`; inset `0 0 0 1px rgba(255,255,255,.8)`; `0 0 0 1px` rim; `0 6px 14px -10px` drop | same with Night rim and drop |
| `inset` (fields, tracks, pressed) | inset `0 0 0 1px` rim; inset `0 2px 4px -2px` drop | same with Night rim and drop |

Auto theme = Night from 6 PM to 6 AM local time, rechecked every minute. The page is flat `bg` in both themes: no gradient or wash behind it (only the lights described in brief §10).

## 3. Type
- Nunito 400 and 600 for interface and moments; Literata 400 for diary text and the Diary month title (line height 1.75). Bundle the font files (Google Fonts, OFL) in `app/assets/fonts/`.
- Fallbacks via `fontFamilyFallback`: sans `PingFang SC`, `Noto Sans SC`; serif `Songti SC`, `Noto Serif SC` (for Chinese).
- Scale 13 / 15 / 17 / 22 / 28 px (Home title 25px, 22px on narrow or short screens), sentence case, no all-caps. Body 17px, line height 1.5.
- Text scaling: respect the system setting up to 1.3×; layouts must not overflow at 1.3×.

## 4. Translating CSS to Flutter (rules, so nothing drifts)
| CSS | Flutter |
|---|---|
| `px` | logical pixels, 1:1 |
| `rgba(r,g,b,a)` | `Color.fromRGBO(r,g,b,a)` |
| `line-height: 22.5px` with `font-size: 15px` | `TextStyle(fontSize: 15, height: 22.5/15)` |
| `border-radius: 999px` / `50%` | `StadiumBorder` / `CircleBorder` (or `BorderRadius.circular(h/2)`) |
| outer `box-shadow: x y blur spread color` | `BoxShadow(offset: Offset(x,y), blurRadius: blur, spreadRadius: spread, color)` — Flutter's `blurRadius` matches CSS; negative spread is fine |
| `0 0 0 1px color` (a ring) | a 1px `Border` (outside the content) or `BoxShadow(spreadRadius: 1)` |
| **inset** `box-shadow` | Flutter has no inset `BoxShadow`. Implement one `InsetShadowPainter` (a `CustomPainter` drawing each inset shadow inside the clipped rounded rect) and use it everywhere `raised`/`inset` need it. Don't drop inset layers: they make the glass bevel. |
| `backdrop-filter: blur(Npx)` | `BackdropFilter(filter: ImageFilter.blur(sigmaX: N, sigmaY: N))` inside a `ClipRRect` with the same radius |
| `filter: blur(Npx)` (candies, syrup, lights) | `ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: N, sigmaY: N))` |
| `linear-gradient(180deg, a, b)` | `LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [a, b])` |
| `radial-gradient(W% H% at X% Y%, c, transparent)` | `RadialGradient` with `center` from X/Y and a `GradientTransform` scaling to the ellipse |
| `transition: 220ms ease-out` | an implicit animation or `AnimationController` with `Duration(milliseconds: 220)`, `Curves.easeOut` |
| `cubic-bezier(a,b,c,d)` | `Cubic(a,b,c,d)` |
| `prefers-reduced-motion` | `MediaQuery.disableAnimationsOf(context)` |
| inline SVG icons | copy the SVG paths into `app/assets/icons/*.svg`, draw with `flutter_svg`, stroke 1.75, round caps and joins |

## 5. Components (Phase 1 class → Flutter widget)
Build these once in `app/lib/ui/` and use them everywhere; never style a one-off. For each, take every value from `computed-styles.json` under the listed keys, then compare with the screenshots.

| Flutter widget | Phase 1 keys in `computed-styles.json` | Seen on |
|---|---|---|
| `GlassSurface` (base: fill, rim, inset bevel, drop, blur) | `div.capture.entry`, `div.sheet`, `div.profile`, `div.pop`, `div.cal-pop` | home, sheets |
| `CaptureCard` | `div.capture.entry`, `textarea.field`, `div.capture-row` | home |
| `PrimaryPill` (lemon/lavender glass) | `button.btn-primary`, `button.ts-make`, `button.send` | home, sheets |
| `GlassPill` (secondary, 40/46px) | `button.btn`, `button.btn.sm`, `button.act`, `button.act.hist`, `button.act.danger.icon` | day view, chat, settings |
| `IconCircleButton` | `button.iconbtn`, `button.back.iconbtn`, `button.tool`, `span.tool-ic` | headers |
| `ProfilePill` | `button.me-pill` | headers |
| `InsetField` | `input.field`, `textarea.field` | home, sheets, settings |
| `StarterChip` | `button.starter`, `div.starters` | home |
| `Jar` (+ candies, syrup, water, lid, straw, shine) | `button.jar-btn`, `span.jar`, `span.lid`, `span.straw`, `span.shine`, `span.syrup`, `span.water`, `span.blob` | home |
| `TodayLine` | `div.today-sum`, `div.ts-row`, `button.ts-link`, `span.ts-lead`, `span.ts-sep`, `button.ts-make` | home |
| `LuckyCandy` | `button.luck-orb`, `span.luck-bub`, `span.orb` | home |
| `UnfinishedList` | `div.unf-list`, `li.unf` | home |
| `TabBar` | `nav.tabbar`, `div.tabbar-in`, `button.tab` | everywhere |
| `PageHeader` | `header.top`, `header.is-home.top`, `h1.hero-lead`, `p.hero-sub`, `p.page-sub` | all tabs |
| `Sheet` (bottom sheet + frost scrim) | `div.sheet`, `div.full.sheet`, `div.scrim`, `div.sheet-head`, `div.sheet-foot` | sheets |
| `ChatBubble` | `div.ai.msg` (and the user's lemon bubble class in the HTML), `div.chat-log`, `div.chat-foot`, `div.chat-input`, `div.chat-tools` | talk-with-me |
| `DraftCard` | chat card classes in the HTML (`.card`, `.card-row`, `.card-link`) | chat after drafting |
| `StyleTray` | `div.styles` and its buttons | make-diary-sheet |
| `GlassCheckbox` list | `ul.checks` | make-diary-sheet |
| `DayGroup` / `MomentRow` / `AddRow` | `section.dayg`, `div.dayg-h`, `button.dayg-d`, `button.moment`, `button.add-row`, `span.plus` | moments |
| `DiaryCard` | `button.dcard`, `div.diary-text`, `div.diary-block` | diary, day view |
| `Clothesline` (rod, notes, clips, dots, fades) | `div.cl`, `div.cl-head`, `h2.cl-title`, `p.cl-n`, `div.cl-sc`, `div.cl-tr`, `path.rope`, `path.rope-s`, `button.note`, `span.paper`, `span.pin` | diary |
| `DatePicker` | `div.cal-pop`, `div.cal-head`, `button.cal-arr`, `button.cal-ttl`, `div.cal-days`, `button.cal-d`, `span.cal-d.now`, `span.cal-d.fut`, `span.cal-dot`, `span.cal-wk` | date-picker |
| `Segmented` (Theme, Language) | `div.seg`, `button.lang-opt` | settings |
| `HowItWorksPop` | `div.pop`, `div.pop-scrim`, `p.close-hint` | how-it-works |
| `Toast`, `TipHand`, `TipCaption` | toast and tip classes in the HTML (`.toast`, `.tip-hand`, `.tip-cap` or as named there) | — |
| text styles | `p.body`, `p.hint`, `span.hint`, `p.privacy`, `p.status`, `p.home-foot`, `label.lbl`, `button.link`, `button.sec-h` | all |

Components that only appear during interaction (toast, tips, the save slip, notes' hover bubble, draft cards) aren't in the JSON: read their CSS in `capture-moment.html` (search the class name; use the last rule) and check against the brief's description.

## 6. Glass: what we do and don't do
- **Do:** frosted glass exactly as Phase 1 — blur + semi-transparent white fill + 1px rim + inset white bevel + soft drop + colored light under it (`halo`, `corner`). It's Flutter's `BackdropFilter` plus the inset painter, and it looks the same on all release platforms.
- **Don't:** use Apple's native **Liquid Glass** (iOS 26) through platform views. It would only work on new iPhones, make iOS look different from Windows and Android, and fight the lemon/lavender candy style. Owner decision (Oct 2026).
- **Maybe later, only with owner approval:** a subtle shader "liquid" highlight on one or two surfaces (the tab bar, the Save moment pill). Not part of any milestone.
- **Performance:** keep the number of blurred layers on screen small (Phase 1 already does). On a device that drops frames (check iPhone and Windows for this release; mid-range Android testing is deferred to M14), switch that surface to the same fill at 93% opacity without blur, through one global switch in `GlassSurface`. Where Flutter exposes the platform's reduce-transparency or high-contrast setting, use the same fallback.

## 7. Motion
Every duration, curve and spring in brief §5 and §10 is kept: views fade and rise 220ms; buttons sink 200–250ms; sheets slide up; the save slip flight 1310ms, candy drop 900ms, jar wiggle 800ms, "+1" 1440ms; candy melt 1s; water fade 0.9s; notes' hover sway (stiffness 0.012, damping 0.955, push 0.008) and swing-in (stiffness 0.045, damping 0.93, start −0.9 rad); tip hand every 2.4s with a 0.55s walk; hover bubble hides after 250ms. Read the exact keyframes and curves in `capture-moment.html` (search `@keyframes`, `transition`, `cubic-bezier`). With reduced motion, follow Phase 1's reduced-motion rules exactly.

## 8. Layout
- One column, max 560px, centered; 8px spacing grid; radii 24–28 (capture card, sheets), 20 (date picker), 16 (fields, cards), 14 (tip captions), full pills, circles.
- Home's three groups (top, middle, bottom) fill the height between header and tab bar; at heights ≤720 the jar is 104px and the page scrolls.
- Phone: 390×844 reference. Shortcut window: 450×900 reference, minimum 380×560.

## 9. Visual check (part of every UI milestone)
1. Run the Flutter screen at 390×844 and 450×900, Day and Night, English and Chinese, with the same seeded data as `tools/phase1-screens/capture.py` (port its seed into a debug-only "Load sample data" action).
2. Screenshot it (`flutter test --update-goldens` for goldens, or the integration test's screenshot) into `docs/progress/screens/<milestone>/`.
3. Compare with the matching `docs/reference/screens/` file side by side. Fix every difference in color, size, spacing, radius, shadow, blur, font size or weight. Fonts render slightly differently between a browser and Flutter; everything else should match.
4. List any difference you couldn't remove in `docs/progress.md` for the owner.
