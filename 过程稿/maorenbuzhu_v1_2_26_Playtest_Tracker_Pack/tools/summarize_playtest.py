#!/usr/bin/env python3
import argparse, csv, statistics, re
from collections import Counter, defaultdict

LEVEL_ORDER = [f"L{i:02d}" for i in range(1, 13)]

def read_csv(path):
    with open(path, encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))

def num(v):
    try:
        return float(v)
    except (TypeError, ValueError):
        return None

def pct(n, d):
    return 0.0 if d == 0 else 100.0*n/d

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("runs_csv")
    ap.add_argument("--events-csv", default="")
    ap.add_argument("--out", default="playtest_summary.md")
    args = ap.parse_args()

    rows = [r for r in read_csv(args.runs_csv) if r.get("TesterID") and r.get("LevelID")]
    by_level = defaultdict(list)
    by_tester = defaultdict(list)
    for r in rows:
        by_level[r["LevelID"]].append(r)
        by_tester[r["TesterID"]].append(r)

    out = []
    out.append("# 《猫忍不住》v1.2.26 Playtest 自动统计\n")
    out.append("> 输入：player_runs.csv；可选 player_events.csv。脚本只做统计，不自动替代设计判断。\n")
    out.append("\n## 1. 12关总览\n")
    out.append("| Level | N | Clear% | Median Time | Median HP | Median Suspicion | Avg Paw | Avg Retry | First Fail Top | Route Mix |")
    out.append("|---|---:|---:|---:|---:|---:|---:|---:|---|---|")
    for lv in LEVEL_ORDER:
        rs = by_level.get(lv, [])
        n = len(rs)
        clears = sum(1 for r in rs if r.get("Clear","").lower() in ("1","y","yes","true","clear","成功"))
        times = [num(r.get("TimeSec")) for r in rs if num(r.get("TimeSec")) is not None]
        hp = [num(r.get("NinjaHPFinal")) for r in rs if num(r.get("NinjaHPFinal")) is not None]
        susp = [num(r.get("MaxSuspicion")) for r in rs if num(r.get("MaxSuspicion")) is not None]
        paw = [num(r.get("PawCount")) for r in rs if num(r.get("PawCount")) is not None]
        retry = [num(r.get("RetryCount")) for r in rs if num(r.get("RetryCount")) is not None]
        failcodes = Counter(r.get("FirstFailCode","") for r in rs if r.get("FirstFailCode",""))
        routes = Counter(r.get("RouteObserved","") for r in rs if r.get("RouteObserved",""))
        med = lambda xs: statistics.median(xs) if xs else ""
        route_mix = ", ".join(f"{k}:{v}" for k,v in routes.most_common()) if routes else ""
        fail_top = failcodes.most_common(1)[0][0] if failcodes else ""
        out.append(f"| {lv} | {n} | {pct(clears,n):.0f}% | {med(times) if times else ''} | {med(hp) if hp else ''} | {med(susp) if susp else ''} | {med(paw) if paw else ''} | {med(retry) if retry else ''} | {fail_top} | {route_mix} |")

    out.append("\n## 2. Gate 信号\n")
    out.append("- 首通可理解：`UnderstoodCore = Y`。\n- 失败后改策略：`ChangedStrategy = Y`。\n- 三路线：`RouteObserved` 应覆盖 SAFE / BALANCED / RISKY；若某关长期只有一种路线，需要回看关卡信息结构或收益结构。\n")
    out.append("\n## 3. 失败分布\n")
    all_fail = Counter(r.get("FirstFailCode","") for r in rows if r.get("FirstFailCode",""))
    if all_fail:
        out.append("| Fail Code | Count | Share |")
        out.append("|---|---:|---:|")
        total = sum(all_fail.values())
        for k,v in all_fail.most_common():
            out.append(f"| {k} | {v} | {pct(v,total):.0f}% |")
    else:
        out.append("暂无失败数据。")

    out.append("\n## 4. 需要人工复核的信号\n")
    out.append("以下规则只作为提示，不自动判定“好/坏”：\n")
    out.append("1. 某关 Clear% < 50%：优先检查可读性与失败原因，而不是直接放宽数值。\n")
    out.append("2. 某关 Median Time 超过该关 FirstClearTarget 的上界：检查路线长度、等待和事件顺序。\n")
    out.append("3. 某关 RouteObserved 长期只有一种：检查三路线是否真的存在明显差异。\n")
    out.append("4. `ChangedStrategy` 很低但 `RetryCount` 很高：通常说明玩家知道失败、却不知道如何改变。\n")
    out.append("5. `UnderstoodCore` 很低：优先回看教程/空间语言。\n")

    with open(args.out, "w", encoding="utf-8") as f:
        f.write("\n".join(out))

if __name__ == "__main__":
    main()
