from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
required = [
    "scripts/settlement/boast_generator.gd",
    "scripts/settlement/result_flow.gd",
    "data/banter/banter_data.gd",
    "data/banter/banter_emergency.tres",
    "data/banter/banter_boss_caltrop.tres",
    "data/settlement/settlement_flow_data.gd",
    "data/settlement/default_settlement_flow.tres",
    "scenes/settlement/izakaya_settlement.tscn",
]
errors=[]
for rel in required:
    if not (ROOT/rel).exists(): errors.append(f"MISSING:{rel}")

text=(ROOT/"scripts/settlement/boast_generator.gd").read_text(encoding="utf-8")
for token in ["EventLog", "EMERGENCY", "NEAR_DEATH", "BOSS", "CHAIN", "ROUTE_CHANGE"]:
    if token not in text: errors.append(f"MISSING_TOKEN:{token}")

audit = [
    "《猫忍不住》v1.2.16 static audit",
    f"required_files={len(required)}",
    f"errors={len(errors)}",
]
if errors: audit += errors
(ROOT/"static_audit.txt").write_text("\n".join(audit)+"\n", encoding="utf-8")
print("\n".join(audit))
raise SystemExit(1 if errors else 0)
