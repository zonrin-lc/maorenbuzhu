# 《猫忍不住》v1.2.2 · 第一章白盒地图蓝图

> 用途：给 Godot 关卡设计师 / 程序直接搭建第一章 L01-L04。
>
> 本文件不修改玩法规则，只把 v1.2.1 Level Implementation Spec 转成“地图图纸 + 节点清单 + 测试锚点”。

---

# 0. 白盒统一规则

## 0.1 TileGrid

- `G(x,y)`：TileGrid 坐标。
- 原点为关卡左上角 `(0,0)`。
- 角色可通行区域优先使用整数格。
- EventPoint 放在 Ninja Route 附近，但不要与主路线重叠。

## 0.2 图例

```text
S   猫/忍者 Start
N   Ninja Route Anchor
E1  EventPoint 1
E2  EventPoint 2
E3  EventPoint 3
E4  EventPoint 4
C   可搬运箱 / Carryable
T   CatTunnel
J   JumpPoint / 快捷跳跃
G   Goal
V   Guard Vision / 视线测试区
D   Dog
P   Poison / Hazard
#   不可通行墙体 / 场景边界
.   可通行地面
~   水面 / 间隔
*   可进入但承担风险的路径
>[0m  Ninja Route 行进方向
```

## 0.3 每张图的实际节点结构

```text
LxxRoot
├─ Environment
│  ├─ Ground
│  ├─ Collision
│  └─ SetDress
├─ Navigation
│  ├─ CatWalkable
│  ├─ CatTunnel
│  └─ JumpPoints
├─ NinjaRoute
│  ├─ RoutePoint_00
│  ├─ RoutePoint_01
│  └─ ...
├─ EventPoints
│  ├─ E01
│  ├─ E02
│  └─ ...
├─ Actors
│  ├─ Cat
│  ├─ NinjaBlue
│  └─ NPCs
├─ Collectibles
├─ Audio
├─ Cameras
└─ Debug
```

---

# 1. L01《第一份差事》

## 1.1 设计目标

只教一件事：

> **猫必须跑到忍者前面。**

地图必须让玩家一眼看到“危险就在路线前方”，不能用复杂岔路干扰教学。

## 1.2 尺寸

```text
26 × 14 tile
```

## 1.3 区域矩形

```text
Start          G(2,6)  - G(6,10)
Tripwire Alley G(7,4)  - G(11,10)
Guard Plaza    G(12,3) - G(18,10)
Watergap       G(19,5) - G(23,10)
Goal           G(24,6) - G(25,9)
```

## 1.4 白盒俯视草图

```text
y00  ##########################
y01  #........................#
y02  #........................#
y03  #..........######........#
y04  #......###.E1.####.......#
y05  #......#.....###....~~~~.#
y06  #..S...#..N01.........E3#G#
y07  #..S...#......N02...~~~~.#
y08  #..S...#..E1.........C...#
y09  #......#.......N03...~~~~.#
y10  #......###...............#
y11  #........................#
y12  #........................#
y13  ##########################
```

> 说明：实际搭图时 E1 只占一个逻辑点；上图用于表达空间关系，不作为逐格碰撞数据。

## 1.5 路线

```text
N00 Start
  ↓
N01 AlleyEntry
  ↓
N02 Tripwire
  ↓
N03 PlazaEntry
  ↓
N04 Guard
  ↓
N05 Watergap
  ↓
N06 Goal
```

推荐坐标：

| Anchor | 坐标 | 说明 |
|---|---|---|
| N00 | G(5,8) | 出发 |
| N01 | G(9,8) | 绊绳前 |
| N02 | G(10,7) | 绊绳踩踏线 |
| N03 | G(13,7) | 进入守卫区 |
| N04 | G(16,7) | 守卫事件 |
| N05 | G(21,7) | 水沟前 |
| N06 | G(24,7) | 终点 |

## 1.6 EventPoint

### E01 Tripwire

```text
position      G(10,6)
trigger_actor Ninja
solution      BITE
risk_solution LAST_SECOND_BITE
```

交互区：`[3×2 tile[0m`。

猫必须能从侧方接近，不允许只有单一进出方向。

### E02 Guard

```text
position       G(16,6)
solution       MEOW_LURE
risk_solution  CLOSE_PASS
```

Guard 初始视线朝右；玩家可从视线背面绕行。

### E03 Watergap

```text
position       G(21,7)
solution       PUSH_CRATE
risk_solution  NARROW_JUMP
```

## 1.7 时间锚点

```text
T+00  Ninja Start
T+05  RoutePoint_01
T+12  Tripwire danger
T+18  Guard danger
T+30  Watergap hesitate
T+33  Watergap decision end
T+40~50 Goal
```

## 1.8 L01 不允许出现

- 第二条真正等价主路线
- 多个可搬运物争抢
- 多名守卫
- Dog
- Poison
- Caltrop
- Boss

## 1.9 L01 Godot 任务

```text
[ ] 创建 L01 scene
[ ] 铺 26×14 白盒碰撞
[ ] 放置 N00-N06
[ ] 放置 E01-E03
[ ] 放置 1 个可搬运箱
[ ] 接入 CatController
[ ] 接入 NinjaController
[ ] 接入 Tripwire / Guard / Watergap
[ ] 打通 Reset
[ ] LevelValidator 无路径错误
```

---

# 2. L02《他总是踩同一个坑》

## 2.1 设计目标

第一次让玩家发现：

> **跟着忍者跑，必然来不及。**

重点不是增加更多机制，而是第一次制造“赶场”的节奏。

## 2.2 尺寸

```text
30 × 14 tile
```

## 2.3 地图结构

```text
Start → Narrow Alley → Plaza → Waterline → Goal
                ↘ Shortcut ↗
```

## 2.4 草图

```text
##############################
#............................#
#..S.........................#
#..S....########.............#
#..S....# E1   #......E2.....#
#.......#      #.............#
#.......###J####....######...#
#..........T........# E3 #G.#
#...................#....#..#
#...................######..#
#............................#
#............................#
#............................#
##############################
```

## 2.5 主要路线

```text
N00 Start
→ N01 E01 Tripwire
→ N02 Plaza
→ N03 E02 Guard
→ N04 Waterline
→ N05 E03 Watergap
→ N06 Goal
```

## 2.6 猫快捷路线

```text
J01 / T01
Start Side
   ↓
CatTunnel
   ↓
JumpPoint
   ↓
Plaza Backside
```

要求：

- 捷径缩短猫移动距离。
- 不改变 Ninja Route。
- 不让玩家第一次看到捷径就误以为必须走捷径。

## 2.7 事件节奏

```text
E01：玩家学会“提前跑”
↓
E02：守卫制造第一次绕路
↓
E03：忍者犹豫
↓
玩家需要连续赶场
```

## 2.8 Variant B

只改变：

```text
Guard start_position
Guard route direction
E02 trigger_offset
```

禁止改变：

```text
事件数量
地图外形
核心交互
```

## 2.9 QA 关键问题

观察测试者是否会：

```text
跟着 Ninja 一起跑
→ 发现来不及
→ 第二次主动提前跑
```

如果大量玩家第一次就直接贴着 Ninja 跑并且不认为有问题，需调整 E01→E02 的距离与 Ninja 节奏，而不是给文字提示。

---

# 3. L03《谁在看猫》

## 3.1 设计目标

单独建立 Suspicion 的心智模型：

```text
被看见 ≠ 可疑
做事被看见 = 怀疑增加
离开 = 停止新增
卖萌 = 清除已有怀疑
```

## 3.2 尺寸

```text
32 × 16 tile
```

## 3.3 区域

```text
Start
↓
Guard Vision Yard
↓
Crate Yard
↓
Emote Shelter
↓
Watergap
↓
Goal
```

## 3.4 草图

```text
################################
#..............................#
#..S...........VVVVVV..........#
#..S..........VV....VV.........#
#..S..........V..E1..V.........#
#.............V......V.........#
#.......#######......####......#
#.......# E2  #......#  T #....#
#.......# C   #......#    #....#
#.......######..E3...####J#G...#
#..............................#
#..............................#
#..............................#
#..............................#
#..............................#
################################
```

## 3.5 Event

### E01 Guard Passive

Guard 只巡视。

目标：允许玩家安全从视线中走过，证明“看到猫”并不等于怀疑。

### E02 Steal Crate

箱子位于 Guard 边缘视线内。

流程：

```text
偷箱
→ suspicion +
→ 玩家离开视线
→ suspicion 不再增加
→ Ctrl
→ suspicion 清除
```

### E03 Emote Check

单独放一个安全的卖萌位置。

目的不是奖励，而是让玩家自己发现：

> 卖萌是资源。

## 3.6 QA 五态矩阵

| 场景 | 预期 |
|---|---|
| 被看见但没做事 | 不加怀疑 |
| 被看见正在搬箱 | 加怀疑 |
| 搬完马上离开 | 停止继续累积 |
| 离开后不卖萌 | 已有怀疑保留 |
| 离开后卖萌 | 已有怀疑清除 |

## 3.7 Godot 锚点

```text
SuspicionEmitterVolume
SuspicionObserver
EmoteSafeZone
```

这三个节点应独立于 Guard Actor，以便以后换 NPC 不改关卡逻辑。

---

# 4. L04《村口大事故》

## 4.1 设计目标

第一章终局：第一次让玩家真正解一个“顺序题”。

核心关系：

```text
Guard A
   ↓
Tripwire
   ↓
Crate
   ↓
Watergap
```

## 4.2 尺寸

```text
34 × 18 tile
```

## 4.3 白盒分区

```text
West Gate
    ↓
Guard Square
    ↓
Tripwire Alley ── Cat Shortcut ── Riverbank
    ↓                    ↑
Crate Yard ──────────────┘
    ↓
Watergap
    ↓
Village Goal
```

## 4.4 草图

```text
##################################
#................................#
#..S.............................#
#..S....########.................#
#..S....# E1   #......T..........#
#.......#      #......T..........#
#.......# E2   ######J######....#
#.......#######......# E3 #....#
#....................# C  #....#
#..............E4....####J#G...#
#................................
#................................
#................................
#................................
#................................
#................................
#................................
##################################
```

## 4.5 两条有效主路线

### Route A：稳健

```text
E01 Guard A
→ E02 Tripwire
→ E03 Crate
→ E04 Watergap
→ Goal
```

### Route B：快捷

```text
E02 Tripwire
→ E01 Guard A
→ Cat Shortcut
→ E04 Watergap
→ Goal
```

## 4.6 关键设计

两条路线都必须能完整通关。

但：

```text
Route A
风险低 / 时间正常

Route B
移动压力更高 / 时间更快
```

不要把“路线 B”标成“正确答案”。

## 4.7 失败设计

禁止：

```text
错误顺序
→ 永久 Softlock
```

允许：

```text
错误顺序
→ 当前事件失败
→ Ninja HP 受损或路线变化
→ 玩家理解原因
→ Reset
```

## 4.8 第一章章节结算

L04 完成后触发章节总结：

```text
村庄篇完成
↓
Ninja 在居酒屋吹牛
↓
系统统计：
“提前处理”次数
“险中救场”次数
“怀疑最高值”
↓
解锁 Chapter 2
```

章节总结不加额外强力数值，只负责建立成长反馈。

---

# 5. 第一章统一 Data Resource

推荐：

```text
res://data/levels/chapter_01/
├─ L01_FirstJob.tres
├─ L02_SamePit.tres
├─ L03_WhoWatching.tres
├─ L04_VillageAccident.tres
├─ L01_FirstJob_Route_A.tres
├─ L02_SamePit_Route_A.tres
├─ L03_WhoWatching_Route_A.tres
├─ L04_VillageAccident_Route_A.tres
└─ variants/
   ├─ L02_SamePit_B.tres
   └─ L04_VillageAccident_B.tres
```

## 5.1 EventData

每个事件至少：

```text
id
position
trigger_route_point
actor_id
event_type
solutions[]
risk_solution
fail_codes[]
world_flags_before[]
world_flags_after[]
time_window
```

## 5.2 L04 示例

```text
id = L04_E01
actor_id = guard_a
event_type = GUARD
trigger_route_point = N02
solutions = [MEOW_LURE, BYPASS]
risk_solution = CLOSE_PASS
fail_codes = [FAIL_TOO_LATE, FAIL_SUSPICION]
world_flags_after = [guard_a_departed]
```

---

# 6. 第一章 Debug Overlay

开发版必须支持一键显示：

```text
[Route]
N00 N01 N02 ...

[Events]
E01 E02 E03 ...

[WorldState]
guard_a_departed = true/false
bridge_open = true/false

[Timing]
Ninja ETA
Event ETA
Player ETA

[Suspicion]
Current
Max
State

[Score]
Paw1
Paw2
Paw3 conditions
```

## 6.1 推荐热键

```text
F1  Debug Overlay
F2  Force Next Event
F3  Toggle Ninja Route
F4  Toggle Event Bounds
F5  Reset Level
F6  Restart from Checkpoint（开发版）
F7  Trigger Variant B
```

---

# 7. 第一章制作顺序

```text
Day A
L01 Geometry
→ Route
→ Events
→ Playtest

Day B
L02 Geometry
→ Shortcut
→ Timing
→ Playtest

Day C
L03 Suspicion
→ Guard Vision
→ Emote
→ Playtest

Day D
L04 Dependency
→ 2 Routes
→ Failure Recovery
→ Playtest

Day E
Chapter 01 Blind Test
→ Balance
→ Art Pass
```

具体工时不在本文冻结，由团队产能决定。

---

# 8. 第一章通过标准

四关全部满足：

```text
[ ] Ninja Route 无自由寻路依赖
[ ] EventPoint 可独立测试
[ ] Reset 无残留 WorldState
[ ] 玩家可提前赶场
[ ] 失败原因可解释
[ ] 无不可逆 Softlock
[ ] L04 两条有效主路线
[ ] L03 怀疑五态矩阵全通过
[ ] Chapter 01 Blind Test 达标
[ ] LevelValidator 全绿
```

第一章完成标准不是“地图漂亮”，而是：

> **玩家已经从“跟着忍者跑”转变成“我提前安排他会遇到什么”。**
