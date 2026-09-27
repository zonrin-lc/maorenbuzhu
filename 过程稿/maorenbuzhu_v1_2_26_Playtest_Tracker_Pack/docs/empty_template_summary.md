# 《猫忍不住》v1.2.26 Playtest 自动统计

> 输入：player_runs.csv；可选 player_events.csv。脚本只做统计，不自动替代设计判断。


## 1. 12关总览

| Level | N | Clear% | Median Time | Median HP | Median Suspicion | Avg Paw | Avg Retry | First Fail Top | Route Mix |
|---|---:|---:|---:|---:|---:|---:|---:|---|---|
| L01 | 8 | 0% |  |  |  |  |  |  |  |
| L02 | 8 | 0% |  |  |  |  |  |  |  |
| L03 | 8 | 0% |  |  |  |  |  |  |  |
| L04 | 8 | 0% |  |  |  |  |  |  |  |
| L05 | 8 | 0% |  |  |  |  |  |  |  |
| L06 | 8 | 0% |  |  |  |  |  |  |  |
| L07 | 8 | 0% |  |  |  |  |  |  |  |
| L08 | 8 | 0% |  |  |  |  |  |  |  |
| L09 | 8 | 0% |  |  |  |  |  |  |  |
| L10 | 8 | 0% |  |  |  |  |  |  |  |
| L11 | 8 | 0% |  |  |  |  |  |  |  |
| L12 | 8 | 0% |  |  |  |  |  |  |  |

## 2. Gate 信号

- 首通可理解：`UnderstoodCore = Y`。
- 失败后改策略：`ChangedStrategy = Y`。
- 三路线：`RouteObserved` 应覆盖 SAFE / BALANCED / RISKY；若某关长期只有一种路线，需要回看关卡信息结构或收益结构。


## 3. 失败分布

暂无失败数据。

## 4. 需要人工复核的信号

以下规则只作为提示，不自动判定“好/坏”：

1. 某关 Clear% < 50%：优先检查可读性与失败原因，而不是直接放宽数值。

2. 某关 Median Time 超过该关 FirstClearTarget 的上界：检查路线长度、等待和事件顺序。

3. 某关 RouteObserved 长期只有一种：检查三路线是否真的存在明显差异。

4. `ChangedStrategy` 很低但 `RetryCount` 很高：通常说明玩家知道失败、却不知道如何改变。

5. `UnderstoodCore` 很低：优先回看教程/空间语言。
