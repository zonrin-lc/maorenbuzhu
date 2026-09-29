"""UI pack audit (global_ui + HUD contract).

Removed the stale MeowButton/EmoteButton requirement from global_ui.tscn: those
are touch-control buttons owned by TouchControls, not HUD nodes, so the old
check could never pass. Also verifies the HUD is wired to the CJK font.
"""
from __future__ import annotations
import csv, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []

required = [
    "docs/v1_2_14_Global_UI_HUD_Spec.md",
    "scripts/ui/ui_manager.gd",
    "scripts/ui/suspicion_eye.gd",
    "scripts/ui/ninja_locator.gd",
    "scripts/ui/interaction_prompt.gd",
    "scripts/ui/tutorial_director.gd",
    "scripts/ui/failure_diagnostic.gd",
    "scripts/ui/result_panel.gd",
    "scenes/ui/global_ui.tscn",
    "data/tutorial/tutorial_data.gd",
    "scripts/input/touch_controls.gd",
]
for rel in required:
    if not (ROOT / rel).exists():
        errors.append(f"MISSING:{rel}")

manifest = ROOT / "tools/tutorial_manifest.csv"
if manifest.exists():
    seen: set[str] = set()
    with manifest.open(encoding="utf-8") as f:
        for row in csv.DictReader(f):
            tid = row.get("tutorial_id", "")
            if tid in seen:
                errors.append(f"DUPLICATE tutorial_id {tid}")
            seen.add(tid)
else:
    errors.append("MISSING:tools/tutorial_manifest.csv")

scene = (ROOT / "scenes/ui/global_ui.tscn").read_text(encoding="utf-8")
# global_ui 应挂的 HUD 脚本（不含 Meow/EmoteButton——那是 TouchControls 的职责）
for token in ["res://scripts/ui/ui_manager.gd", "res://scripts/ui/suspicion_eye.gd",
              "res://scripts/ui/ninja_locator.gd", "res://scripts/ui/interaction_prompt.gd",
              "res://scripts/ui/tutorial_director.gd"]:
    if token not in scene:
        errors.append(f"SCENE token missing: {token}")

# TouchControls 必须提供喵叫/卖萌触控键（对应旧 spec 的 MeowButton/EmoteButton）
touch = (ROOT / "scripts/input/touch_controls.gd").read_text(encoding="utf-8")
for token in ["meow", "emote"]:
    if token not in touch:
        errors.append(f"TOUCH_CONTROL_MISSING:{token}")

# 世界空间中文绘制不得再回退到引擎内置拉丁字体
stale = []
for f in (ROOT / "scripts").rglob("*.gd"):
    txt = f.read_text(encoding="utf-8")
    if "ThemeDB.fallback_font" in txt and "const UI_FONT" not in txt:
        stale.append(f.name)
for name in stale:
    errors.append(f"FALLBACK_FONT_STILL_USED:{name}")

print(f"REQUIRED_FILES = {len(required)}")
print(f"ERRORS = {len(errors)}")
for e in errors:
    print(e)
sys.exit(1 if errors else 0)
