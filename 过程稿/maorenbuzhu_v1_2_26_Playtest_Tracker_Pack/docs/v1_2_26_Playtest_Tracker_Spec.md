# 《猫忍不住》v1.2.26 玩家试玩记录与自动统计

## 目标

把前一版 12 关 × SAFE / BALANCED / RISKY 的测试设计变成实际数据采集管线。

本版不使用虚构玩家数据。工作簿与 CSV 是空白采集模板；自动统计脚本在真实数据填入后才产生结论。

## 采集对象

### Run Log：每次尝试一行

核心字段：

- TesterID / SessionID
- LevelID / AttemptNo
- RouteObserved
- Clear / TimeSec
- NinjaHPFinal / MaxSuspicion / PawCount
- HighRiskRescue / ChainRescue / ShortcutUsed
- FirstFailCode / LastFailCode
- RetryCount
- UnderstoodCore / ChangedStrategy
- ThreeRouteGoal / Notes

### Event Log：每个关键事件一行

用于复盘因果链、失败原因、路线以及高风险行为。

## 8人 × 12关首轮采集规模

计划观察槽位：

**8 名玩家 × 12 关 = 96 条 Run Log 主记录。**

如果玩家在某关发生重试，可以继续新增 AttemptNo，而不是覆盖原始记录。

## 三条路线编码

- SAFE
- BALANCED
- RISKY
- UNKNOWN：无法判断时使用，不要猜。

## 推荐采集方式

第一轮测试以“真实玩家首通”为主：

1. 不提前告诉 SAFE/BALANCED/RISKY 的存在。
2. 测试员只记录实际行为。
3. 第二次尝试时观察是否主动改变策略。
4. 测试结束后再询问是否理解核心关系。

## 自动统计

`tools/summarize_playtest.py` 使用标准库读取 CSV，输出：

- 每关 Clear%
- Median Time
- Median Ninja HP
- Median Max Suspicion
- Median Paw
- Median Retry
- First Fail Code Top
- Route Mix
- 全局失败原因分布
- 需要人工复核的信号

## 决策原则

自动统计只负责发现异常，不直接改变数值。

调整顺序继续保持：

**可读性 → 时间 → 风险 → 表现。**

