# 《猫忍不住》v1.2.13 · L01-L12 Production Cards

## 第一章：村庄 / 行动

| ID | 关卡 | 主教学 | CRITICAL | STANDARD | 重玩点 |
|---|---|---|---:|---:|---|
| L01 | 第一份差事 | 提前赶场 | 3 | 0 | 更快 / 更低怀疑 |
| L02 | 他总是踩同一个坑 | 连续赶场 | 2 | 2 | 最晚处理窗口 |
| L03 | 谁在看猫 | 被看见 vs 做事被看见 | 2 | 1 | 怀疑控制 |
| L04 | 村口大事故 | 事件顺序 | 3 | 2 | 两条主路线 |

### L01
- Route：Start → Tripwire → Guard → Watergap → Goal
- 关键行为：BITE / MEOW / PUSH
- 失败：FAIL_TOO_LATE / FAIL_NINJA_DEATH / FAIL_SUSPICION

### L02
- Route：连续危险，缩短安全缓冲。
- 关键行为：先处理远端，再回到近端。
- 重点：让玩家感到“清完一个再慢慢走”已经不够。

### L03
- Route：守卫视锥覆盖核心事件。
- 关键行为：暴露动作后用 Ctrl 做补救。
- 重点：猫出现不失败；动作帧才会涨怀疑。

### L04
- Route：Guard → Tripwire → Crate → Watergap；另有 Shortcut 路线。
- 关键行为：排序。
- 重点：第一次让错误顺序改变后续可解性。

## 第二章：码头 / 规划

| ID | 关卡 | 主教学 | CRITICAL | STANDARD | 重玩点 |
|---|---|---|---:|---:|---|
| L05 | 月夜码头 | 搬运 | 3 | 1 | 资源送达路线 |
| L06 | 狗也能当队友 | NPC 联动 | 3 | 1 | SAFE / RISKY |
| L07 | 谁先走 | 顺序依赖 | 4 | 1 | Guard A/B 时序 |
| L08 | 最后一班船 | 多线程规划 | 4 | 2 | 三线组合 |

### L05
- 教 Q 叼取 / 放置。
- 资源：Fish / Antidote。
- 主要失败：FAIL_TOO_LATE / FAIL_ROUTE_BLOCKED。

### L06
- Dog → Bark → Guard 的固定因果链。
- 标准解：鱼肉引狗。
- 风险解：猫当诱饵。

### L07
- Guard A 离岗后，固定时间后 Guard B 改线。
- 重点：玩家必须观察“状态改变带来的后续结果”。

### L08
- 三线程：守卫线 / 狗线 / 搬运线。
- 结算必须能从 EventLog 识别“哪一条链最关键”。

## 第三章：天守阁 / 操纵

| ID | 关卡 | 主教学 | CRITICAL | STANDARD | 重玩点 |
|---|---|---|---:|---:|---|
| L09 | 雷雨夜 | 高压环境 | 3 | 2 | 低怀疑 / 低损伤 |
| L10 | 炸药不能乱碰 | 连锁事故 | 4 | 1 | 不同触发顺序 |
| L11 | 越靠近城门越忙 | 多线程压力 | 4 | 2 | 最短路线 |
| L12 | 守门武士 | Boss 战中继续操作 | 4 | 1 | 三机关组合 |

### L09
- 主要事件：Dynamite / Guard / Dog。
- 天气作为信息氛围，不改变核心判定。

### L10
- Dynamite 是主要连锁源。
- 成功处理后可以改变 Guard / Dog 的后续脚本分支。

### L11
- 同时管理 Guard A/B、Dog、Poison、Caltrop。
- 玩家必须在“处理眼前事件”和“提前布局后续事件”之间切换。

### L12
- Boss 不是普通 MAIN 路线阻挡事件。
- BOSS_PREP：Crane / Gourd。
- BOSS_COMBAT：Phase 2 Caltrop。
- Emergency Rescue：仅保底 1 Paw，不给正向资源奖励。

## 跨关质量基线

```text
L01：理解规则
L02：建立速度感
L03：建立风险感
L04：建立排序感
L05：建立搬运感
L06：建立 NPC 联动感
L07：建立因果链
L08：建立规划习惯
L09：建立高压节奏
L10：建立连锁预测
L11：建立多线程管理
L12：综合考试
```
