"""权威事件计数：data/events/*.tres 是 QA 事件数量的唯一事实源。

用法：
    python tools/count_events.py            # 打印计数
    python tools/count_events.py --json     # {"event_count": N}
    python tools/count_events.py --expect N # 校验，不符则退出码 1
"""
from pathlib import Path
import json, sys

ROOT = Path(__file__).resolve().parents[1]
EVENTS_DIR = ROOT / "data" / "events"


def count_events() -> int:
    return sum(1 for p in EVENTS_DIR.glob("*.tres") if p.is_file())


def main() -> int:
    args = sys.argv[1:]
    count = count_events()
    if "--json" in args:
        print(json.dumps({"event_count": count}))
    else:
        print(f"EVENT_COUNT={count}")
    if "--expect" in args:
        expected = int(args[args.index("--expect") + 1])
        if count != expected:
            print(f"MISMATCH: expected {expected}, actual {count}", file=sys.stderr)
            return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
