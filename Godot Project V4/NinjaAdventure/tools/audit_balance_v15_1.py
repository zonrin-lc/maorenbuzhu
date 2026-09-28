#!/usr/bin/env python3
import glob, math, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path):
    return path.read_text(encoding='utf-8')


def scalar(text, key, default=0.0):
    m = re.search(rf'^{re.escape(key)}\s*=\s*([-\d.]+)', text, re.M)
    return float(m.group(1)) if m else default


def points(text):
    return [(float(x), float(y)) for x,y in re.findall(r'Vector2\(([-\d.]+),\s*([-\d.]+)\)', text)]

errors=[]
rows=[]
for level_file in sorted((ROOT/'data'/'levels').glob('*/*.tres')):
    s=read(level_file)
    m=re.search(r'level_id\s*=\s*&"([^"]+)"',s)
    if not m: continue
    lid=m.group(1)
    target=scalar(s,'target_time')
    route_path=ROOT/'data'/'routes'/f'{lid}_Ninja_Main.tres'
    if not route_path.exists():
        errors.append(f'{lid}: missing route')
        continue
    rs=read(route_path)
    pts=points(rs)
    speed=scalar(rs,'move_speed')
    dist=sum(math.hypot(pts[i+1][0]-pts[i][0],pts[i+1][1]-pts[i][1]) for i in range(len(pts)-1))
    route_seconds=dist/max(speed,1)
    ratio=target/max(route_seconds,1)
    referenced_names = set(re.findall(r'path="res://data/events/([^"]+\.tres)"', s))
    event_count = len(referenced_names)
    rows.append((lid,target,speed,route_seconds,ratio,event_count))

all_event_files = {p.name for p in (ROOT/'data'/'events').glob('*.tres')}
referenced_event_files = set()
for level_file in (ROOT/'data'/'levels').glob('*/*.tres'):
    text = read(level_file)
    referenced_event_files.update(re.findall(r'path="res://data/events/([^"]+\.tres)"', text))
orphan_events = sorted(all_event_files - referenced_event_files)

for lid,target,speed,route_seconds,ratio,count in rows:
    print(f'{lid}: target={target:.0f}s route={route_seconds:.1f}s ratio={ratio:.2f} speed={speed:.0f} events={count}')
print(f'orphan_event_files={len(orphan_events)}')
if orphan_events:
    print('ORPHAN', ','.join(orphan_events))

# The tool is deliberately descriptive rather than prescriptive; broad ratios are review flags,
# not automatic balance failures, because cat-routing and scripted pauses are playtest variables.
if orphan_events:
    errors.append('orphan event resources remain')

for lid,target,speed,route_seconds,ratio,count in rows:
    if target <= 0:
        errors.append(f'{lid}: invalid target_time')
    if speed <= 0:
        errors.append(f'{lid}: invalid move_speed')

print(f'BALANCE_AUDIT: {"PASS" if not errors else "FAIL"}')
if errors:
    print('\n'.join(errors))
    sys.exit(1)
