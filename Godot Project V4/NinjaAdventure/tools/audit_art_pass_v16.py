from pathlib import Path
from PIL import Image
import re

ROOT = Path(__file__).resolve().parents[1]
ART = ROOT / 'assets' / 'scene_art'
MANAGER = ROOT / 'scripts' / 'gameplay' / 'unified_level_manager.gd'

EXPECTED = {
    'chapter_village_bg.png': (1104, 490),
    'chapter_dock_bg.png': (1104, 490),
    'chapter_castle_bg.png': (1104, 490),
}

errors=[]
for name, size in EXPECTED.items():
    p=ART/name
    if not p.exists(): errors.append(f'missing {name}'); continue
    try:
        with Image.open(p) as im:
            if im.size != size: errors.append(f'{name} size={im.size} expected={size}')
            if im.mode not in ('RGBA','RGB'): errors.append(f'{name} mode={im.mode}')
    except Exception as exc:
        errors.append(f'{name} unreadable: {exc}')

text=MANAGER.read_text(encoding='utf-8')
for name in EXPECTED:
    if f'res://assets/scene_art/{name}' not in text: errors.append(f'manager missing reference {name}')
if 'geometry.visible = false' not in text: errors.append('whitebox geometry is not hidden')
for path in ['assets/props/scroll.png','assets/props/crate.png','assets/props/dynamite_crate.png','assets/props/caltrop.png']:
    if f'res://{path}' not in text: errors.append(f'manager missing prop reference {path}')

scene_count=0
for p in (ROOT/'scenes'/'levels').rglob('*.tscn'):
    if re.search(r'/L\d{2}_[^/]+\.tscn$', str(p)):
        scene_count += 1
if scene_count != 12: errors.append(f'level scene count={scene_count} expected=12')

print(f'ART_PASS_LEVELS=12')
print(f'ART_BG_ASSETS={len(EXPECTED)}')
print(f'ERRORS={len(errors)}')
for e in errors: print('ERROR:', e)
raise SystemExit(1 if errors else 0)
