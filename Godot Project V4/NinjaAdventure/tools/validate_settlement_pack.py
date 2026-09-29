"""Settlement pack audit (rewritten for the post-result_flow IzakayaSettlement era).

The old version required scripts/settlement/result_flow.gd, which was deleted in
v1.6.2 when the settlement was consolidated into IzakayaSettlement +
SettlementContext. This version validates the CURRENT settlement contract and
deliberately has no side effects (the old one rewrote static_audit.txt, which
is why that file kept showing up dirty in git).
"""
from __future__ import annotations
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []

required = [
    "scripts/settlement/izakaya_settlement.gd",
    "scripts/settlement/settlement_context.gd",
    "scripts/settlement/boast_generator.gd",
    "data/banter/banter_data.gd",
    "data/banter/banter_emergency.tres",
    "data/banter/banter_boss_caltrop.tres",
    "scenes/settlement/izakaya_settlement.tscn",
]
for rel in required:
    if not (ROOT / rel).exists():
        errors.append(f"MISSING:{rel}")

# SettlementContext 必须提供清理接口（结算场景 6 条出口都靠它防串档）
ctx = (ROOT / "scripts/settlement/settlement_context.gd").read_text(encoding="utf-8")
for token in ["has_pending", "set_pending", "clear"]:
    if token not in ctx:
        errors.append(f"SETTLEMENT_CONTEXT_MISSING:{token}")

# 结算场景必须挂 CJK 字体 theme（此前 theme 错挂在 CanvasLayer 上导致字体不生效）
scene = (ROOT / "scenes/settlement/izakaya_settlement.tscn").read_text(encoding="utf-8")
if 'theme = ExtResource' not in scene:
    errors.append("SETTLEMENT_SCENE_NO_THEME")
if "[node name=\"UI\" type=\"CanvasLayer\"" in scene and "theme = ExtResource" in scene.split("[node name=\"UI\"")[1].split("\n\n")[0]:
    errors.append("SETTLEMENT_THEME_ON_CANVASLAYER")

print(f"REQUIRED_FILES={len(required)}")
print(f"ERRORS={len(errors)}")
for e in errors:
    print(e)
sys.exit(1 if errors else 0)
