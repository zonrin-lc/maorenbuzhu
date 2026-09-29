"""Input contract audit.

Single source of truth = project.godot [input]. This audit cross-checks three
artifacts against it so drift in any one is caught:

  1. project.godot            [input]  (authoritative)
  2. tools/input_action_manifest.csv   (generated, documentation)
  3. data/input/default_bindings.json  (generated, documentation)

Also asserts the rebind UI/runtime files exist and that the rebindable action
list in RebindManager.gd matches the actions the CSV claims to document.
"""
from __future__ import annotations
import csv, json, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from gen_input_manifest import parse_action_events, _input_section, REBINDABLE  # noqa: E402

manifest = ROOT / "tools/input_action_manifest.csv"
defaults = ROOT / "data/input/default_bindings.json"
rebind_src = ROOT / "scripts/input/rebind_manager.gd"
errors: list[str] = []

REQUIRED = REBINDABLE + ["confirm", "cancel"]

# 1) RebindManager 是可重绑 action 的唯一事实源。
src = rebind_src.read_text(encoding="utf-8")
m = re.search(r"const REBINDABLE_ACTIONS\s*:=\s*\[(.*?)\]", src, re.S)
declared: list[str] = []
if m:
    declared = re.findall(r'"([^"]+)"', m.group(1))
if sorted(declared) != sorted(REBINDABLE):
    errors.append(f"rebindable_list_drift: RebindManager={sorted(declared)} generator={sorted(REBINDABLE)}")

# 2) CSV（跳过以 # 开头的说明行）
rows = list(csv.DictReader(manifest.open(encoding="utf-8")))
by_id = {r["action"]: r for r in rows if not str(r.get("action", "")).startswith("#")}

# 3) default_bindings.json
data = json.loads(defaults.read_text(encoding="utf-8"))

section = _input_section()
for action in REQUIRED:
    if action not in by_id:
        errors.append(f"manifest_missing:{action}")
        continue
    if action not in data:
        errors.append(f"defaults_missing:{action}")

    row = by_id[action]
    kbd = str(row.get("keyboard_default", "")).strip()
    pad = str(row.get("gamepad_default", "")).strip()
    if not kbd or not pad:
        errors.append(f"binding_empty:{action}")
        continue
    if kbd == "—" and pad == "—":
        errors.append(f"binding_both_empty:{action}")

    # 4) 关键漂移检测：CSV 必须与 project.godot 的真实绑定一致。
    real_k, real_p = parse_action_events(section, action)
    if not real_k and not real_p:
        errors.append(f"not_in_project_godot:{action}")
        continue
    # CSV 的键鼠字段应包含 project.godot 里每个键位（用主字母做包含判断，容忍格式差异）。
    for key in real_k:
        base = key.split(" - ")[0]
        if base not in kbd:
            errors.append(f"csv_key_drift:{action}:{base} not in '{kbd}'")
    real_pad_buttons = [b for b in real_p if b.startswith("button_")]
    for b in real_pad_buttons:
        if b not in pad:
            errors.append(f"csv_pad_drift:{action}:{b} not in '{pad}'")

# 文件存在性
if not (ROOT / "scenes/ui/rebind_panel.tscn").exists():
    errors.append("rebind_panel_missing")
if not (ROOT / "scripts/input/pause_controller.gd").exists():
    errors.append("pause_controller_missing")

# RebindManager 需提供持久化入口（本次修复引入）
for needle in ["apply_persisted_bindings", "save_bindings", "restore_factory_defaults", "snapshot_factory_defaults"]:
    if needle not in src:
        errors.append(f"rebind_persistence_missing:{needle}")

print(f"ACTIONS={len(by_id)}")
print(f"ERRORS={len(errors)}")
for e in errors:
    print(e)
raise SystemExit(1 if errors else 0)
