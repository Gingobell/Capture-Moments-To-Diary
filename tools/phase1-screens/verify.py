"""Check the committed reference set without browser or network dependencies."""
import hashlib
import itertools
import json
import pathlib
import struct

ROOT = pathlib.Path(__file__).resolve().parents[2]
REFERENCE = ROOT / 'docs/reference'
SCREENS = ('home-empty', 'how-it-works', 'home', 'talk-with-me',
           'make-diary-sheet', 'moments', 'diary', 'date-picker', 'day-view', 'settings')
expected = {f'{size}-{theme}-{lang}-{screen}.png'
            for size, theme, lang, screen in itertools.product(
                ('phone', 'window'), ('day', 'night'), ('en', 'zh'), SCREENS)}
actual = {p.name for p in (REFERENCE / 'screens').glob('*.png')}
assert actual == expected, f'Reference names differ: {actual ^ expected}'
for name in expected:
    data = (REFERENCE / 'screens' / name).read_bytes()
    assert data[:8] == b'\x89PNG\r\n\x1a\n', name
    size = struct.unpack('>II', data[16:24])
    assert size == ((780, 1688) if name.startswith('phone-') else (900, 1800)), name
assert (REFERENCE / 'phase1-version.txt').read_text().strip() == hashlib.sha256(
    (ROOT / 'capture-moment.html').read_bytes()).hexdigest(), 'Phase 1 reference is stale'
styles = json.loads((REFERENCE / 'computed-styles.json').read_text())
assert all(styles.get(theme) for theme in ('day', 'night')), 'Missing theme styles'
fonts = json.loads((REFERENCE / 'font-check.json').read_text())
for family in ('Nunito', 'Literata'):
    assert any(f['family'] == family and f['status'] == 'loaded' for f in fonts), family
print('PASS: 80 reference images, sizes, source SHA, both themes and font evidence')
