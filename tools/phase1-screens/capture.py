"""Phase 1 reference screenshots.

Renders capture-moment.html (the Phase 1 app, at the repository root) outside claude.ai (a stub stands in for the
artifact runtime: no cloud db, a fake user "Gin", a fake AI) and saves every main
screen in Day and Night, English and Chinese, at phone size (390x844) and
shortcut-window size (450x900).

Setup once:  .venv/bin/python -m pip install -r tools/phase1-screens/requirements.txt
             .venv/bin/python -m playwright install chromium
Run:         .venv/bin/python tools/phase1-screens/capture.py   (from the repository root)
Output:      docs/reference/screens/<size>-<theme>-<lang>-<screen>.png
             docs/reference/computed-styles.json  (the final, cascaded style of every
             component class seen, per theme: the exact values to port)
             docs/reference/phase1-version.txt     (SHA-256 of the HTML these came from)
"""
import asyncio, datetime, hashlib, json, pathlib, time
from playwright.async_api import async_playwright

ROOT = pathlib.Path(__file__).resolve().parents[2]
HTML = ROOT / "capture-moment.html"
APP = HTML.as_uri()
OUT = ROOT / "docs/reference/screens"
STYLES = ROOT / "docs/reference/computed-styles.json"
PROPS = ["color", "background-color", "background-image", "border", "border-radius", "box-shadow",
         "backdrop-filter", "filter", "opacity", "font-family", "font-size", "font-weight", "line-height",
         "letter-spacing", "text-align", "padding", "margin", "gap", "min-height", "transition"]
DUMP = """(props) => { const out = {};
  for (const el of document.querySelectorAll('[class]')) {
    const r = el.getBoundingClientRect(); if (!r.width || !r.height) continue;
    const key = el.tagName.toLowerCase() + '.' + [...el.classList].sort().join('.');
    if (out[key]) continue;
    const s = getComputedStyle(el), o = { size: Math.round(r.width) + 'x' + Math.round(r.height) };
    for (const p of props) { const v = s.getPropertyValue(p); if (v && v !== 'none' && v !== 'normal' && v !== '0px' && v !== 'rgba(0, 0, 0, 0)') o[p] = v; }
    out[key] = o; }
  return out; }"""
STYLE_DATA = {}

STUB = """
window.claude = { use: async (name) => {
  if (name === 'user') return { me: async () => ({ name: 'Gin', firstName: 'Gin', avatarUrl: 'data:image/svg+xml,' + encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" width="80" height="80"><text x="40" y="54" text-anchor="middle" font-family="sans-serif" font-size="40" fill="#3D4350">G</text></svg>') }),
                                id: async () => 'u1', isOwner: async () => false };
  if (name === 'sample') {
    const f = async (turns, o) => { const t = 'Ooh, cozy. What was the best bite? Even just the dish is fine.<same/>';
      if (o && o.onText) o.onText({ text: t }); return { text: t }; };
    f.json = async () => ({ moments: [{ text: 'Had ramen for lunch, the spicy kind.', continues: null, addition: '' }] });
    return f; }
  if (name === 'downloads') return { save: async () => {} };
  return null; } };
"""

def seed(filled: bool, theme: str, lang: str) -> str:
    now = int(time.time() * 1000)
    day = lambda n: (datetime.date.today() - datetime.timedelta(days=n)).isoformat()
    recs = {"settings": {"id": "settings", "type": "settings", "tipsOff": True, "seenAiNote": True,
                         "seenGuide": True, "displayName": "Gin", "updatedAt": now}}
    if filled:
        lines = ["Coffee with Mia, the good kind of tired.", "I just finished the reading for class.",
                 "Now I feel calm after the walk home.", "Rain started right as I left the library.",
                 "Called grandma, she asked about my plants.", "Burned the toast, ate it anyway.",
                 "Presentation went better than I feared.", "Found a quiet seat by the window.",
                 "I want to cook dumplings this weekend."]
        for i, t in enumerate(lines):  # 9 moments today -> 7 candies + syrup
            recs[f"m-t{i}"] = {"id": f"m-t{i}", "type": "moment", "text": t, "date": day(0),
                               "createdAt": now - (9 - i) * 600000, "updatedAt": now, "source": "typed"}
        for n in [1, 2, 3, 5, 8, 12, 20, 33, 40]:  # past days, some in the previous month
            ids = []
            for j, t in enumerate(["Long walk by the bay.", "Tried the new noodle place."]):
                mid = f"m-{n}-{j}"; ids.append(mid)
                recs[mid] = {"id": mid, "type": "moment", "text": t, "date": day(n),
                             "createdAt": now - n * 86400000 + j * 60000, "updatedAt": now, "source": "typed"}
            recs["d-" + day(n)] = {"id": "d-" + day(n), "type": "diary", "date": day(n), "style": "plain",
                                   "text": "I took a long walk by the bay. Later I tried the new noodle place, and it was worth the wait.",
                                   "sourceMomentIds": ids, "generatedAt": now, "updatedAt": now}
        recs["q-1"] = {"id": "q-1", "type": "draft", "kind": "quick", "text": "Half a thought about the rain",
                       "date": day(1), "createdAt": now, "updatedAt": now}
    store = json.dumps(json.dumps({"records": recs, "pending": {}}))
    return (f"localStorage.clear();localStorage.setItem('cmd.v1.device',{store});"
            f"localStorage.setItem('cmd.v1.lastScope','\"device\"');"
            f"localStorage.setItem('cmd.theme','{theme}');localStorage.setItem('cmd.lang','{lang}');")

async def click(pg, sel, wait=900):
    await pg.locator(sel).locator("visible=true").first.click(timeout=5000); await pg.wait_for_timeout(wait)

async def shoot(pg, name, size, theme, lang):
    broken = await pg.locator('img').evaluate_all('(images) => images.filter(i => !i.complete || i.naturalWidth === 0).length')
    if broken:
        raise RuntimeError(f"Broken image in {size}/{theme}/{lang}/{name}")
    await pg.screenshot(path=str(OUT / f"{size}-{theme}-{lang}-{name}.png"))
    if size == "phone" and lang == "en":
        seen = STYLE_DATA.setdefault(theme, {})
        for k, v in (await pg.evaluate(DUMP, PROPS)).items():
            seen.setdefault(k, {"first_seen_on": name, **v})

async def run(b, size, w, h, theme, lang):
    ctx = await b.new_context(viewport={"width": w, "height": h}, device_scale_factor=2,
                              reduced_motion="reduce")
    pg = await ctx.new_page(); await pg.add_init_script(STUB)
    async def fresh(filled):
        await pg.goto(APP); await pg.evaluate(seed(filled, theme, lang)); await pg.reload()
        await pg.evaluate("document.fonts.ready")
        loaded = await pg.evaluate("""async () => {
          const checks = await Promise.all(['400 17px Nunito', '600 17px Nunito',
            '400 17px Literata'].map(spec => document.fonts.load(spec)));
          return checks.every(faces => faces.length > 0 && faces.every(f => f.status === 'loaded'));
        }""")
        if not loaded:
            raise RuntimeError("Reference fonts did not load; refusing fallback-font screenshots")
        await pg.wait_for_timeout(1500)
    s = lambda name: shoot(pg, name, size, theme, lang)
    await fresh(False); await s("home-empty")
    await click(pg, "[data-act=jar]"); await s("how-it-works")
    await fresh(True); await s("home")
    await click(pg, "[data-act=help-words]"); await s("talk-with-me")
    await fresh(True); await click(pg, "[data-act=make-diary]"); await s("make-diary-sheet")
    await fresh(True); await click(pg, "[data-act=tab][data-view=moments]"); await s("moments")
    await click(pg, "[data-act=tab][data-view=diary]"); await s("diary")
    await click(pg, "[data-act=cal-toggle]"); await s("date-picker")
    await fresh(True); await click(pg, "[data-act=tab][data-view=diary]")
    await click(pg, "[data-act=open-day]"); await s("day-view")
    await fresh(True); await click(pg, "[data-act=settings]"); await s("settings")
    await ctx.close()

async def main():
    OUT.mkdir(parents=True, exist_ok=True)
    async with async_playwright() as p:
        b = await p.chromium.launch()
        for size, w, h in [("phone", 390, 844), ("window", 450, 900)]:
            for theme in ["day", "night"]:
                for lang in ["en", "zh"]:
                    await run(b, size, w, h, theme, lang)
        await b.close()
    STYLES.write_text(json.dumps(STYLE_DATA, indent=1, sort_keys=True))
    (ROOT / "docs/reference/phase1-version.txt").write_text(hashlib.sha256(HTML.read_bytes()).hexdigest() + "\n")
    print(f"Saved {len(list(OUT.glob('*.png')))} screenshots to {OUT}")

asyncio.run(main())
