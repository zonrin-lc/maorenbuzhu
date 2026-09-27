# 《影猫》v1.1 制作执行包 · Level Bible

> 状态：Production Candidate 基线
>
> 目标：把三关从“策划描述”落到可以由关卡设计师在 Godot 中逐项搭建的空间、事件、路线、资源和验证清单。

---

# 0. 统一关卡模板

每个关卡必须拥有：

```text
LevelData
RouteData
EventPointData[]
ShortcutData[]
WorldFlagData
ScoreRuleData
Banters
AudioMap
ValidationRules
```

场景模板：

```text
LevelRoot
├─ World
├─ Navigation
├─ Actors
├─ Interactables
├─ Routes
├─ Goals
├─ Collectibles
└─ SpawnMarkers
```

---

# 1. L01《初出茅庐》

## 1.1 产品目标

关键词：**行动**

玩家必须理解：

```text
忍者按路线前进
↓
我提前跑到前方
↓
我处理危险
↓
忍者安全通过
```

并建立第一次怀疑系统认知：

```text
被看到 ≠ 可疑
做事被看到 = 怀疑
卖萌 = 清除累积怀疑
```

## 1.2 推荐场景结构

```text
L01_Village
├─ World
│  ├─ Road
│  ├─ Houses
│  ├─ Fence
│  └─ Watergap
├─ Actors
│  ├─ Cat
│  ├─ NinjaBlue
│  └─ Guard
├─ Interactables
│  ├─ Tripwire
│  ├─ GuardEvent
│  ├─ Crate
│  ├─ PotOptional
│  └─ FishOptional
├─ Routes
│  └─ NinjaRoute_Main
├─ Shortcuts
│  ├─ JumpPoint_A
│  └─ CatTunnel_A
├─ Goal
└─ Debug
```

## 1.3 区域分块

| 区 | 目的 | 关卡设计要求 |
|---|---|---|
| Spawn | 低风险观察 | 玩家能看到忍者路线 |
| Teach | 第一事件 | Tripwire 易观察 |
| Rush | 第一次赶场 | 给猫足够提前空间 |
| Guard | 怀疑教学 | 玩家可被看到但仍有回旋余地 |
| Watergap | 第一次复合操作 | 使用木箱或绕路 |
| Goal | 收束 | 忍者完成路线 |

## 1.4 事件清单

### L01-E01 Tripwire

分类：CRITICAL

目标：让玩家第一次提前赶场。

必须：

- 玩家可观察绊绳
- 猫可互动解除
- 至少存在直接拆除与快速处理两种行为表现
- 失败可归因 `FAIL_TOO_LATE`

### L01-E02 Guard

分类：CRITICAL

目标：建立“猫出现不等于危险”。

关键变量：

```text
player_visible
player_action_seen
suspicion_value
emote_available
```

必须存在：

- 正常经过猫
- 猫进行可疑操作
- 被注意后卖萌

### L01-E03 Watergap

分类：CRITICAL

目标：第一次理解环境调度。

建议解法：

```text
Carry Crate → Bridge
```

以及：

```text
Shortcut → JumpPoint
```

失败主要是：

`FAIL_TOO_LATE`

`FAIL_ROUTE_BLOCKED`

## 1.5 Optional

- Pot
- Fish

不影响主线与猫爪核心。

## 1.6 时间

```text
新玩家：35–70s
熟练：25–40s
三猫爪目标：<= 60s
```

## 1.7 关卡变体

### Variant A

绊绳固定；Guard 默认巡逻方向。

### Variant B

Guard 巡逻方向改变，其他关系保持可预测。

两个变体不改变基础教学对象。

## 1.8 L01 关卡制作清单

```text
[ ] TileMap / TileMapLayer
[ ] Ninja Route
[ ] Spawn
[ ] Goal
[ ] E01 Tripwire
[ ] E02 Guard
[ ] E03 Watergap
[ ] JumpPoint
[ ] CatTunnel
[ ] Optional Pot
[ ] Optional Fish
[ ] Suspicion indicators
[ ] Tutorial prompts
[ ] AudioMap
[ ] Boast tags
[ ] LevelValidator rules
[ ] Variant A
[ ] Variant B
```

---

# 2. L02《月夜码头》

## 2.1 产品目标

关键词：**规划**

玩家必须学会：

> 不是看到危险就立刻处理，而是先判断顺序。

核心因果：

```text
A 离岗
↓
B 换岗
↓
Dog 改变 Guard
↓
Bridge / Caltrop 窗口改变
↓
Antidote 运输
↓
Goal
```

## 2.2 推荐场景结构

```text
L02_Dock
├─ World
│  ├─ DockFloor
│  ├─ Water
│  ├─ Bridge
│  ├─ Warehouse
│  └─ BoatProps
├─ Actors
│  ├─ Cat
│  ├─ NinjaBlue
│  ├─ GuardA
│  ├─ GuardB
│  └─ Dog
├─ Interactables
│  ├─ GuardAEvent
│  ├─ DogEvent
│  ├─ GuardBEvent
│  ├─ BridgeEvent
│  ├─ PoisonEvent
│  └─ CaltropEvent
├─ Carryables
│  ├─ Fish
│  ├─ Crate
│  └─ Antidote
├─ Shortcuts
│  ├─ JumpPoint_A
│  ├─ JumpPoint_B
│  └─ CatTunnel_A
├─ Routes
└─ Goal
```

## 2.3 事件依赖图

```text
Guard A
  └→ Guard B positioning

Dog
  └→ Guard B positioning

Guard B
  └→ Bridge timing

Poison
  └→ Antidote requirement

Caltrop
  └→ Ninja damage risk

Antidote
  └→ Goal safety
```

## 2.4 事件清单

### L02-E01 Guard A

CRITICAL

作用：开始改变世界状态。

成功后：

```text
guard_a_departed = true
```

### L02-E02 Dog

CRITICAL

建议行为链：

```text
Fish
→ Dog FED
→ Bark
→ Guard B reposition
```

### L02-E03 Guard B

CRITICAL

行为由 WorldState 驱动。

不要让 Guard B 重新自由判断，而是进入预设 AlternativeRoute。

### L02-E04 Bridge

CRITICAL

玩家可用：

- Crate
- Bridge switch
- JumpPoint

### L02-E05 Poison

CRITICAL

玩家需要先考虑 Antidote 的运输。

### L02-E06 Caltrop

STANDARD

功能主要是：

- 时间窗口
- 风险路线
- 备选捷径

## 2.5 L02 资源冲突设计

关键资源：

```text
鱼
木箱
解毒药
猫的移动时间
怀疑值
```

目标：让玩家理解“动作顺序”比“单点处理速度”更重要。

## 2.6 Shortcut

至少 2 个。

要求：

- 不只是少走几步
- 最好改变事件时序
- 必须存在可解释的 trade-off

## 2.7 失败清单

```text
FAIL_TOO_LATE
FAIL_WRONG_ORDER
FAIL_SUSPICION
FAIL_ROUTE_BLOCKED
FAIL_NINJA_DEATH
```

## 2.8 关卡变体

### Dock A

Guard B 正常补位。

### Dock B

Dog 起始位置不同，但因果关系不变。

## 2.9 L02 关卡制作清单

```text
[ ] Dock World
[ ] Guard A
[ ] Dog
[ ] Guard B
[ ] Bridge
[ ] Poison
[ ] Antidote
[ ] Caltrop
[ ] Carry Crate
[ ] Fish
[ ] >=2 Shortcuts
[ ] NPC state machines
[ ] WorldState flags
[ ] Cause chain validation
[ ] Variant A
[ ] Variant B
[ ] Boast tags
[ ] AudioMap
[ ] LevelValidator
```

---

# 3. L03《天守阁》

## 3.1 产品目标

关键词：**操纵**

玩家已经掌握：

- 提前准备
- 排顺序
- NPC 联动
- Carry
- Shortcut

第三关要求：

> Boss 开始行动后，玩家仍必须继续主动处理场地。

## 3.2 推荐场景结构

```text
L03_Castle
├─ World
│  ├─ CastleFloor
│  ├─ Courtyard
│  ├─ Corridors
│  ├─ Cliffs
│  └─ BossArena
├─ Actors
│  ├─ Cat
│  ├─ NinjaBlue
│  ├─ GuardA
│  ├─ GuardB
│  ├─ Dog
│  └─ Boss
├─ Interactables
│  ├─ Tripwire
│  ├─ Dynamite
│  ├─ GuardAEvent
│  ├─ DogEvent
│  ├─ Caltrop
│  ├─ Cliff
│  ├─ Poison
│  ├─ GuardBEvent
│  ├─ Crane
│  └─ Gourd
├─ BossArena
│  ├─ BossSpawn
│  ├─ CaltropZone
│  ├─ CraneZone
│  ├─ GourdZone
│  └─ EmergencyDoor
├─ Routes
└─ Goal
```

## 3.3 普通事件

### L03-E01 Tripwire

STANDARD

复用第一关认知，缩短处理时间。

### L03-E02 Dynamite

CRITICAL

高风险环境事件。

建议玩家必须先读懂影响范围，而不是直接尝试靠近。

### L03-E03 Guard A

CRITICAL

用于制造进入 Boss 区前的路线压力。

### L03-E04 Dog

CRITICAL

复用第二关机制，但与另一事件形成因果链。

### L03-E05 Caltrop

CRITICAL

普通事件与 Boss 机制共用视觉语言，但语义必须明确。

### L03-E06 Cliff

STANDARD

作为移动路线约束。

### L03-E07 Poison

CRITICAL

再次调用搬运 / Antidote 逻辑。

### L03-E08 Guard B

STANDARD

用于进入 Boss 前最后一次路线扰动。

---

# 4. Boss 关卡

## 4.1 Boss 三机制

| Mechanic | 准备 | 最佳时机 | 作用 |
|---|---:|---:|---|
| Crane | 是 | Phase 1 | 提前计划 |
| Caltrop | 可提前 | Phase 2 | 战中救场 |
| Gourd | 是 | Intro | 延迟/保底 |

## 4.2 Boss Flow

```text
Boss Intro
↓
Boss Prepare
↓
Phase 1
  └─ Crane
↓
Phase 2
  └─ Caltrop active window
↓
Phase 3
  └─ HP check
↓
Defeated / Retreat
```

### Phase 1 关卡制作

玩家可以提前站位并触发吊车。

但不能让所有后续事件在这里一次性自动解决。

### Phase 2 关卡制作

这是第三关最重要的实时调度区。

要求：

```text
Boss already moving
+
Caltrop window open
+
Cat must physically reach zone
```

不能做成“战前点击一下，战中自动触发”。

### Emergency Rescue

Boss Finish + Ninja HP <= 1：

```text
EmergencyDoor
→ player interaction
→ 1.5–2s window
→ save at 1 HP
→ mission complete
→ 1 paw
```

## 4.3 Boss 玩家主动性 Gate

内部测试至少观察：

> 60% 测试玩家在 Boss 已开始行动后仍继续移动处理机关。

低于该值：返工关卡结构。

---

# 5. L03 评分重点

第三关三猫爪：

基础资格：

```text
mission_complete
AND ninja_hp >= 2
```

A–G 满足 4 项：

```text
A ninja_hp = 3
B max_suspicion < 50
C elapsed_time <= target_time
D high_risk_rescue >= 1
E chain_rescue >= 1
F shortcut_or_dependency_mastery
G boss_mechanics_success >= 2
```

Emergency Rescue 不计入正向评分指标。

---

# 6. 三关共享事件制作规范

每个事件必须填写：

| 字段 | 必填 |
|---|---:|
| EventID | ✓ |
| Classification | ✓ |
| Goal | ✓ |
| Trigger | ✓ |
| Success | ✓ |
| Failure | ✓ |
| FailCode | ✓ |
| WorldState delta | ✓ |
| Player risk | ✓ |
| Ninja reaction | ✓ |
| Shortcut | 有则填 |
| CausedEvent | 有则填 |
| Boast tags | ✓ |
| AudioMap key | ✓ |
| Validator rule | ✓ |

---

# 7. CRITICAL / STANDARD / OPTIONAL

## CRITICAL

- 至少 2 个解法
- 高风险解
- 因果关系
- 完整 QA

## STANDARD

- 1 个稳定标准解
- 1 个高风险解或捷径解
- 完整失败出口

## OPTIONAL

- 收藏 / 彩蛋
- 不影响主线
- 不影响忍者存活
- 不影响主评分核心

---

# 8. 关卡可读性标准

第一眼必须能辨认：

```text
忍者路线
危险区
猫的捷径
可搬运物
目标位置
```

禁止：

- 用颜色作为唯一危险提示
- 事件触发器看不见且无环境暗示
- Ninja Route 与危险边界没有空间关系

---

# 9. 三关最终制作顺序

```text
L01 Whitebox
→ L01 Playtest Gate
→ L01 Art Lock

L02 Whitebox
→ L02 Cause Chain Gate
→ L02 Art Lock

L03 Whitebox
→ Boss Activity Gate
→ L03 Art Lock
```

不要三关同时精修。

---

# 10. LevelValidator 专项

## L01

```text
[ ] Tripwire reaches Ninja before resolver window
[ ] Guard has suspicion test
[ ] Watergap has >=1 valid route
[ ] Optional items do not block main route
```

## L02

```text
[ ] GuardA flag changes GuardB route
[ ] Dog event changes Guard state
[ ] Antidote is reachable
[ ] At least 2 shortcuts exist
[ ] Wrong-order failure is reproducible
```

## L03

```text
[ ] Boss Intro exists
[ ] Crane path valid
[ ] Caltrop Phase2 window valid
[ ] Gourd timing valid
[ ] Emergency window valid
[ ] Boss can end for all valid mechanic combinations
[ ] No soft-lock after Boss Retreat
```

---

# 11. 关卡数据文件命名

```text
levels/
├─ l01_village.tres
├─ l02_dock.tres
└─ l03_castle.tres

routes/
├─ l01_main_route.tres
├─ l01_variant_b.tres
├─ l02_main_route.tres
├─ l02_variant_b.tres
└─ l03_main_route.tres

events/
├─ l01_e01_tripwire.tres
├─ l01_e02_guard.tres
...
└─ l03_e08_guard_b.tres

variants/
├─ l01_variant_a.tres
├─ l01_variant_b.tres
├─ l02_variant_a.tres
├─ l02_variant_b.tres
├─ l03_variant_a.tres
└─ l03_variant_b.tres
```

---

# 12. 关卡美术锁定前提

任何关卡进入最终美术前必须：

```text
[ ] Gameplay Gate 通过
[ ] Timing Gate 通过
[ ] Failure Understanding Gate 通过
[ ] LevelValidator 全绿
[ ] P0 = 0
[ ] Collision / route 完成
[ ] 所有关键事件可复现
```

---

# 13. 最终关卡体验

### L01

玩家：“原来我应该提前跑。”

### L02

玩家：“先处理谁，比怎么处理更重要。”

### L03

玩家：“战斗已经开始了，我还得继续操控整张场。”

这三句话是关卡审核时的体验验收标准。
