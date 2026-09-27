from pathlib import Path
import re, sys
root=Path(__file__).resolve().parents[1]
event_dir=root/'data'/'events'
behavior_dir=root/'data'/'event_behaviors'
ids=[]; errors=[]; event_types=set()
for p in sorted(event_dir.glob('*.tres')):
    s=p.read_text(encoding='utf-8')
    mid=re.search(r'event_id = &"([^"]+)"',s)
    mt=re.search(r'event_type = &"([^"]+)"',s)
    if not mid: errors.append(f'{p.name}: missing event_id'); continue
    if mid.group(1) in ids: errors.append(f'duplicate event_id: {mid.group(1)}')
    ids.append(mid.group(1))
    if not mt: errors.append(f'{p.name}: missing event_type'); continue
    event_types.add(mt.group(1))
    behavior=behavior_dir/(mt.group(1).lower()+'.tres')
    if not behavior.exists(): errors.append(f'{p.name}: missing behavior {behavior.name}')
print(f'events={len(ids)} types={len(event_types)} errors={len(errors)}')
for e in errors: print('ERROR',e)
sys.exit(1 if errors else 0)
