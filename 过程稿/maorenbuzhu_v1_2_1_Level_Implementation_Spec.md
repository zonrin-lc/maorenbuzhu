# 《猫忍不住》v1.2.1 · Level Implementation Spec

> 目的：把 v1.2 的 12 个主线关卡进一步落到可直接进入 Godot Whitebox 阶段的实施颗粒度。
>
> 本文只解决“怎么搭关卡”，不重新定义核心玩法。

---

# 0. 使用规则

## 0.1 坐标标准

本文件中的 `G(x,y)` 均指 **TileGrid 坐标**，不假定具体像素尺寸。

实际项目由关卡 TileMap / GridMap 的 tile size 决定。

例如：

```text
G(4,8)
```

表示第 4 列、第 8 行的白盒锚点。

## 0.2 每关固定五层

```text
01_Environment
02_NinjaRoute
03_EventPoints
04_Actors
05_Debug
```

推荐场景结构：

```text
LevelRoot
├─ Environment
├─ Navigation
├─ NinjaRoute
├─ EventPoints
├─ Actors
├─ Collectibles
├─ Audio
├─ Cameras
└─ Debug
```

## 0.3 路线锚点

Ninja 不使用自由寻路作为关卡逻辑。

白盒阶段直接放置：

```text
RoutePoint_00
RoutePoint_01
...
RoutePoint_N
```

EventPoint 与 RoutePoint 之间使用引用建立关系。

---

# 1. L01《第一份差事》

## 1.1 关卡职责

第一教学关，只回答一个问题：

> “为什么我必须跑到忍者前面？”

## 1.2 推荐白盒尺寸

```text
宽：26 tile
高：14 tile
```

## 1.3 区域

| 区域 | G范围 | 功能 |
|---|---|---|
| Start | G(2,6)~G(6,10) | 猫/忍者出生 |
| Tripwire Alley | G(7,4)~G(11,10) | E01 |
| Guard Plaza | G(12,3)~G(18,10) | E02 |
| Watergap | G(19,5)~G(23,10) | E03 |
| Goal | G(24,6)~G(25,9) | 卷轴 |

## 1.4 Ninja Route

```text
R00 Start
→ R01 AlleyEntry
→ R02 Tripwire
→ R03 PlazaEntry
→ R04 Guard
→ R05 Watergap
→ R06 Goal
```

## 1.5 事件

### E01 Tripwire

```text
event_type = TRIPWIRE
success = BITE
risk_solution = LAST_SECOND_BITE
```

玩家通过 E 后，忍者继续前进，不额外等待。

### E02 Guard

```text
event_type = GUARD
success = MEOW_LURE
risk_solution = CLOSE_PASS
```

第一次只允许一个最明显的可用交互提示。

### E03 Watergap

```text
event_type = WATERGAP
success = PUSH_CRATE
risk_solution = NARROW_JUMP
```

## 1.6 关键时间线

```text
T+00    忍者出发
T+05    E01 接近
T+12    E01 进入危险判定
T+18    E02 进入危险判定
T+30    E03 进入犹豫
T+33    E03 犹豫结束
T+40~50 Goal
```

以上为白盒初值，最终由试玩调整。

## 1.7 失败出口

```text
FAIL_TOO_LATE
FAIL_NINJA_DEATH
FAIL_TIMEOUT
```

## 1.8 Godot 资源

```text
Scene: scenes/levels/chapter_01_village/L01_FirstJob.tscn
LevelData: data/levels/chapter_01/L01_FirstJob.tres
RouteData: data/routes/chapter_01/L01_FirstJob_Route_A.tres
Variant: data/variants/chapter_01/L01_FirstJob_B.tres
```

---

# 2. L02《他总是踩同一个坑》

## 2.1 关卡职责

第一次让玩家建立：

```text
事件 A 解决后
→ 马上赶往事件 B
```

## 2.2 区域

```text
Start → Narrow Alley → Plaza → Waterline → Goal
```

建议白盒：

```text
30 × 14 tile
```

## 2.3 事件关系

```text
E01 Tripwire
   ↓
E02 Guard
   ↓
E03 Watergap
```

三个 EventPoint 必须存在明显空间捷径：

```text
MainRoute
ShortcutRoute
```

Shortcut 只能缩短猫的移动，不直接改变 Ninja Route。

## 2.4 Variant B

仅改变：

```text
Guard 起始位置
Guard Event 触发时间
```

禁止新增事件。

## 2.5 关键 Gate

测试者必须有明显机会发现：

> “跟着忍者跑，我永远来不及。”

---

# 3. L03《谁在看猫》

## 3.1 关卡职责

单独建立 Suspicion 心智模型。

## 3.2 区域

```text
Start
→ Guard Vision
→ Crate Yard
→ Emote Shelter
→ Watergap
→ Goal
```

## 3.3 事件

```text
E01 = GUARD_PASSIVE
E02 = STEAL_CRATE
E03 = EMOTE_CHECK
E04 = WATERGAP
```

## 3.4 推荐空间关系

E02 必须在 Guard 视线边缘。

设计成：

```text
视线内
  ↓
偷箱
  ↓
Suspicion +
  ↓
跑出视线
  ↓
不再新增
  ↓
Ctrl 卖萌
  ↓
Suspicion 清除
```

## 3.5 QA 特例

必须单独测试：

```text
被看见但没有做事
被看见做事
做完立刻离开
离开后不卖萌
离开后卖萌
```

---

# 4. L04《村口大事故》

## 4.1 关卡职责

第一章终局：首次真正考察“顺序”。

## 4.2 推荐白盒

```text
34 × 18 tile
```

## 4.3 事件依赖

```text
Guard A
   ↓
Tripwire
   ↓
Crate
   ↓
Watergap
```

## 4.4 两条有效主路线

### Route A

```text
Guard A
→ Tripwire
→ Crate
→ Watergap
```

### Route B

```text
Tripwire
→ Guard A
→ Shortcut
→ Watergap
```

两条路线都必须能够完成任务。

## 4.5 禁止

不可出现：

```text
A处理错误 = 整局永久 Softlock
```

失败后必须能 Reset。

---

# 5. L05《月夜码头》

## 5.1 关卡职责

正式引入 Carry。

## 5.2 区域

```text
Dock Entrance
Fish Storage
Dog Yard
Broken Bridge
Poison Lane
Goal Ship
```

建议：

```text
38 × 20 tile
```

## 5.3 资源点

```text
Fish_01
Crate_01
Antidote_01
```

## 5.4 主路线

```text
Fish
→ Dog
→ Crate
→ Bridge
→ Antidote
→ Poison
→ Goal
```

## 5.5 资源约束

一次只允许携带一个 Carryable。

这必须在 L05 首次产生可感知的资源占用。

---

# 6. L06《狗也能当队友》

## 6.1 关卡职责

把 Dog 从“障碍”转成“工具”。

## 6.2 三个关键区域

```text
Dog Yard
Guard Lane
Cat Bait Shortcut
```

## 6.3 解法 A：Fish

```text
Fish
→ Dog Fed
→ Dog Locked
→ Guard 不再被干扰
→ Ninja 通过
```

## 6.4 解法 B：Cat Bait

```text
Cat Enters Vision
→ Dog Chase
→ Guard Reacts
→ Ninja Window Open
```

## 6.5 风险标记

B 路线写入：

```text
high_risk = true
risk_style = RISKY
```

---

# 7. L07《谁先走》

## 7.1 关卡职责

第二章核心逻辑关。

## 7.2 Event Graph

```text
Guard A
   ↓
Guard B Shift
   ↓
Dog Path
   ↓
Bridge Window
   ↓
Poison Window
```

## 7.3 地图要求

每个事件之间必须让玩家可以看到下一个事件区域，避免“解谜答案藏在视野之外”。

## 7.4 错误演示

第一次顺序错误，不直接 Game Over。

应出现：

```text
Guard B 提前出现
→ Ninja 路线变化
→ 玩家看到后果
```

让玩家自己总结：

> “原来我应该先处理 A。”

---

# 8. L08《最后一班船》

## 8.1 关卡职责

第二章压力测试。

## 8.2 白盒

```text
44 × 22 tile
```

## 8.3 EventPoint

至少 7 个：

```text
E01 Guard A
E02 Dog
E03 Bridge
E04 Poison
E05 Guard B
E06 Caltrop
E07 Goal Ship
```

## 8.4 资源冲突

```text
AntidoteContainer
```

可以服务两个用途，但只能选择一个方向。

必须确保另一种用途仍有替代解，否则会产生假多解。

## 8.5 目标

玩家完成后，应能说出：

> “我刚才不是在做七件事，是在安排七件事。”

---

# 9. L09《雷雨夜》

## 9.1 关卡职责

第三章入口：提高压力，但不提高规则复杂度。

## 9.2 白盒

```text
42 × 22 tile
```

## 9.3 事件

```text
Tripwire
Dynamite
Guard
Dog
```

## 9.4 环境层

```text
Rain
Thunder Flash
Darkness Tint
```

环境表现不得遮挡：

- Ninja
- EventPoint
- Cat

## 9.5 音频层

```text
Base BGM
Rain Loop
Thunder One-Shot
Ninja Voice
Event Resolve
```

---

# 10. L10《炸药不能乱碰》

## 10.1 关卡职责

第一次正式测试“连锁事故”。

## 10.2 Event Graph

```text
Dynamite
   ↓
Guard A Change
   ↓
Dog Panic
   ↓
Ninja Route Branch
   ↓
Caltrop Window
```

## 10.3 EventLog

必须写入：

```text
caused_event_id
world_changes
route_change
```

例如：

```text
E02.caused_event_id = E03
E03.caused_event_id = E04
```

## 10.4 Variant B

仅让：

```text
Dynamite 起始位置
```

变化。

因果关系不变化。

---

# 11. L11《越靠近城门越忙》

## 11.1 关卡职责

Boss 前压力测试，不是 Boss 替代品。

## 11.2 EventPoint

至少 7：

```text
Guard A
Dog
Dynamite
Poison
Caltrop
Cliff
Guard B
```

## 11.3 三阶段节奏

```text
Phase A：准备
Phase B：移动中补救
Phase C：入口冲刺
```

## 11.4 核心要求

不能要求玩家提前把全部事情处理干净。

至少保留：

```text
1 个中途事件
1 个最后窗口事件
```

确保玩家一直有“赶场”体验。

---

# 12. L12《守门武士》

## 12.1 白盒

```text
48 × 26 tile
```

## 12.2 Arena 分区

```text
A Crane Zone
B Gourd Zone
C Charge Line
D Ninja Arena
E Emergency Door
```

## 12.3 Boss EventPoint

```text
B01 Crane
B02 Gourd
B03 Caltrop
B04 Emergency
```

## 12.4 Boss 前

玩家可以：

```text
B01 Prepare
B02 Prepare
```

但是不得让 B03 在 Boss 前就完全失去价值。

## 12.5 Phase 1

Boss 行动。

```text
B01 → trigger
```

玩家应该看到结果，但无需停留观看。

## 12.6 Phase 2

```text
Boss Charge Start
→ B03 Open
→ Cat Relocates
→ Place Caltrop
→ Boss Hits
```

这是 L12 最重要的主动操作窗口。

## 12.7 Phase 3

根据 Boss HP：

```text
HP <= 0 → Defeated
HP > 0  → Ninja Finish Attempt
```

## 12.8 Emergency

仅当：

```text
Ninja HP <= 1
AND Boss Finish Attempt
```

开放。

## 12.9 Boss 组合测试

必须完整覆盖：

```text
ABC
AB
AC
BC
A
B
C
None
Emergency
```

---

# 13. 12 关统一 Godot 文件映射

```text
scenes/levels/chapter_01_village/L01_FirstJob.tscn
scenes/levels/chapter_01_village/L02_SameTrap.tscn
scenes/levels/chapter_01_village/L03_WatchingCat.tscn
scenes/levels/chapter_01_village/L04_VillageAccident.tscn

scenes/levels/chapter_02_dock/L05_MoonlitDock.tscn
scenes/levels/chapter_02_dock/L06_DogAlly.tscn
scenes/levels/chapter_02_dock/L07_WhoGoesFirst.tscn
scenes/levels/chapter_02_dock/L08_LastShip.tscn

scenes/levels/chapter_03_castle/L09_StormNight.tscn
scenes/levels/chapter_03_castle/L10_DontTouchDynamite.tscn
scenes/levels/chapter_03_castle/L11_TooBusy.tscn
scenes/levels/chapter_03_castle/L12_GatekeeperBoss.tscn
```

---

# 14. LevelData 文件映射

```text
data/levels/chapter_01/L01_FirstJob.tres
...
data/levels/chapter_03/L12_GatekeeperBoss.tres
```

每个 LevelData 必须引用：

```text
route_data
shortcuts
world_flags
score_rules
banter_profile
audio_map
validation_rules
modifiers
variant
```

---

# 15. Whitebox 统一验收

一个关卡从 Whitebox 进入 Art 前必须：

```text
[ ] Ninja Route 能完整跑通
[ ] 每个 CRITICAL Event 有成功出口
[ ] 每个 CRITICAL Event 有失败出口
[ ] 至少一条 Shortcut
[ ] 至少一条 Risky Solution
[ ] Reset 后状态全部恢复
[ ] Save/Load 不破坏 WorldState
[ ] Variant B 可加载
[ ] LevelValidator 通过
[ ] 新玩家知道下一步危险在哪
```

---

# 16. 白盒阶段禁止事项

```text
禁止先做精美背景
禁止先做复杂特效
禁止先做完整 UI
禁止先做大量台词
禁止为了“看起来丰富”增加新按钮
```

生产顺序必须：

```text
路线
→ 事件
→ 依赖
→ 时间
→ 失败
→ Reset
→ Gate
→ Art
→ Audio
→ Settlement
```

---

# 17. v1.2.1 下一阶段

完成本文后，正式进入：

```text
L01-L04 Whitebox Sprint
↓
Chapter 1 Blind Playtest
↓
锁定第一章
↓
L05-L08 Whitebox Sprint
↓
Chapter 2 Blind Playtest
↓
L09-L12 Whitebox Sprint
↓
Boss Active Gate
```

不建议 12 关同时进入精细美术。

正确策略是：

> **一章一章锁定，而不是十二关一起堆资源。**
