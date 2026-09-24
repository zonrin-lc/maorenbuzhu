#!/usr/bin/env python3
from __future__ import annotations
import csv, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MATRIX = ROOT / 'data_templates' / 'level_authoring_matrix.csv'
KNOWN = {'TRIPWIRE','GUARD','WATERGAP','BRIDGE','DOG','POISON','CALTROP','DYNAMITE','CLIFF','BOSS_CRANE','BOSS_GOURD','BOSS_CALTROP'}
FAILS = {'FAIL_TOO_LATE','FAIL_WRONG_ORDER','FAIL_SUSPICION','FAIL_NINJA_DEATH','FAIL_BOSS_FINISHER','FAIL_ROUTE_BLOCKED','FAIL_TIMEOUT'}

errors=[]
rows=list(csv.DictReader(MATRIX.open(encoding='utf-8')))
seen=set()
for r in rows:
    lid=r['level_id']
    if lid in seen: errors.append(f'duplicate level_id: {lid}')
    seen.add(lid)
    if not re.fullmatch(r'L\d{2}', lid): errors.append(f'bad level_id: {lid}')
    for key in ('title','chapter','lesson','main_route','primary_risk','variant_b'):
        if not r[key].strip(): errors.append(f'{lid}: empty {key}')
    for key in ('critical_count','standard_count','optional_count'):
        try: n=int(r[key])
        except ValueError: errors.append(f'{lid}: bad {key}'); continue
        if n<0: errors.append(f'{lid}: negative {key}')
    if int(r['critical_count']) == 0:
        errors.append(f'{lid}: no CRITICAL event')
    if r['primary_risk'] not in {'时间','怀疑','顺序','资源运输','狗的时序','状态切换','多线程','连锁','Boss窗口'}:
        errors.append(f'{lid}: unsupported risk tag {r["primary_risk"]}')

expected={f'L{i:02d}' for i in range(1,13)}
missing=sorted(expected-seen)
extra=sorted(seen-expected)
if missing: errors.append('missing levels: ' + ','.join(missing))
if extra: errors.append('unexpected levels: ' + ','.join(extra))

print(f'LEVELS={len(rows)}')
print(f'EXPECTED=12')
print(f'ERRORS={len(errors)}')
for e in errors: print('ERROR:', e)
sys.exit(1 if errors else 0)
