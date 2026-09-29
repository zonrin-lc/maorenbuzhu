"""16x16 grid alignment ratchet (GDD §15.3 grid debt).

Reality check: the 16x16 production standard is currently 0% implemented in content —
all 230 geometry rects across the 12 levels are off-grid (verified against
LayoutGeometry.LEVEL_LAYOUTS). So the alignment check cannot simply be promoted to
ERROR: doing so would fail every level, and realigning 230 rects blind would shift
collision geometry and level design (it needs level-design + playtest work, and
snapped geometry can open/close traversal gaps).

So this is a RATCHET: it records the current misalignment count as a baseline and
fails only when the count INCREASES (new drift). Each intentional realignment
lowers BASELINE. This prevents further drift now and gives an exact migration
target, without freezing the game on existing debt.
"""
from __future__ import annotations
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LAYOUT = ROOT / "scripts/gameplay/layout_geometry.gd"

# 当前基线（= 12 关全部几何未对齐时的总数）。每完成一关对齐就下调。
BASELINE = 230

KEYS = ["walls", "tunnels", "shortcuts", "bridges", "water"]
LEVELS = [f"L{i:02d}" for i in range(1, 13)]


def parse_alignment() -> dict[str, int]:
    text = LAYOUT.read_text(encoding="utf-8")
    seg = text.split("LEVEL_LAYOUTS := {", 1)[1]
    out: dict[str, int] = {}
    for lvl in LEVELS:
        m = re.search(rf'&"{lvl}":\s*\{{(.*?)\n    \}}', seg, re.S)
        if not m:
            out[lvl] = 0
            continue
        body = m.group(1)
        bad = 0
        for key in KEYS:
            km = re.search(rf'"{key}":\s*\[(.*?)\]', body, re.S)
            if not km:
                continue
            for x, y, w, h in re.findall(r'Rect2\((-?\d+),\s*(-?\d+),\s*(-?\d+),\s*(-?\d+)\)', km.group(1)):
                if any(int(v) % 16 != 0 for v in (x, y, w, h)):
                    bad += 1
        out[lvl] = bad
    return out


def main() -> None:
    counts = parse_alignment()
    total = sum(counts.values())
    errors: list[str] = []
    if total > BASELINE:
        errors.append(f"grid_drift: misalignment {total} > baseline {BASELINE} (new off-grid geometry added)")
    print(f"GRID_MISALIGNED={total} BASELINE={BASELINE}")
    for lvl in LEVELS:
        print(f"  {lvl}: {counts[lvl]}")
    print(f"ERRORS={len(errors)}")
    for e in errors:
        print(e)
    raise SystemExit(1 if errors else 0)


if __name__ == "__main__":
    main()
