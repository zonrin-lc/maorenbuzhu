from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
required = [
    "project.godot",
    "scenes/flow/main_menu.tscn",
    "scenes/flow/chapter_select.tscn",
    "scenes/flow/level_select.tscn",
    "scripts/flow/main_menu.gd",
    "scripts/flow/chapter_select.gd",
    "scripts/flow/level_select.gd",
    "scripts/flow/app_flow.gd",
    "scripts/flow/global_flow_memory.gd",
    "scripts/flow/save_data.gd",
    "scripts/flow/save_manager.gd",
    "scripts/flow/progress_manager.gd",
    "data/flow/level_catalog.gd",
    "scenes/flow/settings_menu.tscn",
    "scripts/flow/settings_menu.gd",
]
errors = []
for p in required:
    if not (ROOT / p).exists(): errors.append(f"missing: {p}")
cat = (ROOT / "data/flow/level_catalog.gd").read_text(encoding="utf-8")
levels = re.findall(r'"L\d\d"', cat)
if len(levels) < 12: errors.append("level catalog < 12")
for s in ["ChapterSelect", "LevelSelect", "Continue", "scene_path"]:
    texts = "\n".join((ROOT / p).read_text(encoding="utf-8") for p in required if (ROOT / p).exists())
    if s not in texts: errors.append(f"missing keyword: {s}")
print(f"FILES={len(required)}")
print(f"LEVEL_IDS={len(levels)}")
print(f"ERRORS={len(errors)}")
for e in errors: print(e)
raise SystemExit(1 if errors else 0)
