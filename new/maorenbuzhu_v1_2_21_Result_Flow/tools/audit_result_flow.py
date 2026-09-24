from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
checks = {
    "result_scene": ROOT / "scenes/flow/result.tscn",
    "result_screen": ROOT / "scripts/flow/result_screen.gd",
    "result_flow": ROOT / "scripts/flow/result_flow.gd",
    "app_flow": ROOT / "scripts/flow/app_flow.gd",
    "save_manager": ROOT / "scripts/flow/save_manager.gd",
    "progress_manager": ROOT / "scripts/flow/progress_manager.gd",
    "level_catalog": ROOT / "data/flow/level_catalog.gd",
    "spec": ROOT / "docs/v1_2_21_Result_Flow_Spec.md",
}
errs=[]
for k,p in checks.items():
    if not p.exists(): errs.append(f"missing:{k}")
app=(ROOT/"scripts/flow/app_flow.gd").read_text()
result=(ROOT/"scripts/flow/result_screen.gd").read_text()
rf=(ROOT/"scripts/flow/result_flow.gd").read_text()
for token in ["complete_level", "next_level", "can_start", "result_flow"]:
    if token not in app: errs.append(f"app_missing:{token}")
for token in ["consume_result", "finish_level", "retry", "go_next"]:
    if token not in rf: errs.append(f"resultflow_missing:{token}")
for token in ["Retry", "Next", "LevelSelect", "Menu"]:
    if token not in result: errs.append(f"resultscreen_missing:{token}")
scene=(ROOT/"scenes/flow/result.tscn").read_text()
for button in ["Retry","Next","LevelSelect","Menu"]:
    if f'name="{button}"' not in scene: errs.append(f"scene_missing:{button}")
print(f"CHECKS={len(checks)+10}")
print(f"ERRORS={len(errs)}")
for e in errs: print(e)
raise SystemExit(1 if errs else 0)
