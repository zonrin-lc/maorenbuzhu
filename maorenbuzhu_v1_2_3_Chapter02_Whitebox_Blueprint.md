# 《猫忍不住》v1.2.3 · 第二章白盒地图蓝图

> 范围：L05《月夜码头》、L06《狗也能当队友》、L07《谁先走》、L08《最后一班船》
>
> 目的：把第二章从“组合玩法设计”进一步落实为可直接在 Godot 白盒阶段搭建的地图、路线、事件和状态关系。
>
> 本章核心学习目标：
>
> ```text
> L05 物品需要被搬到正确的位置
> ↓
> L06 NPC 可以成为玩家的工具
> ↓
> L07 顺序会改变后续世界状态
> ↓
> L08 玩家开始同时管理多个因果链
> ```

---

# 0. 第二章统一白盒规则

## 0.1 坐标

继续沿用 `G(x,y)` TileGrid 坐标，不假定最终像素尺寸。

## 0.2 场景层级

```text
LevelRoot
├─ Environment
├─ Navigation
├─ NinjaRoute
├─ EventPoints
├─ Actors
├─ Carryables
├─ CatTunnels
├─ JumpPoints
├─ Collectibles
├─ Audio
├─ Cameras
└─ Debug
```

## 0.3 第二章新出现的空间对象

```text
CarryPoint       物品可放置锚点
DogRoute         狗的固定可预测路线
GuardRoute       守卫 A/B 的固定路线
DependencyLink   事件依赖可视化
SafePocket       猫躲避/卖萌安全位
CatTunnel        忍者无法进入的捷径
```

## 0.4 第二章不增加新玩家按键

继续使用：

```text
WASD / 左摇杆 = 移动
Shift          = 疾跑
Space          = 跳跃/攀爬
E              = 情境互动
Q              = 叼取/放置
F              = 喵叫
Ctrl           = 卖萌
```

第二章的“新鲜感”来自关系和顺序，不来自新的输入设备。

---

# 1. L05《月夜码头》

## 1.1 关卡定位

这是第二章第一关。

玩家第一次进入沼泽/码头环境，同时第一次正式学习 `Q 叼取 / 放置`。

核心问题：

> “我有东西，但我要把它送到正确的位置。”

原设计中的码头已经包含守卫 ×2、恶狗、断桥、毒雾/流沙、铁蒺藜，并以威胁联动作为第二章的核心进阶。fileciteturn30file0

## 1.2 推荐白盒尺寸

```text
宽：42 tile
高：24 tile
```

## 1.3 区域规划

| 区域 | G范围 | 功能 |
|---|---|---|
| Dock Start | G(2,10)~G(6,15) | 猫/忍者出生 |
| Fish Crate Yard | G(7,5)~G(15,10) | 鱼肉获取 |
| Guard A Pier | G(16,4)~G(23,9) | 守卫 A |
| Dog Yard | G(13,11)~G(20,17) | 狗 + FishTarget |
| Broken Bridge | G(21,9)~G(29,15) | Bridge Event |
| Poison Marsh | G(28,5)~G(35,12) | Poison Event |
| Guard B Jetty | G(30,13)~G(37,19) | 守卫 B |
| Goal Boat | G(38,8)~G(41,15) | 目标 |

## 1.4 主路线

```text
R00 Start
→ R01 Fish Yard
→ R02 Guard A
→ R03 Dog Yard
→ R04 Broken Bridge
→ R05 Poison Marsh
→ R06 Guard B
→ R07 Goal
```

## 1.5 第一条因果链

```text
FishPicked
    ↓
DogDistracted
    ↓
Guard A route remains clear
    ↓
Bridge reached
    ↓
Antidote delivered
```

这里不要求玩家一次解决全部事情。

重点是让玩家开始发现：

> 一个道具的价值不在道具本身，而在它改变了谁的位置。

## 1.6 EventPoint

### E01 FishPickup

```text
event_type = CARRY_SOURCE
interact = Q
item = FISH
```

猫叼住鱼后：

```text
CARRY_SPEED_MULT = 0.85
```

沿用 v1.1 冻结参数。

### E02 GuardA

```text
event_type = GUARD
reaction = PATROL
```

基础处理：

```text
F 喵叫
→ Guard A 离开路线
```

### E03 Dog

标准解：

```text
Fish
→ Dog
→ Dog 留在原区域
```

风险解：

```text
猫自己吸引 Dog
→ 绕场
→ Guard 受影响
```

原事件设计已经定义“鱼肉吸引”和“自己当诱饵”两种思路。fileciteturn32file0

### E04 BrokenBridge

需要：

```text
BridgeReady = true
```

来源：

```text
CratePlaced = true
```

### E05 Poison

毒雾区不能通过数字 UI 告诉答案。

玩家通过：

```text
明显的毒雾视觉
+
药瓶交互
```

完成处理。

### E06 GuardB

Guard B 在白盒阶段必须有明确的：

```text
Route_A
Route_B
```

两段路线。

## 1.7 空间捷径

至少 1 条：

```text
CatTunnel_A
```

猫从守卫区域下方穿过。

忍者不能进入该区域。

## 1.8 目标体验

第一次完成时玩家可能是：

```text
只会逐个解决事件
```

但通关后应该意识到：

> “下次我应该先拿东西。”

## 1.9 Godot 文件

```text
Scene:
scenes/levels/chapter_02_dock/L05_MoonlitDock.tscn

LevelData:
data/levels/chapter_02/L05_MoonlitDock.tres

RouteData:
data/routes/chapter_02/L05_MoonlitDock_Route_A.tres

EventData:
data/events/chapter_02/L05/*.tres

Variant:
data/variants/chapter_02/L05_MoonlitDock_B.tres
```

## 1.10 白盒 QA

```text
[ ] 猫可以拿到 Fish
[ ] Q 叼取后速度下降
[ ] Dog 能进入 Distracted
[ ] Guard A 能被改变位置
[ ] Bridge 能从 WorldState 打开
[ ] 毒雾失败/成功状态可重复
[ ] Guard B 不会进入自由寻路
[ ] 猫捷径不允许忍者通过
[ ] Reset 后所有 Flag 清零
```

---

# 2. L06《狗也能当队友》

## 2.1 关卡定位

这一关不再把 Dog 当作单纯障碍。

玩家需要意识到：

> **NPC 可以成为工具。**

## 2.2 白盒尺寸

```text
46 × 26 tile
```

比 L05 更宽，避免复杂度来自狭窄通道。

## 2.3 区域

```text
Start
↓
Crate Storage
├─ Fish Source
└─ Cat Tunnel
↓
Guard Square
├─ Guard A
└─ Guard B
↓
Dog Pen
↓
Bridge Fork
↓
Goal
```

## 2.4 核心事件关系

```text
Dog
├─ Fish
│   └─ Dog stays 20s
│
└─ Cat Lure
    └─ Dog follows Cat
         ↓
      Guard notices movement
         ↓
      Guard position changes
```

## 2.5 标准解

```text
拿鱼
→ 喂狗
→ 狗离开守卫主线
→ Guard 位置稳定
→ Ninja 安全通过
```

## 2.6 风险解

```text
不喂狗
→ 猫进入 Guard 区
→ F/移动制造干扰
→ 狗追猫
→ Guard 被吸引
→ Ninja 从另一侧通过
```

## 2.7 关键设计

不能让风险解成为唯一优解。

两条路线必须都能完成任务：

```text
SAFE
BALANCED
RISKY
```

由玩家自己的操作生成，而不是关卡直接给标签。

## 2.8 EventPoint

```text
E01 = FISH_SOURCE
E02 = DOG_PEN
E03 = GUARD_A
E04 = GUARD_B
E05 = BRIDGE_FORK
E06 = GOAL
```

## 2.9 DogRoute

狗必须使用离散路线：

```text
D00 Pen
→ D01 SmellFish
→ D02 Follow
→ D03 BarkStop
→ D04 Return
```

禁止 NavigationAgent 自由追猫。

“狗蠢”必须可预测。

## 2.10 失败出口

```text
FAIL_TOO_LATE
FAIL_WRONG_ORDER
FAIL_NINJA_DEATH
FAIL_SUSPICION
```

## 2.11 Godot 文件

```text
Scene:
scenes/levels/chapter_02_dock/L06_DogAlly.tscn

LevelData:
data/levels/chapter_02/L06_DogAlly.tres

DogRoute:
data/routes/chapter_02/L06_Dog_Route.tres

Events:
data/events/chapter_02/L06/*.tres
```

## 2.12 QA Gate

新玩家中至少多数玩家应尝试一次：

```text
Fish → Dog
```

否则说明 Dog 的“可利用性”读图不足。

---

# 3. L07《谁先走》

## 3.1 关卡定位

第二章真正的“顺序关”。

核心问题：

> “不是我会不会处理，而是我先处理谁。”

## 3.2 白盒尺寸

```text
48 × 26 tile
```

## 3.3 地图分区

```text
            Guard A
               │
               ▼
Start → Fish Yard → Dog Yard → Bridge
               │                  │
               ▼                  ▼
            Guard B ← Poison ← Shortcut
                                  │
                                  ▼
                                 Goal
```

## 3.4 核心依赖

```text
Guard A Departed
        ↓ 8s
Guard B Shifted
        ↓
Bridge Window Open
        ↓
Poison Route Available
```

这是整个第二章最重要的依赖链。

## 3.5 玩家错误也必须“合理”

错误顺序：

```text
先处理 Guard B
```

并不能直接提示：

> “顺序错了。”

而是世界产生后果：

```text
Guard B 提前站位
→ Bridge 被堵
→ Ninja 改走 Poison Route
→ Ninja 进入危险
```

玩家自己从结果推断顺序。

## 3.6 Event Dependency Graph

```text
E01 GuardA
  ↓
W01 guard_a_departed
  ↓ +8s
E02 GuardB
  ↓
W02 guard_b_active
  ↓
E03 Bridge
  ↓
W03 bridge_open
  ↓
E04 Poison
```

## 3.7 标准解

```text
Guard A
→ 等待/赶场
→ Guard B
→ Bridge
→ Poison
→ Goal
```

## 3.8 风险解

```text
Guard A
→ Dog
→ Guard B
→ Shortcut
→ Bridge
```

要求玩家更准确地利用 NPC 联动。

## 3.9 关键白盒测试

测试者失败后必须能回答：

> “我为什么要先处理 Guard A？”

答案可以是自己的语言，但必须指出后续状态变化。

## 3.10 Godot 文件

```text
Scene:
scenes/levels/chapter_02_dock/L07_WhoMovesFirst.tscn

LevelData:
data/levels/chapter_02/L07_WhoMovesFirst.tres

DependencyData:
data/dependencies/chapter_02/L07_WhoMovesFirst_Dependency.tres

Events:
data/events/chapter_02/L07/*.tres
```

---

# 4. L08《最后一班船》

## 4.1 关卡定位

第二章章节终关。

目标不是增加全新机制，而是让玩家同时面对：

```text
资源有限
+
NPC 联动
+
事件顺序
+
时间窗口
+
风险选择
```

## 4.2 白盒尺寸

```text
54 × 28 tile
```

这是第一章以来第一个明显“横向多线程”地图。

## 4.3 区域

```text
A Start
│
├── B Fish/Crate Yard
│
├── C Guard A Pier
│
├── D Dog Yard
│
├── E Broken Bridge
│
├── F Poison Marsh
│
├── G Guard B Jetty
│
├── H Caltrop Dock
│
└── I Final Boat
```

## 4.4 三条工作线

### 工作线 1：守卫

```text
Guard A
→ Guard B
```

### 工作线 2：动物

```text
Fish
→ Dog
→ Guard Position
```

### 工作线 3：运输

```text
Crate
→ Bridge
→ Poison
→ Goal
```

三条线最后汇合。

## 4.5 资源冲突

这一关故意只有有限数量的关键道具刷新点：

```text
Fish ×1
Crate ×1
Antidote ×1
```

不是随机消耗。

而是玩家必须考虑：

> “我现在拿这个，会不会影响后面的时间？”

## 4.6 核心路线

### 稳健

```text
Fish
→ Dog
→ Guard A
→ Bridge
→ Antidote
→ Guard B
→ Goal
```

### 调度

```text
Guard A
→ Fish
→ Dog
→ Shortcut
→ Bridge
→ Guard B
→ Goal
```

### 风险

```text
Cat Lure
→ Dog Chase
→ Guard Shift
→ Narrow Shortcut
→ Bridge
→ Emergency Move
```

风险路线允许更高 `high_risk_rescue` 与 `chain_rescue` 记录，但不允许通过故意让 Ninja 低血刷三猫爪。

## 4.7 Caltrop 的作用

第二章的蒺藜在这里只承担：

> “迫使玩家留意 Ninja 下一阶段路线。”

不把它做成 Boss 级复杂机制。

因此它属于 `STANDARD`。

## 4.8 船离港时间

加入一个纯关卡计时器：

```text
SHIP_WINDOW = 90s ~ 120s
```

注意：

它只控制：

```text
Goal 可进入窗口
```

不直接倒计时致死。

这样玩家不会把关卡理解成传统限时跑酷。

## 4.9 章节终关演出

当 Ninja 到达船边：

```text
船夫看向 Ninja
→ Ninja 摆 pose
→ 风吹起斗篷
→ 猫蹲在货箱上
```

Ninja：

> “我一到码头，连海风都顺着我吹。”

猫：

> “……”

## 4.10 Godot 文件

```text
Scene:
scenes/levels/chapter_02_dock/L08_LastBoat.tscn

LevelData:
data/levels/chapter_02/L08_LastBoat.tres

RouteData:
data/routes/chapter_02/L08_LastBoat_Route_A.tres

DependencyData:
data/dependencies/chapter_02/L08_LastBoat_Dependency.tres

Events:
data/events/chapter_02/L08/*.tres

Variant:
data/variants/chapter_02/L08_LastBoat_B.tres
```

---

# 5. 第二章统一 WorldState

第二章使用的世界事实只允许来自以下集合或其正式扩展：

```text
guard_a_departed
guard_b_active
dog_fed
dog_distracted
dog_returning
fish_taken
fish_consumed
bridge_open
bridge_blocked
poison_route_safe
antidote_placed
caltrop_ready
ship_window_open
```

禁止写入：

```text
player_should_do_X
best_solution_X
correct_order_X
```

保持 v1.1 的“WorldState 只保存事实”原则。fileciteturn28file0

---

# 6. 第二章 Ninja Route 规范

所有路线必须满足：

```text
固定锚点
+
离散状态
+
WorldState 分支
```

例如：

```text
R03_BridgeEntry
├─ bridge_open = true  → R04_Bridge
└─ bridge_open = false → R04_PoisonFork
```

不得出现：

```text
“忍者发现桥坏了所以自己找一条路”
```

正确做法是：

```text
WorldState
→ 预设分支路线
```

这样继续遵守“蠢要可预测”。

---

# 7. 第二章 Cat Tunnel / JumpPoint 制作规则

## CatTunnel

每关至少：

```text
1 个
```

L08：

```text
2 个
```

CatTunnel 的作用必须是：

> 缩短猫的路径，而不是直接给出答案。

## JumpPoint

用于：

- 箱堆
- 码头平台
- 栈桥
- 屋顶/货箱

禁止通过 JumpPoint 绕过所有事件。

---

# 8. 第二章 Debug Overlay

调试时显示：

```text
[NINJA]
CurrentRoute = R04
State = WALK
TargetEvent = E04

[WORLD]
guard_a_departed = true
dog_distracted = true
bridge_open = false

[PLAYER]
Carry = FISH
Suspicion = 42

[DEPENDENCY]
E04 <- E02 <- E01
```

玩家正式版本隐藏。

---

# 9. 第二章统一 QA Matrix

每关必须至少覆盖：

```text
标准成功
标准失败
风险成功
风险失败
错误顺序
NPC 状态并发
Reset
重复进入 EventPoint
怀疑值上涨
怀疑值清除
```

L07 / L08 额外覆盖：

```text
A→B→C
A→C→B
B→A→C
B→C→A
C→A→B
C→B→A
```

这些不是六种都必须成为“可通关解法”，而是必须得到明确、稳定、可诊断的结果。

---

# 10. 第二章 Playtest Gate

8 名第一次体验第二章的玩家中：

```text
≥5/8
使用 NPC 联动至少一次

≥5/8
实际搬运至少一次

≥5/8
使用至少两次猫捷径

≥4/8
失败后主动改变事件顺序

≥4/8
能解释至少一条因果链
```

同时沿用 v1.1 对第二关的 Gate 标准；若玩家普遍反馈：

> “东西太多。”

而不是：

> “我顺序弄错了。”

则应减少同屏并发事件，而不是简单延长时间。fileciteturn28file0

---

# 11. 第二章制作顺序

```text
1. L05 Whitebox
2. L05 可通关
3. L06 Whitebox
4. Dog 联动锁定
5. L07 Dependency 锁定
6. L08 多线程白盒
7. Chapter Playtest
8. 固定 Variant B
9. 美术 Dressing
10. Audio
11. LevelValidator
```

不得四关一起做最终美术。

---

# 12. 第二章完成定义

第二章只有同时满足以下条件才进入 Production Candidate：

```text
[ ] L05 玩家理解搬运
[ ] L06 玩家理解 NPC 可利用
[ ] L07 玩家理解事件顺序
[ ] L08 玩家能同时管理至少两条工作线
[ ] Dog 全状态稳定
[ ] Guard A/B 路线稳定
[ ] Bridge / Poison 状态稳定
[ ] 所有失败均产生 FAIL_CODE
[ ] Reset 后 WorldState 正常
[ ] Variant B 可重复
[ ] LevelValidator 全绿
[ ] 第二章 Playtest Gate 通过
```

---

# 13. 第二章一句话

> **第一章让玩家学会“抢在忍者前面”，第二章让玩家学会“让整个码头替自己工作”。**
