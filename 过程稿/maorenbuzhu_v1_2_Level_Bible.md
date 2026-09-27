# 《猫忍不住》v1.2 制作执行包 · Level Bible

> 目标：把 **12 个主线关卡**落到 Godot 可制作的地图结构、忍者路线、EventPoint、依赖关系、解法、失败出口、评分目标与制作清单。

---

# 0. 统一关卡模板

每关必须具备：

```text
LevelData
RouteData
EventPoint[]
WorldState
Shortcut[]
ScoreRule
Variant B
AudioMap
ValidationRules
```

事件等级：

- CRITICAL：核心学习 / 核心题
- STANDARD：普通推进 / 压力
- OPTIONAL：鱼干 / 彩蛋

---

# 1. 第一章·村庄篇

章节关键词：**行动**

---

## L01《第一份差事》

### 产品目标

第一次让玩家理解：

> **我不是跟着忍者走，我要跑到他前面。**

### 推荐场景

`scenes/levels/chapter_01_village/L01_FirstJob.tscn`

### 区域

```text
A 出发点
→ B 绊绳巷
→ C 守卫广场
→ D 小水沟
→ E 卷轴终点
```

### EventPoint

| ID | 事件 | 等级 | 标准解 | 风险解 |
|---|---|---|---|---|
| L01-E01 | Tripwire | CRITICAL | 咬断 | 最后 1s 咬断 |
| L01-E02 | Guard | CRITICAL | 喵叫引开 | 贴身绕行 |
| L01-E03 | Watergap | CRITICAL | 推箱 | 临界跳跃 |

### 目标时间

60s 起调。

### 失败

`FAIL_TOO_LATE / FAIL_NINJA_DEATH / FAIL_TIMEOUT`

### 制作重点

必须让第一次玩家无需文字帮助就能发现第一个危险。

---

## L02《他总是踩同一个坑》

### 核心

把“单事件处理”升级成“连续赶场”。

### 路线

```text
Start
 ↓
Tripwire
 ↓
Guard
 ↓
Watergap
 ↓
Goal
```

### 节奏

- E01 处理后 Ninja 立即继续
- E02 在 6~8s 内进入
- E03 犹豫窗口 3s

### 关键问题

玩家必须开始选择更短的猫路线。

### Variant B

守卫开始位置改变，但危险仍然可预测。

### 失败

`FAIL_TOO_LATE / FAIL_WRONG_ORDER / FAIL_NINJA_DEATH`

---

## L03《谁在看猫》

### 核心

教学 Suspicion。

### 事件

```text
L03-E01 近距离经过守卫
L03-E02 偷取木箱
L03-E03 卖萌
L03-E04 水沟
```

### 因果

```text
偷箱被看见
→ Suspicion +
→ 退出视线
→ 停止继续增加
→ Ctrl 卖萌
→ Suspicion 清除
```

### 必测行为

至少一半测试玩家主动尝试一次卖萌。

---

## L04《村口大事故》

### 第一章高潮

### 事件图

```text
Guard A
   ↓
Tripwire
   ↓
Crate
   ↓
Watergap
```

改变 Guard 的位置会改变后面两个事件窗口。

### 主题

**第一次真正安排顺序。**

### 风险解

故意保留一次短窗口，在最后阶段完成推箱。

### 制作清单

```text
[ ] 4 EventPoint
[ ] 1 因果链
[ ] 1 Shortcut
[ ] 1 Variant B
[ ] 1 高风险解
[ ] 1 结算笑点
```

---

# 2. 第二章·码头篇

章节关键词：**规划**

---

## L05《月夜码头》

### 核心

正式使用搬运。

### 事件

- Guard A
- Dog
- Bridge
- Poison
- Fish

### 主解

```text
拿 Fish
→ 安抚 Dog
→ 拿 Crate
→ 开 Bridge
→ 搬 Antidote
→ Ninja 通过 Poison 区
```

### 核心学习

> **物品位置本身就是解谜的一部分。**

---

## L06《狗也能当队友》

### 核心

Dog 不是单纯障碍，而是移动工具。

### 解法 A

Fish → Dog → Guard → Ninja

### 解法 B

Cat Bait → Dog Chase → Guard 被吸引 → Ninja

### 评分

高风险解应有机会触发 `high_risk_rescue`，但不能靠故意伤害刷 3 猫爪。

### Failure

`FAIL_SUSPICION / FAIL_WRONG_ORDER / FAIL_NINJA_DEATH`

---

## L07《谁先走》

### 核心依赖链

```text
Guard A 离岗
↓
Guard B 换岗
↓
Dog 路线改变
↓
Bridge Window 改变
↓
Poison Window 改变
```

### 关卡问题

> “你先处理谁？”

### 错误反馈

允许玩家先做错一次，再通过明确后果理解顺序，而不是直接 Softlock。

### Variant B

Guard B 更早换岗。

---

## L08《最后一班船》

### 第二章高潮

### 同时管理

```text
Guard A
Guard B
Dog
Bridge
Poison
Caltrop
Antidote
```

### 资源冲突

Antidote Container 同时可用于：

- Poison 区安全处理
- 某个备用路线的诱导道具

一次只能带一个。

### 关键设计

玩家第一次遇到：

> **“我现在拿的这个东西，会影响十秒后的决定。”**

### 制作清单

```text
[ ] >= 6 EventPoint
[ ] >= 2 条有效顺序
[ ] >= 1 资源冲突
[ ] >= 1 Shortcut
[ ] >= 1 Risky Solution
[ ] Variant B
```

---

# 3. 第三章·天守阁篇

章节关键词：**操纵**

---

## L09《雷雨夜》

### 核心

环境压力第一次明显提升。

### 事件

- Tripwire
- Dynamite
- Guard
- Dog

### 表现

- 雷声
- 闪电
- 雨
- Dark Castle BGM

不新增操作，只提高读取节奏。

### 目标

玩家仍然能够依靠箭头和事件高亮定位 Ninja。

---

## L10《炸药不能乱碰》

### 核心

**连锁事故。**

### 因果链

```text
Dynamite
↓
Guard A 换位
↓
Dog 受惊
↓
Ninja 改线
↓
Caltrop 提前进入窗口
```

### 设计要求

失败必须出现明确 `caused_event_id`，让 EventLog 可以追溯因果。

### Failure

`FAIL_WRONG_ORDER / FAIL_ROUTE_BLOCKED / FAIL_NINJA_DEATH`

---

## L11《越靠近城门越忙》

### Boss 前完整压力测试

### 同时存在

- Guard A
- Guard B
- Dog
- Dynamite
- Poison
- Caltrop
- Cliff

### 玩家流程

```text
战前准备
↓
提前解决 1~2 个高风险点
↓
跟随 Ninja 判断剩余事件
↓
中途赶场
↓
最后安全进入 Boss 区
```

### 重点

这一关不应该比 L12 更难。

L11 的任务是：

> **让玩家在进入 Boss 前已经习惯多线程。**

---

## L12《守门武士》

### Boss Arena

```text
城门广场
├─ 吊车区
├─ 葫芦台
├─ 蒺藜冲锋线
├─ Ninja 战斗区
└─ Emergency Rescue 点
```

### Boss Flow

```text
INTRO
→ PREPARE
→ PHASE_1
→ PHASE_2
→ PHASE_3
→ END
```

### 机关

#### E01 吊车

战前准备，咬绳。

#### E02 酒葫芦

战前下药，Boss 开场延迟。

#### E03 蒺藜

**Phase 2 冲锋过程中处理。**

### Emergency Rescue

Boss Finisher 前、Ninja HP <=1 时触发。

结果：

- Ninja 保留 1 HP
- 任务完成
- 1 猫爪
- 不提供额外正向资源

### Boss Gate

至少 60% 测试玩家在 Boss 已开始行动后继续主动移动。

---

# 4. 12 关 Variant B 规范

Variant B 是确定性脚本变体，不是随机地图。

只允许改变：

- Route 分支
- NPC 起始位置
- Event 时间窗口
- 资源初始位置
- 一条依赖关系

禁止改变：

- 操作方式
- 核心失败语义
- 三猫爪公式
- EventLog schema

---

# 5. 每关标准生产表

| 字段 | 必填 |
|---|---|
| LevelID | ✓ |
| Scene | ✓ |
| LevelData | ✓ |
| RouteData | ✓ |
| Event 数 | ✓ |
| 主路线 | ✓ |
| Shortcut | ✓ |
| 标准解 | ✓ |
| 风险解 | ✓ |
| 失败出口 | ✓ |
| Variant B | ✓ |
| 目标时间（初始值） | ✓ |
| 三猫爪适配 | ✓ |
| 结算笑点 | ✓ |
| QA Case | ✓ |

---

# 6. 十二关初始时间基线

> 以下只是第一轮调平起点，不是最终冻结值。

| 关卡 | Target Time |
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

---

# 7. 关卡制作顺序

```text
L01 Whitebox
→ L01 Gate
→ L01 Art Lock

L02 Whitebox
→ L02 Gate
→ L02 Art Lock

L03 Whitebox
→ L03 Suspicion Gate
→ L03 Art Lock

L04 Whitebox
→ Chapter 1 Gate

L05 Whitebox
→ L05 Carry Gate

L06 Whitebox
→ L06 NPC Link Gate

L07 Whitebox
→ Cause Chain Gate

L08 Whitebox
→ Chapter 2 Gate

L09 Whitebox
→ Pressure Gate

L10 Whitebox
→ Chain Reaction Gate

L11 Whitebox
→ Multi-thread Gate

L12 Whitebox
→ Boss Active Gate
→ Final Art Lock
```

---

# 8. LevelValidator 检查重点

## L01-L04

- 路线连续
- Event 有出口
- 第一次理解不被 HUD 干扰

## L05-L08

- Carryable 引用正确
- NPC 联动无死循环
- 顺序失败可 Reset

## L09-L11

- 动态事件不会互相永久锁死
- `caused_event_id` 正确
- 多线程下 Ninja 路线仍确定

## L12

- Boss 进入 / 退出完整
- 三机关组合全部有明确结果
- Emergency Rescue 独立可测

---

# 9. 最终关卡体验

### 第一章

> “我得跑快点。”

### 第二章

> “我得先做对的事。”

### 第三章

> “我得让整个场面按我的顺序发生。”
