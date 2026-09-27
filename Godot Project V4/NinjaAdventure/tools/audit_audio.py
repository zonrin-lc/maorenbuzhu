import csv
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
manifest = ROOT / 'tools' / 'audio_manifest.csv'
errors = []
rows = list(csv.DictReader(manifest.open(encoding='utf-8')))
ids = [r['AudioID'] for r in rows]
if len(ids) != len(set(ids)):
    errors.append('DUPLICATE_AUDIO_ID')
for r in rows:
    if not r['AudioID'] or not r['Kind'] or not r['Bus']:
        errors.append(f"INVALID_ROW:{r}")
required_buses = {'Music','SFX','Voice','UI','Ambient'}
seen = {r['Bus'] for r in rows}
for bus in sorted(required_buses - seen):
    errors.append(f'MISSING_BUS:{bus}')
print(f'AUDIO_ROWS={len(rows)}')
print(f'BUSES={len(seen & required_buses)}/{len(required_buses)}')
print(f'ERRORS={len(errors)}')
for e in errors:
    print(e)
raise SystemExit(1 if errors else 0)
