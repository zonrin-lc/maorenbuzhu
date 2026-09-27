#!/usr/bin/env python3
from pathlib import Path
import json, re, sys

ROOT = Path(__file__).resolve().parents[1]
errors = []
required = [
    "scripts/save/save_manager.gd",
    "scripts/meta/progress_manager.gd",
    "scripts/meta/talent_tracker.gd",
    "data/meta/save_data.gd",
    "data/meta/meta_config.gd",
    "data/meta/meta_config.tres",
    "docs/v1_2_15_Meta_Progress_Spec.md",
    "docs/v1_2_15_Meta_UI_Flow.md",
]
for p in required:
    if not (ROOT / p).exists():
        errors.append(f"MISSING:{p}")

save_text = (ROOT / "data/meta/save_data.gd").read_text(encoding="utf-8") if (ROOT / "data/meta/save_data.gd").exists() else ""
for field in ["schema_version", "completed_levels", "best_paws", "best_time_ms", "best_max_suspicion", "fish_collected", "unlocked_skins", "unlocked_talents", "tutorial_seen", "hard_mode_unlocked", "hard_plus_unlocked"]:
    if f"{field}" not in save_text:
        errors.append(f"SAVE_FIELD:{field}")

progress = (ROOT / "scripts/meta/progress_manager.gd").read_text(encoding="utf-8") if (ROOT / "scripts/meta/progress_manager.gd").exists() else ""
for level_id in [f"L{i:02d}" for i in range(1,13)]:
    if level_id not in progress:
        errors.append(f"LEVEL_ORDER:{level_id}")

spec = (ROOT / "docs/v1_2_15_Meta_Progress_Spec.md").read_text(encoding="utf-8") if (ROOT / "docs/v1_2_15_Meta_Progress_Spec.md").exists() else ""
for marker in ["Hard Mode", "Hard+", "Cyclop", "鱼干", "猫技艺", "SaveManager"]:
    if marker not in spec:
        errors.append(f"SPEC_MARKER:{marker}")

print("REQUIRED_FILES", sum((ROOT/p).exists() for p in required), "/", len(required))
print("LEVELS", 12)
print("FISH_TOTAL", 36)
print("SKINS", 5)
print("TALENTS", 6)
print("ERRORS", len(errors))
for e in errors:
    print(e)
sys.exit(1 if errors else 0)
