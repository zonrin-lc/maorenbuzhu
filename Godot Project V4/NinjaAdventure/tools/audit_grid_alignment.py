"""16x16 grid alignment ratchet (GDD §15.3 grid debt).

Reality check: the 16x16 production standard is currently 0% implemented in content —
all 230 geometry rects across the 12 levels are off-grid (verified against
LayoutGeometry.LEVEL_LAYOUTS). So the alignment check cannot simply be promoted to
ERROR: doing so would fail every level, and realigning 230 rects blind would shift
collision geometry and level design (it needs level-design + playtest work, and
snapped geometry can open/close traversal gaps).

So this is a RATCHET. Rather than a single total (which would let "fix one rect,
break another" net to zero and slip through), it records a PER-LEVEL, PER-KEY
fingerprint of the misaligned rect list. Any change to which rects are misaligned
in any level/key is reported as drift, whether it improves or worsens. This also
forces an intentional, visible decision whenever a level's geometry is edited.

BASELINE maps "<level>.<key>" -> sorted tuple of the misaligned rect strings.
To adopt an intentional change, update the corresponding baseline entry.
"""
from __future__ import annotations
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LAYOUT = ROOT / "scripts/gameplay/layout_geometry.gd"

KEYS = ["walls", "tunnels", "shortcuts", "bridges", "water"]
LEVELS = [f"L{i:02d}" for i in range(1, 13)]


def _fmt(x: str, y: str, w: str, h: str) -> str:
    return f"{x},{y},{w},{h}"


def parse_fingerprints() -> dict[str, tuple[str, ...]]:
    text = LAYOUT.read_text(encoding="utf-8")
    seg = text.split("LEVEL_LAYOUTS := {", 1)[1]
    # 按关卡头 `&"Lxx": {` 切片到下一个关卡头，而不是用 `\n    }` 做边界
    # （关卡实际以 `    },` 结束，正则会跨关吞并，导致错配与重复计数）。
    heads = [(m.start(), m.group(1)) for m in re.finditer(r'&"(L\d\d)":\s*\{', seg)]
    out: dict[str, tuple[str, ...]] = {}
    for i, (start, lvl) in enumerate(heads):
        end = heads[i + 1][0] if i + 1 < len(heads) else len(seg)
        body = seg[start:end]
        for key in KEYS:
            km = re.search(rf'"{key}":\s*\[(.*?)\]', body, re.S)
            if not km:
                continue
            bad = []
            for x, y, w, h in re.findall(r'Rect2\(\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*\)', km.group(1)):
                if any(int(v) % 16 != 0 for v in (x, y, w, h)):
                    bad.append(_fmt(x, y, w, h))
            if bad:
                out[f"{lvl}.{key}"] = tuple(sorted(bad))
    return out


def _load_baseline() -> dict[str, tuple[str, ...]]:
    path = ROOT / "tools/grid_alignment_baseline.txt"
    if not path.exists():
        return {}
    out: dict[str, tuple[str, ...]] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, val = line.split("=", 1)
        # 每个 rect 单独 strip：某些条目首个值可能带前导空格，规范化后再比较，
        # 避免「同一矩形因空白差异」被误报为 drift。
        rects = tuple(r.strip() for r in val.split("|") if r.strip())
        out[key.strip()] = rects
    return out


def main() -> None:
    current = parse_fingerprints()
    baseline = _load_baseline()

    if not baseline:
        print("no baseline file (tools/grid_alignment_baseline.txt) — treating all as new")
        for k in sorted(current):
            print(f"  {k}: {len(current[k])}")
        print(f"TOTAL={sum(len(v) for v in current.values())}")
        print("ERRORS=1")
        sys.exit(1)

    errors: list[str] = []
    for key in sorted(set(baseline) | set(current)):
        b = set(baseline.get(key, ()))
        c = set(current.get(key, ()))
        added = c - b
        removed = b - c
        if added:
            errors.append(f"grid_drift[{key}]: +{len(added)} newly misaligned {sorted(added)}")
        if removed:
            # improvement is allowed but must be an explicit baseline edit, not silent
            errors.append(f"grid_improved[{key}]: -{len(removed)} no longer misaligned {sorted(removed)} (update baseline to adopt)")

    total = sum(len(v) for v in current.values())
    print(f"GRID_MISALIGNED={total} LEVELS_WITH_DRIFT={len(baseline)}")
    for k in sorted(current):
        print(f"  {k}: {len(current[k])}")
    print(f"ERRORS={len(errors)}")
    for e in errors:
        print(e)
    sys.exit(1 if errors else 0)


if __name__ == "__main__":
    main()
