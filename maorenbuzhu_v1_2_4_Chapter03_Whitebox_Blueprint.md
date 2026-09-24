# 《猫忍不住》v1.2.4 第三章白盒地图蓝图

> 状态：Production Whitebox
> 章节：第三章《天守阁》
> 关卡：L09–L12
> 目标：把第三章直接拆成 Godot 可搭建的地图、路线、事件点、状态和 QA 锚点。
>
> 本章建立在 v1.2 已冻结的第三章定位：多线程系统操纵；不新增玩家核心按键，重点通过旧机制重组、时间压力、连锁事故和 Boss 战提升复杂度。
>
> 来源约束：原始设计已定义天守阁为城堡外围→正门、雷雨环境，并使用守卫、炸药桶、铁蒺藜、悬崖、恶狗、毒雾以及 Boss 三机关。第三章原定位为时间压力 + 多解 Boss；本白盒进一步把这些内容拆成 L09–L12 四个阶段。fileciteturn33file7

---

# 0. 第三章总体白盒规范

## 0.1 章节学习曲线

```text
L09 雷雨夜
环境压力 + 炸药第一次重组
        ↓
L10 炸药不能乱碰
连锁事故 + 路线污染
        ↓
L11 越靠近城门越忙
多线程综合压力测试
        ↓
L12 守门武士
Boss 战最终考试
```

## 0.2 统一地图坐标

以左上角为 `(0,0)`，单位：px。

建议基础 Tile：32×32。

推荐关卡白盒尺寸：

| Level | Width | Height | Tile Size |
|---|---:|---:|---:|
| L09 | 1536 | 896 | 32 |
| L10 | 1664 | 960 | 32 |
| L11 | 1920 | 1088 | 32 |
| L12 | 1792 | 1024 | 32 |

统一保留：

- 主路线宽度 96–128 px
- 猫捷径宽度 48–64 px
- Ninja EventTrigger 宽度 64–96 px
- 场地边界 32 px 安全缓冲

---

# 1. L09《雷雨夜》

## 1.1 关卡定位

关键词：

> **环境压力。**

玩家已经会处理单点事件和 NPC 联动；L09 不再教新操作，而是用雷雨、视线遮蔽、炸药和守卫，让玩家第一次主动读“事件后果”。

## 1.2 区域划分

```text
R0 南侧入口
R1 雨巷
R2 木箱堆场
R3 炸药区
R4 北门守卫区
R5 内城入口
```

建议矩形范围：

```text
R0  (64, 704)  → (320, 832)
R1  (256, 480) → (704, 832)
R2  (608, 320) → (992, 640)
R3  (928, 192) → (1248, 480)
R4  (1184, 320) → (1536, 640)
R5  (1376, 544) → (1472, 800)
```

## 1.3 Ninja Route

```text
N09_00 Start
→ N09_01 雨巷
→ N09_02 木箱堆场
→ N09_03 炸药区
→ N09_04 北门
→ N09_05 Goal
```

固定速度：普通 Ninja 60 px/s；第三章基础可使用得意状态 66 px/s。原设计中的忍者加速与更短犹豫窗口属于第三章压力来源。fileciteturn33file8

## 1.4 EventPoints

| ID | Event | Type | Ninja Window | Goal |
|---|---|---|---:|---|
| E09_TW | 绊绳 | STANDARD | 1.5s | 提前处理 |
| E09_DY | 炸药桶 | CRITICAL | 0s | 水里/断引线 |
| E09_GA | Guard A | CRITICAL | 2.0s | 改变其位置 |
| E09_DOG | Dog | STANDARD | 2.5s | 鱼/诱饵 |
| E09_GOAL | 北门 | GOAL | — | 取得卷轴 |

## 1.5 核心因果链

### 主路线

```text
炸药未处理
→ Ninja 敲桶
→ 爆炸
→ Guard A 警觉
→ Guard A 改变巡逻
→ Ninja 进入 Dog 路线
```

### 稳健解

```text
E09_DY 先处理
→ E09_GA 吸引离岗
→ E09_DOG 用鱼
→ 终点
```

### 风险解

```text
不处理炸药
→ 等 Ninja 触发前最后一刻推桶入水
→ 借爆炸声诱导 Guard A
→ 快速处理 Dog
```

> 风险解必须有明确收益，不得成为唯一正解。

## 1.6 白盒捷径

`S09_01 CatTunnel`：雨棚下方短隧道。

```text
入口 (448,688)
出口 (736,432)
```

`S09_02 JumpPoint`：木箱堆垛。

猫可从 `(832,512)` 跳到 `(1016,352)`。

## 1.7 失败出口

```text
FAIL_TOO_LATE
FAIL_NINJA_DEATH
FAIL_ROUTE_BLOCKED
FAIL_BOSS? = No
```

## 1.8 Godot 对照

```text
res://levels/ch03/l09_rain_night.tscn
res://data/levels/ch03/l09_rain_night.tres
res://data/events/ch03/l09_*.tres
res://data/routes/ch03/l09_ninja_route.tres
res://data/validation/ch03/l09_rules.tres
```

## 1.9 白盒验收

- 玩家第一次看到炸药后，应能推断它和忍者路线有关。
- 至少一条安全解、一条风险解成立。
- 雷雨不能遮住关键 EventPoint 的可读反馈。
- 玩家不应因为纯视野恶化而失败。

---

# 2. L10《炸药不能乱碰》

## 2.1 关卡定位

关键词：

> **连锁事故。**

这一关的核心不是“炸药更危险”，而是让玩家第一次认真预测：

> “我处理这个事件之后，谁会改变状态？”

原事件设计已经定义炸药：忍者会手贱敲击；猫可提前把桶推进水里或咬断引线。fileciteturn33file5

## 2.2 区域

```text
R0 西门
R1 炸药仓
R2 中庭
R3 Guard A 巡逻线
R4 Dog 院
R5 Poison Corridor
R6 东门
```

## 2.3 Ninja Route

```text
N10_00
→ N10_01 炸药仓入口
→ N10_02 中庭
→ N10_03 Guard A
→ N10_04 Dog
→ N10_05 Poison
→ N10_06 Goal
```

## 2.4 Event Chain

```text
E10_DY_A
   ↓
Guard A Alert
   ↓
E10_GA
   ↓
Guard A 回位计时
   ↓
Dog Window
   ↓
Poison Window
```

第二条链：

```text
Dog 被鱼吸引
→ Dog 离开
→ Guard A 不再被狗声吸引
→ Guard A 保持岗位
→ Ninja 被迫进入 Poison 路线
```

这是一条典型的“正确处理 A 反而关闭 B”的题目。

## 2.5 双解结构

### 解 A：稳定

```text
先炸药
→ Guard A 离岗
→ Dog 被鱼引走
→ 提前投放解毒药
→ 通过 Poison
```

### 解 B：高风险

```text
不提前解毒
→ Ninja 触发 Poison 前 4 秒
→ 猫叼药高速赶路
→ 在他进入毒雾前滚药
→ 与 Guard A 回位时间错峰
```

## 2.6 Shortcut

`S10_01 RoofJump`：

```text
R1 炸药仓顶部
→ R4 Dog 院
```

只允许猫使用。

## 2.7 关卡关键时间窗

| 项目 | 基准 |
|---|---:|
| Guard 回位 | 6s |
| Dog 鱼肉绑定 | 20s |
| Poison 犹豫 | 4s |
| 叼取速度惩罚 | -15% |
| Cat Sprint | 160 px/s |

这些参数沿用已有机制基准。fileciteturn32file1

## 2.8 QA 特别项

必须测试：

```text
炸药处理后 Guard 状态
炸药未处理的失败路线
Dog→Guard 联动
Poison 解毒药提前放置
叼药状态下被发现
Reset 后所有状态恢复
```

---

# 3. L11《越靠近城门越忙》

## 3.1 关卡定位

关键词：

> **多线程压力测试。**

这是 Boss 前最后一关，目的不是再教学，而是验证玩家能否同时处理三条任务线。

## 3.2 地图布局

```text
             ┌──── Guard B ─── Goal
             │
West ─ Guard A ─ Central ─ Poison
             │
          Dog Yard
             │
          Dynamite
```

推荐尺寸：`1920×1088`。

## 3.3 三线程

### Thread A：守卫线

```text
Guard A
→ Guard B
→ Goal
```

### Thread B：动物线

```text
Dog
→ Guard Noise
→ 路线偏移
```

### Thread C：环境线

```text
Dynamite
→ Caltrop / Bridge
→ Poison
```

## 3.4 EventPoint

```text
E11_GA  Guard A       CRITICAL
E11_GB  Guard B       STANDARD
E11_DOG Dog           CRITICAL
E11_DY1 Dynamite      CRITICAL
E11_CAL Caltrop       CRITICAL
E11_POI Poison        CRITICAL
E11_CLI Cliff         STANDARD
```

## 3.5 设计核心

玩家一次只能持续操作一个事件，因此必须学会：

```text
处理 A 一半
→ 放弃
→ 赶去 B
→ 再回来完成 A
```

这会第一次验证“互动可打断”的实际价值。

原绊绳互动已有“可被打断”的设计原则，可直接复用到高压关。fileciteturn33file4

## 3.6 推荐解法

### 稳健型

```text
Dynamite
→ Guard A
→ Dog
→ Poison
→ Guard B
→ Goal
```

### 调度型

```text
Guard A 声引
→ 立刻转 Dog
→ Dog 改位
→ 回来完成 Dynamite
→ 利用 Guard B 窗口走 Poison
```

### 极限型

```text
故意让一个普通事件进入临界
→ 最后一秒补救
→ 获得 high_risk_rescue
→ 快速压缩总时长
```

## 3.7 白盒捷径

`S11_01 CatTunnel`：中央下方排水沟。

`S11_02 JumpPoint`：西侧屋顶。

`S11_03 FenceGap`：猫专用小缝。

## 3.8 三猫爪测试重点

第三章 允许使用 `A–G` 七项表现条件中的任意 4 项；其中 `boss_mechanics_success` 只在 L12 有效。

L11 重点观察：

- max_suspicion
- elapsed_time
- high_risk_rescue
- chain_rescue
- shortcut_or_dependency_mastery

---

# 4. L12《守门武士》

## 4.1 关卡定位

> **Boss 最终考试。**

不是新系统展示，而是验证玩家是否真正掌握：

```text
提前准备
+
事件排序
+
空间捷径
+
战中补救
```

## 4.2 Arena

推荐尺寸：`1792×1024`。

区域：

```text
R0 Approach
R1 Gourd Platform
R2 Crane Platform
R3 Boss Intro
R4 Charge Lane
R5 Caltrop Storage
R6 Ninja Combat Zone
R7 Emergency Door
```

## 4.3 Boss 核心机关

原设计明确了三个“手脚”：吊车货箱、门口蒺藜、酒葫芦。猫不能直接伤害 Boss。fileciteturn33file7

### A 吊车

```text
Boss 前准备
→ 猫爬上 Crane
→ 咬绳 0.8s
→ boss_crane_ready = true
```

伤害：`-40`。

### B 酒葫芦

```text
Boss 前准备
→ 拍药进葫芦
→ boss_gourd_ready = true
```

开场触发延迟窗口。

### C 蒺藜

```text
Boss Phase 2
→ Boss 进入 Charge
→ 玩家移动到 Caltrop Storage
→ 撒放到 Charge Line
→ Boss 冲锋踩中
```

伤害：`-30`。

## 4.4 Boss 状态机

```text
BOSS_INTRO
↓
BOSS_PREPARE
↓
BOSS_PHASE_1
↓
BOSS_PHASE_2
↓
BOSS_PHASE_3
↓
BOSS_DEFEATED / BOSS_RETREAT
```

对应 v1.1 已冻结的 Boss 状态结构。

## 4.5 Phase 1

Boss 进入场地。

如果 `boss_gourd_ready`：

```text
Boss 离开 10s
→ Ninja 获得安全输出窗口
```

如果 `boss_crane_ready`：

```text
玩家触发吊车
→ Boss HP -40
```

## 4.6 Phase 2

Boss 锁定 Ninja，开始冲锋准备。

关键条件：

```text
boss_caltrop_ready = false
```

玩家仍然必须移动。

倒计时：`1.5–2.0s` 紧急窗口只用于最后补救，不替代正常路线。

## 4.7 Phase 3

根据 Boss HP：

```text
HP <= 30
→ Ninja 收尾动画

HP > 30
→ Ninja 苦战
→ 可能扣至 2 心

HP 条件失败
→ Emergency / Retreat
```

## 4.8 Emergency Rescue

```text
Boss Finish
AND Ninja HP <= 1
→ Emergency Door 开启
→ 玩家 触发 1.5–2s
→ Ninja 保住 1 HP
→ Mission Complete
→ Paws = 1
```

Emergency 不是第四个 Boss 机关，也不产生额外资源奖励。

## 4.9 Boss 多解组合

必须测试：

```text
A+B+C
A+B
A+C
B+C
A
B
C
None
```

并保证每种组合都有明确结果；这一测试要求沿用 v1.1 QA 规则。

推荐结果矩阵：

| 机关成功 | Ninja 最终状态 | 结果 |
|---|---|---|
| A+B+C | 3 HP | 完整胜利 |
| 任意 2 个 | ≥2 HP | 常规胜利 |
| 任意 1 个 | 1–2 HP | 险胜 / 补救可能 |
| 0 个 | 0 HP 前 | 必须提供明确失败或 Emergency 条件 |

## 4.10 Boss 白盒节点

```text
BossArena
├── NinjaRoute
├── BossController
├── CraneMechanic
│   ├── Rope
│   ├── Cargo
│   └── Trigger
├── GourdMechanic
│   ├── Gourd
│   └── PoisonPayload
├── CaltropMechanic
│   ├── Storage
│   ├── ScatterZone
│   └── ChargeLane
├── EmergencyDoor
├── EventPoints
└── DebugMarkers
```

## 4.11 Godot 文件

```text
res://levels/ch03/l12_tenshukaku_boss.tscn
res://scripts/boss/boss_controller.gd
res://scripts/boss/crane_mechanic.gd
res://scripts/boss/gourd_mechanic.gd
res://scripts/boss/caltrop_mechanic.gd
res://scripts/boss/emergency_rescue.gd
res://data/boss/tenshukaku_boss.tres
res://data/events/ch03/l12_*.tres
res://data/validation/ch03/l12_boss_rules.tres
```

---

# 5. 第三章统一 WorldState

```text
dynamite_a_safe
dynamite_b_safe
guard_a_departed
guard_b_active
dog_fed
poison_route_safe
caltrop_cleared
boss_crane_ready
boss_caltrop_ready
boss_gourd_ready
boss_phase
boss_retreat
emergency_available
```

禁止写入：

```text
player_should_do_X
```

WorldState 只保存世界事实。

---

# 6. 第三章 Debug Overlay

建议统一显示：

```text
Ninja: [state] [HP]
Boss: [phase] [HP]
Suspicion: [value]

GuardA: [state]
GuardB: [state]
Dog: [state]

DynamiteA: [safe/armed]
Poison: [safe/active]

Crane: [ready]
Gourd: [ready]
Caltrop: [ready]
Emergency: [available]

EventQueue:
[E09]
[E10]
...
```

Release 构建隐藏。

---

# 7. 第三章 QA Matrix

## 7.1 L09

```text
[ ] 炸药标准解
[ ] 炸药风险解
[ ] Guard 状态切换
[ ] Dog 联动
[ ] 雷雨不遮挡关键反馈
[ ] Reset
```

## 7.2 L10

```text
[ ] 炸药→Guard
[ ] Dog→Guard
[ ] Poison→解毒药
[ ] Shortcut
[ ] 叼取中断
[ ] Reset
```

## 7.3 L11

```text
[ ] 三线程并发
[ ] 至少一次主动放弃当前互动并赶场
[ ] 事件顺序错误但可诊断
[ ] 最后一秒救场
[ ] Shortcut
[ ] 怀疑值不异常漂移
```

## 7.4 L12

```text
[ ] A+B+C
[ ] A+B
[ ] A+C
[ ] B+C
[ ] A
[ ] B
[ ] C
[ ] None
[ ] Phase 2 玩家仍主动移动
[ ] Emergency Rescue
[ ] Boss Retreat
[ ] Reset
```

---

# 8. 第三章 Playtest Gate

沿用 v1.1 第三关 Gate，并把问题具体化：

8 名未体验玩家中至少：

- 5 人在 Boss 前主动准备。
- 5 人在 Boss 战中持续移动。
- 4 人主动处理 Phase 2 蒺藜。
- 4 人能够说出至少一个 Boss 伤害来源。
- 4 人理解 Emergency 是补救，不是主路线。

若玩家普遍变成：

> “把机关全弄完，然后看 Boss。”

则 Boss 结构返工，而不是继续调数值。

---

# 9. 第三章视觉白盒原则

## L09

雨 + 闪电作为空间分区提示。

## L10

炸药区必须有明显的风险阅读层级。

## L11

三个线程使用不同地标识别：

```text
守卫线 = 城墙/门
动物线 = 庭院/犬舍
环境线 = 箱区/毒雾
```

## L12

Boss Arena 必须让玩家一眼看懂三个机关的位置，但不能直接告诉最佳顺序。

---

# 10. 第三章完成定义

第三章白盒通过条件：

```text
L09 可稳定通关
AND
L10 至少一条稳定因果链成立
AND
L11 三线程压力成立
AND
L12 Boss 主动操作成立
AND
所有 LevelValidator = PASS
AND
所有 Critical Event 均可重置
```

第三章通过后，12 关主线白盒全部形成闭环。
