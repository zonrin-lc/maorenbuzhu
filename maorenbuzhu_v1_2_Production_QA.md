# 《猫忍不住》v1.2 制作执行包 · Production & QA

> 目标：将 12 关内容扩充拆成可执行任务、资产需求、测试矩阵、自动验证与发布 Gate。

---

# 0. 版本范围

v1.2 主线范围：

```text
12 Main Levels
3 Chapters
12 Variant B
3 Chapter Challenges
Hard Mode
Hard+
```

优先级仍然：

```text
Gameplay > Settlement > Meta > Replay > Share
```

---

# 1. 总制作阶段

```text
P0 Project / System Backbone
P1 Data + Level Tooling
P2 Chapter 1 L01-L04
P3 Chapter 2 L05-L08
P4 Chapter 3 L09-L12
P5 Hard Mode / Meta
P6 Full QA / Burn-down
P7 Release Candidate
```

---

# 2. Godot 工程任务

## OPS-001 Project Rename

```text
application/config/name = "猫忍不住"
```

验收：启动页、窗口标题、保存 UI 不再出现“影猫”。

## OPS-002 LevelCatalog

实现：

`data/levels/level_catalog.tres`

验收：L01-L12 均可从 Catalog 找到。

## OPS-003 ChapterData

验收：3 章，每章 4 关，顺序正确。

## OPS-004 Debug Jump

Debug Build 支持：

```text
L01 ... L12
```

直接进入任意关卡。

---

# 3. Data Resource 任务

| ID | Resource | 验收 |
|---|---|---|
| DAT-001 | CatData | 输入/移动一致 |
| DAT-002 | NinjaData | 路线状态参数化 |
| DAT-003 | SuspicionProfile | 全局语义一致 |
| DAT-004 | ScoreRuleData | 12 关统一公式 |
| DAT-005 | EventData | 所有事件可配置 |
| DAT-006 | RouteData | L01-L12 完成 |
| DAT-007 | LevelData | L01-L12 完成 |
| DAT-008 | LevelModifier | Hard / Variant 支持 |
| DAT-009 | ChapterData | 3 章完成 |
| DAT-010 | LevelCatalog | 12 关映射 |
| DAT-011 | BoastTemplateData | 事件标签覆盖 |
| DAT-012 | AudioMap | 12 关绑定 |

---

# 4. L01-L12 生产任务总表

## L01 第一份差事

```text
LVL-L01-WB  地图白盒
LVL-L01-RO  NinjaRoute
LVL-L01-EV  Tripwire/Guard/Watergap
LVL-L01-TU  教学提示
LVL-L01-SC  Score
LVL-L01-QA  First Session Gate
```

## L02 他总是踩同一个坑

```text
LVL-L02-WB  连续事件布局
LVL-L02-RO  时间差
LVL-L02-EV  三事件串联
LVL-L02-VB  Route Variant B
LVL-L02-QA  Rush Gate
```

## L03 谁在看猫

```text
LVL-L03-WB  视线区域
LVL-L03-EV  Suspicion 事件
LVL-L03-UX  卖萌反馈
LVL-L03-QA  Suspicion Gate
```

## L04 村口大事故

```text
LVL-L04-WB  因果链布局
LVL-L04-EV  Guard/Tripwire/Crate/Watergap
LVL-L04-QA  Order Gate
LVL-L04-VB  Variant B
```

## L05 月夜码头

```text
LVL-L05-WB  搬运路线
LVL-L05-EV  Dog/Bridge/Poison
LVL-L05-DT  CarryData
LVL-L05-QA  Carry Gate
```

## L06 狗也能当队友

```text
LVL-L06-EV  Fish/Dog/Guard
LVL-L06-RS  风险解
LVL-L06-QA  NPC Link Gate
```

## L07 谁先走

```text
LVL-L07-EV  Guard A/B + Dog + Bridge + Poison
LVL-L07-WS  WorldState依赖
LVL-L07-QA  Cause Chain Gate
```

## L08 最后一班船

```text
LVL-L08-WB  多线程
LVL-L08-EV  6+ EventPoint
LVL-L08-RC  Resource Conflict
LVL-L08-QA  Chapter 2 Gate
```

## L09 雷雨夜

```text
LVL-L09-ART  雷雨环境
LVL-L09-EV   Tripwire/Dynamite/Guard/Dog
LVL-L09-AUD  Thunder/Rain layer
LVL-L09-QA   Pressure Gate
```

## L10 炸药不能乱碰

```text
LVL-L10-EV  Dynamite chain
LVL-L10-LOG caused_event_id
LVL-L10-VB  Variant B
LVL-L10-QA  Chain Reaction Gate
```

## L11 越靠近城门越忙

```text
LVL-L11-WB  Multi-thread arena
LVL-L11-EV  7 hazards
LVL-L11-QA  Multi-thread Gate
```

## L12 守门武士

```text
LVL-L12-BS  Boss Arena
LVL-L12-M1  Crane
LVL-L12-M2  Gourd
LVL-L12-M3  Caltrop
LVL-L12-ER  Emergency Rescue
LVL-L12-QA  Boss Active Gate
```

---

# 5. 三章节 Gate

## Chapter 1 Gate

8 名新玩家中：

- ≥6 人找到首个危险
- ≥5 人主动跑到 Ninja 前面
- ≥5 人理解被看到本身不是失败
- ≥4 人尝试卖萌
- ≥6 人能解释“猫在暗中帮忍者”

## Chapter 2 Gate

8 名新玩家中：

- ≥5 人使用 Carry
- ≥5 人使用 NPC 联动
- ≥4 人失败后改变顺序
- ≥4 人解释一条因果链

## Chapter 3 Gate

8 名测试者中：

- ≥5 人 Boss 前做准备
- ≥5 人 Boss 战中继续移动
- ≥4 人主动处理 Phase 2 蒺藜
- ≥4 人能说出 Boss 的一个伤害来源
- ≥4 人理解 Emergency 是补救，不是最优解

---

# 6. 单关功能测试矩阵

每关至少执行：

```text
标准成功
标准失败
最晚成功
风险解
被发现
重复触发
Reset
Save → Load
Variant B
```

L12 额外：

```text
A+B+C
A+B
A+C
B+C
A
B
C
None
Emergency
```

---

# 7. 自动验证

## LevelValidator

每次提交自动跑：

```text
L01 ... L12
```

输出：

```text
[LEVEL VALIDATOR]
TOTAL 12
PASS 12
FAIL 0
WARN <= 2
```

## SaveValidator

检查：

- 12 关完成状态
- 12 关最佳分
- 3 章完成状态
- Hard / Hard+ 解锁
- 成就
- 猫皮肤
- 鱼干

---

# 8. Bug Severity

## P0

- 任一主线关无法完成
- 无限循环
- Ninja 卡死
- Boss 无法结束
- Save 损坏
- L01-L12 任一输入失效
- LevelValidator 漏掉致命问题

## P1

- 可通过明确 Workaround 绕过
- 影响评分
- 影响 Variant
- 影响结算

## P2

- 视觉
- 音频
- 彩蛋
- 非关键 HUD

---

# 9. 12 关平衡计划

初始目标时间仅用于第一次白盒测试：

| Level | Target |
|---|---:|
| L01 | 60s |
| L02 | 65s |
| L03 | 70s |
| L04 | 85s |
| L05 | 85s |
| L06 | 90s |
| L07 | 100s |
| L08 | 110s |
| L09 | 95s |
| L10 | 105s |
| L11 | 120s |
| L12 | 140s |

> 这些数值在首轮 8 人试玩后再正式冻结，不在没有数据的情况下声称最终平衡已完成。

---

# 10. 章节挑战 QA

### CH1 不慌

- 全章不疾跑
- 所有 4 关仍可完成

### CH2 借力打力

- 全章 >=3 次 NPC 联动

### CH3 还得是我

- Boss 战后半程主动操作机关
- 不 Emergency Rescue

---

# 11. Asset / Audio 任务

原 v1.1 已有 Asset Manifest / Audio Manifest，v1.2 原则是：

> **优先用现有素材包重新组合，而非为每关制作一套新素材。**

新增重点：

- 三章环境调色
- 雷雨氛围只集中在第三章
- 12 关事件可复用同一套交互动画
- 结算台词通过 EventLog 标签变化

---

# 12. 内容量控制

12 关不是要求 12 套独立机制。

目标是：

```text
约 1 套核心操作
+
约 8~10 种核心事件组件
+
12 套事件组合
+
12 个 Variant B
+
3 个章节挑战
```

这样增加内容量，但不把技术维护成本成倍放大。

---

# 13. Release Gate v1.2

```text
[ ] Project 名称已改为《猫忍不住》
[ ] L01-L12 可完整通关
[ ] 3 章进度正常
[ ] 12 关 Retry 正常
[ ] 12 关 Save/Load 正常
[ ] 12 关 Score 正常
[ ] 12 关 EventLog 正常
[ ] 12 关 LevelValidator 全绿
[ ] 12 个 Variant B 可加载
[ ] 3 个 Chapter Challenge 可完成
[ ] Hard Mode 正常
[ ] Hard+ 正常
[ ] L12 Boss Active Gate 通过
[ ] Accessibility 基础项完成
[ ] P0 = 0
[ ] P1 已收敛
```

---

# 14. 第一批开工顺序

```text
Sprint 01
工程改名 + LevelCatalog + ChapterData

Sprint 02
L01-L02

Sprint 03
L03-L04

Sprint 04
L05-L06

Sprint 05
L07-L08

Sprint 06
L09-L10

Sprint 07
L11-L12

Sprint 08
Variant B + Chapter Challenges

Sprint 09
Hard / Hard+

Sprint 10
Full QA / Balance / Polish
```

---

# 15. 最终制作原则

> **先把 12 关白盒全部做出来，再做第二轮美术精修。**

禁止出现：

> L01 已经精修完美，L02-L12 还停留在纸面上。

12 关的最小目标是：

```text
能玩
→ 能看懂
→ 能失败
→ 能重试
→ 能找到更优解
→ 最后才是好看
```
