from pathlib import Path
import re, sys

ROOT = Path(__file__).resolve().parents[1]
errors = []
checks = []

# 1) All level resources and scene paths
levels = sorted((ROOT / 'data' / 'levels').glob('**/L*.tres'))
expected = [f'L{i:02d}' for i in range(1,13)]
found = []
for p in levels:
    s = p.read_text(encoding='utf-8')
    m = re.search(r'^level_id\s*=\s*&"([^"]+)"', s, re.M)
    if m: found.append(m.group(1))
    sp = re.search(r'^scene_path\s*=\s*"([^"]+)"', s, re.M)
    np = re.search(r'^next_scene_path\s*=\s*"([^"]*)"', s, re.M)
    if sp and sp.group(1) and not (ROOT / sp.group(1).replace('res://','')).exists():
        errors.append(f'{p.name}: missing scene_path {sp.group(1)}')
    if np and np.group(1) and not (ROOT / np.group(1).replace('res://','')).exists():
        errors.append(f'{p.name}: missing next_scene_path {np.group(1)}')
checks.append(('12 level data ids', set(found) == set(expected)))

# 2) Score resources for all levels
for lid in expected:
    p = ROOT / 'data' / 'score' / f'{lid}_Score.tres'
    if not p.exists(): errors.append(f'{lid}: missing score resource')
checks.append(('12 score resources', not any('missing score resource' in e for e in errors)))

# 3) Route resources for all levels
for lid in expected:
    p = ROOT / 'data' / 'routes' / f'{lid}_Ninja_Main.tres'
    if not p.exists(): errors.append(f'{lid}: missing route resource')
checks.append(('12 route resources', not any('missing route resource' in e for e in errors)))

# 4) Result/settlement canonical paths
for rel in [
    'scenes/settlement/izakaya_settlement.tscn',
    'scripts/settlement/settlement_context.gd',
    'data/event_behaviors/passive.tres',
]:
    if not (ROOT / rel).exists(): errors.append(f'missing release file: {rel}')
checks.append(('canonical settlement + passive behavior', all((ROOT/r).exists() for r in [
    'scenes/settlement/izakaya_settlement.tscn','scripts/settlement/settlement_context.gd','data/event_behaviors/passive.tres'])))

# 5) No duplicated exact L10 blocker branch in UnifiedLevelManager
p = ROOT / 'scripts/gameplay/unified_level_manager.gd'
s = p.read_text(encoding='utf-8')
count = s.count('if level_data != null and level_data.level_id == &"L10":')
# There are legitimate L10 branches throughout the file; specifically inspect the blocker function region.
start = s.find('func is_ninja_at_blocking_event')
end = s.find('func _l04_blocking_event', start)
block = s[start:end]
dup = block.count('if level_data != null and level_data.level_id == &"L10":')
if dup != 1:
    errors.append(f'is_ninja_at_blocking_event: expected 1 L10 branch, found {dup}')
checks.append(('single L10 blocker branch', dup == 1))

# 6) Canonical ResultFlow scene alignment
app_flow = (ROOT / 'scripts/flow/app_flow.gd').read_text(encoding='utf-8')
result_flow = (ROOT / 'scripts/flow/result_flow.gd').read_text(encoding='utf-8')
canonical = 'res://scenes/settlement/izakaya_settlement.tscn'
if 'const RESULT := "'+canonical+'"' not in app_flow: errors.append('AppFlow.RESULT not canonical settlement')
if 'const RESULT_SCENE := "'+canonical+'"' not in result_flow: errors.append('ResultFlow.RESULT_SCENE not canonical settlement')
checks.append(('flow result constants aligned', ('const RESULT := "'+canonical+'"' in app_flow) and ('const RESULT_SCENE := "'+canonical+'"' in result_flow)))

# 7) No accidental stale flow stub in gameplay manager
if 'result_stub.tscn' in s:
    errors.append('UnifiedLevelManager still references result_stub.tscn')
checks.append(('gameplay manager free of result stub', 'result_stub.tscn' not in s))

# 8) Compile-like sanity for project Python QA tools
pytools = sorted((ROOT/'tools').glob('*.py'))
import py_compile
for p in pytools:
    try: py_compile.compile(str(p), doraise=True)
    except Exception as exc: errors.append(f'{p.name}: python compile error: {exc}')
checks.append(('QA Python tools compile', not any('python compile error' in e for e in errors)))

# 9) Event asset hygiene: every level-referenced EventPointData exists; no orphan event resources remain.
referenced_events = set()
for level_file in (ROOT/'data'/'levels').glob('*/*.tres'):
    level_text = level_file.read_text(encoding='utf-8')
    referenced_events.update(re.findall(r'path=\"res://data/events/([^\"]+\.tres)\"', level_text))
all_events = {p.name for p in (ROOT/'data'/'events').glob('*.tres')}
missing_events = sorted(referenced_events - all_events)
orphan_events = sorted(all_events - referenced_events)
for name in missing_events:
    errors.append(f'missing referenced event: {name}')
for name in orphan_events:
    errors.append(f'orphan event resource: {name}')
checks.append(('referenced event resources clean', not missing_events and not orphan_events))

print('RELEASE_V1_5')
print(f'levels={len(found)} expected=12')
print(f'event_behavior_passive={"PASS" if (ROOT/"data/event_behaviors/passive.tres").exists() else "FAIL"}')
print(f'referenced_events={len(referenced_events)} orphan_events={len(orphan_events)}')
print(f'errors={len(errors)}')
for name, ok in checks:
    print(('PASS' if ok else 'FAIL') + ' ' + name)
for e in errors:
    print('ERROR', e)
sys.exit(1 if errors else 0)
