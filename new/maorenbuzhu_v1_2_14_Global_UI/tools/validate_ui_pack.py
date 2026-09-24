from pathlib import Path
import csv

ROOT = Path(__file__).resolve().parents[1]
errors = []
required = [
    ROOT / "docs/v1_2_14_Global_UI_HUD_Spec.md",
    ROOT / "scripts/ui/ui_manager.gd",
    ROOT / "scripts/ui/suspicion_eye.gd",
    ROOT / "scripts/ui/ninja_locator.gd",
    ROOT / "scripts/ui/interaction_prompt.gd",
    ROOT / "scripts/ui/tutorial_director.gd",
    ROOT / "scripts/ui/failure_diagnostic.gd",
    ROOT / "scripts/ui/result_panel.gd",
    ROOT / "scenes/ui/global_ui.tscn",
    ROOT / "data/tutorial/tutorial_data.gd",
]
for p in required:
    if not p.exists():
        errors.append(f"MISSING {p.relative_to(ROOT)}")

manifest = ROOT / "data/tutorial/tutorial_manifest.csv"
seen = set()
with manifest.open(encoding="utf-8") as f:
    for row in csv.DictReader(f):
        tid = row["tutorial_id"]
        if tid in seen:
            errors.append(f"DUPLICATE tutorial_id {tid}")
        seen.add(tid)

scene = (ROOT / "scenes/ui/global_ui.tscn").read_text(encoding="utf-8")
for token in ["res://scripts/ui/ui_manager.gd", "res://scripts/ui/suspicion_eye.gd", "res://scripts/ui/ninja_locator.gd", "res://scripts/ui/interaction_prompt.gd", "res://scripts/ui/tutorial_director.gd", "FailureDiagnostic", "ResultPanel", "PauseOverlay", "MeowButton", "EmoteButton"]:
    if token not in scene:
        errors.append(f"SCENE token missing: {token}")

print(f"REQUIRED_FILES = {len(required)}")
print(f"TUTORIALS = {len(seen)}")
print(f"ERRORS = {len(errors)}")
for e in errors:
    print(e)
raise SystemExit(1 if errors else 0)
