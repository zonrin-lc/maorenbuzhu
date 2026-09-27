from __future__ import annotations
import csv, json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
manifest = ROOT / "data/input/input_action_manifest.csv"
defaults = ROOT / "data/input/default_bindings.json"
required = [
    "move_up","move_down","move_left","move_right",
    "sprint","interact","carry","meow","emote","jump",
    "pause","retry","confirm","cancel"
]
rows = list(csv.DictReader(manifest.open(encoding="utf-8")))
data = json.loads(defaults.read_text(encoding="utf-8"))
errors = []
ids = {r["action"] for r in rows}
for action in required:
    if action not in ids:
        errors.append(f"manifest_missing:{action}")
    if action not in data:
        errors.append(f"defaults_missing:{action}")
for r in rows:
    if not r["keyboard_default"] or not r["gamepad_default"]:
        errors.append(f"binding_missing:{r['action']}")
if not (ROOT / "scenes/ui/rebind_panel.tscn").exists():
    errors.append("rebind_panel_missing")
if not (ROOT / "scripts/input/pause_controller.gd").exists():
    errors.append("pause_controller_missing")
print(f"ACTIONS={len(rows)}")
print(f"ERRORS={len(errors)}")
for e in errors:
    print(e)
raise SystemExit(1 if errors else 0)
