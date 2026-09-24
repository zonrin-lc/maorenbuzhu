# 《猫忍不住》v1.2 制作执行包 · System Spec

> 目标：在不增加核心操作的前提下，为 **12 个主线关卡**提供可维护的 Godot 4 Scene / Script / Data Resource 架构。

---

# 0. 实现边界

v1.2 是**内容规模扩充**，不是系统重做。

```text
Data 控内容
Script 控行为
Scene 控组成
EventBus 控广播
EventLog 控 Gameplay Facts
WorldState 控世界事实
```

不得因为增加 12 关而在每关复制一份核心行为脚本。

---

# 1. Godot 工程目录

```text
res://
├─ scenes/
│  ├─ boot/
│  ├─ core/
│  ├─ actors/
│  ├─ interactables/
│  ├─ ui/
│  ├─ meta/
│  └─ levels/
│     ├─ chapter_01_village/
│     ├─ chapter_02_dock/
│     └─ chapter_03_castle/
├─ scripts/
│  ├─ core/
│  ├─ actors/
│  ├─ gameplay/
│  ├─ systems/
│  ├─ ui/
│  ├─ meta/
│  └─ debug/
├─ data/
│  ├─ levels/
│  ├─ chapters/
│  ├─ events/
│  ├─ routes/
│  ├─ actors/
│  ├─ scoring/
│  ├─ dialogue/
│  ├─ audio/
│  ├─ achievements/
│  └─ variants/
└─ tests/
```

---

# 2. 新增：ChapterData / LevelCatalog

12 关需要元数据管理，但不增加新的玩家玩法系统。

## 2.1 ChapterData

`data/chapters/chapter_data.gd`

```gdscript
@export var chapter_id: String
@export var display_name: String
@export var level_ids: Array[String]
@export var challenge_id: String
@export var unlock_condition: Resource
```

固定数据：

```text
chapter_01 = [L01,L02,L03,L04]
chapter_02 = [L05,L06,L07,L08]
chapter_03 = [L09,L10,L11,L12]
```

## 2.2 LevelCatalog

`data/levels/level_catalog.tres`

功能：

- 章节 → 关卡映射
- 关卡显示名
- 解锁顺序
- Variant 列表
- Debug 快速跳关

不保存运行时 Node。

---

# 3. LevelData v1.2

```gdscript
@export var level_id: String
@export var chapter_id: String
@export var sequence_index: int
@export var display_name: String
@export var route_data: Resource
@export var event_points: Array[Resource]
@export var shortcut_data: Array[Resource]
@export var world_flags: Resource
@export var score_rules: Resource
@export var banter_profile: Resource
@export var audio_map: Resource
@export var validation_rules: Resource
@export var modifiers: Resource
@export var variant_id: String = "A"
@export var target_time: float = 60.0
@export var chapter_challenge_tags: Array[String]
```

`target_time` 是首轮调平参数，不是设计师在代码里硬编码的常量。

---

# 4. Scene / Script / Resource 总表

| 功能 | Scene | Script | Data Resource |
|---|---|---|---|
| GameRoot | `GameRoot.tscn` | `game_root.gd` | `game_settings.tres` |
| Chapter | 无独立运行 Scene | `chapter_controller.gd` | `chapter_data.tres` |
| Level | `LevelRoot.tscn` | `level_controller.gd` | `level_data.tres` |
| 猫 | `Cat.tscn` | `cat_controller.gd` | `cat_data.tres` |
| 忍者 | `Ninja.tscn` | `ninja_controller.gd` | `ninja_data.tres` |
| 守卫 | `Guard.tscn` | `npc_guard.gd` | `guard_data.tres` |
| 狗 | `Dog.tscn` | `npc_dog.gd` | `dog_data.tres` |
| EventPoint | `EventPoint.tscn` | `event_point.gd` | `event_data.tres` |
| 可搬运物 | `Carryable.tscn` | `carryable.gd` | `carryable_data.tres` |
| JumpPoint | `JumpPoint.tscn` | `jump_point.gd` | `jump_data.tres` |
| CatTunnel | `CatTunnel.tscn` | `cat_tunnel.gd` | `tunnel_data.tres` |
| 怀疑 | Core 节点 | `suspicion_system.gd` | `suspicion_profile.tres` |
| 评分 | Core 节点 | `score_system.gd` | `score_rule_data.tres` |
| EventLog | Core Service | `event_log.gd` | schema only |
| Boss | `BossArena.tscn` | `boss_controller.gd` | `boss_data.tres` |
| Settlement | `IzakayaResult.tscn` | `settlement_controller.gd` | `boast_template_data.tres` |

---

# 5. NinjaController

忍者仍然是：

```text
固定路线
+
状态机
+
脚本分支
```

12 关只增加 `RouteData`，不增加一套新 AI。

禁止：

- 自由寻路
- 随机路线
- 随机危险反应

允许：

- WorldState 驱动预设路线分支
- AlternativeRoute
- Personality Modifier

---

# 6. RouteData v1.2

建议：

```gdscript
@export var route_id: String
@export var ordered_nodes: Array[NodePath]
@export var branch_rules: Array[Resource]
@export var hesitation_points: Array[Resource]
@export var event_links: Array[String]
```

每关路线必须有唯一 `route_id`。

Variant B 通过不同 RouteData 或 BranchRule 实现，不复制 NinjaController。

---

# 7. EventData v1.2

```gdscript
@export var event_id: String
@export var event_type: String
@export var risk_level: String
@export var critical: bool
@export var success_actions: Array[String]
@export var risky_actions: Array[String]
@export var fail_codes: Array[String]
@export var prerequisite_flags: Array[String]
@export var writes_world_flags: Array[String]
@export var caused_event_id: String
@export var target_timeout: float
@export var boast_tags: Array[String]
```

所有 12 关的 EventPoint 只通过 Data 配置。

---

# 8. WorldState

只保存事实，例如：

```text
guard_a_departed
guard_b_active
dog_fed
bridge_open
poison_route_safe
boss_crane_ready
boss_caltrop_ready
boss_gourd_ready
boss_phase
boss_retreat
```

增加 12 关后，禁止把 `L01_xxx` 这种关卡特例直接写入全局状态。

推荐前缀：

```text
l04_gate_*
l07_dock_*
l10_castle_*
l12_boss_*
```

---

# 9. ScoreSystem

12 关统一调用同一套 ScoreRule。

唯一允许的内容差异：

- target_time
- 事件标签
- Boss 额外条件

不允许每一关重写评分算法。

---

# 10. SuspicionSystem

保持 v1.1 语义：

```text
猫出现 = 正常
猫做事被看到 = 怀疑增加
猫离开 = 停止当前行为继续累积
卖萌 = 清除累计怀疑
```

12 关允许通过 `LevelModifier.suspicion_gain_mult` 做轻量难度调整，不允许修改阈值语义。

---

# 11. BossController

只存在于 L12。

```text
INTRO
→ PREPARE
→ PHASE_1
→ PHASE_2
→ PHASE_3
→ DEFEATED / RETREAT
```

Phase 2 必须由玩家主动移动处理蒺藜。

Emergency Rescue 仍然是 Fail-safe，不新增为第四机关。

---

# 12. LevelLoader

新增：`level_loader.gd`

职责：

1. 从 LevelCatalog 获取 level_id
2. 加载 `LevelData`
3. 实例化对应 `.tscn`
4. 注入 WorldState 初始值
5. 注入 LevelModifier
6. 启动 EventLog
7. 初始化 UI

禁止让关卡脚本自己决定“下一关是谁”。

下一关由 `LevelCatalog` 决定。

---

# 13. SaveData v1.2

```gdscript
levels_completed: Array[String]
level_results: Dictionary
chapter_results: Dictionary
hard_mode_unlocked: bool
hard_plus_unlocked: bool
unlocked_cat_skins: Array[String]
fish_collected: Dictionary
achievements: Array[String]
cat_skills: Dictionary
settings: Dictionary
input_bindings: Dictionary
```

12 关的 Save 只增加数据量，不改变协议思路。

---

# 14. LevelValidator v1.2

Validator 必须支持：

```text
L01-L12
```

每关检查：

```text
[ ] LevelData
[ ] RouteData
[ ] Goal
[ ] Event ID 唯一
[ ] WorldState key
[ ] success/fail 出口
[ ] 关键事件双路径
[ ] Shortcut 引用
[ ] AudioMap
[ ] ScoreRule
[ ] Restart 清理
```

L12 额外：

```text
[ ] Boss Exit
[ ] Boss Phase Transition
[ ] Emergency Rescue Exit
[ ] Boss Mechanic >= 3
```

---

# 15. 推荐资源命名

```text
data/chapters/ch01_village.tres

data/levels/l01_first_job.tres
...
data/levels/l12_gatekeeper_boss.tres

data/routes/l01_route_a.tres
...
data/routes/l12_route_a.tres

data/variants/l01_variant_b.tres
...
data/variants/l12_variant_b.tres
```

---

# 16. 12 关实例表

| Level | Scene | LevelData | RouteData | Variant |
|---|---|---|---|---|
| L01 | `L01_FirstJob.tscn` | `l01_first_job.tres` | `l01_route_a.tres` | B |
| L02 | `L02_RepeatTrap.tscn` | `l02_repeat_trap.tres` | `l02_route_a.tres` | B |
| L03 | `L03_WhoSawCat.tscn` | `l03_who_saw_cat.tres` | `l03_route_a.tres` | B |
| L04 | `L04_VillageAccident.tscn` | `l04_village_accident.tres` | `l04_route_a.tres` | B |
| L05 | `L05_MoonlitDock.tscn` | `l05_moonlit_dock.tres` | `l05_route_a.tres` | B |
| L06 | `L06_DogAlly.tscn` | `l06_dog_ally.tres` | `l06_route_a.tres` | B |
| L07 | `L07_FirstMove.tscn` | `l07_first_move.tres` | `l07_route_a.tres` | B |
| L08 | `L08_LastBoat.tscn` | `l08_last_boat.tres` | `l08_route_a.tres` | B |
| L09 | `L09_StormNight.tscn` | `l09_storm_night.tres` | `l09_route_a.tres` | B |
| L10 | `L10_DontTouchDynamite.tscn` | `l10_dynamite.tres` | `l10_route_a.tres` | B |
| L11 | `L11_GateRush.tscn` | `l11_gate_rush.tres` | `l11_route_a.tres` | B |
| L12 | `L12_GatekeeperBoss.tscn` | `l12_gatekeeper_boss.tres` | `l12_route_a.tres` | B |

---

# 17. 系统联调顺序

```text
1. Cat Movement
2. Ninja Route
3. EventPoint
4. WorldState
5. NPC State Machine
6. Suspicion
7. Score
8. Chapter / LevelLoader
9. Boss
10. Settlement
11. Save/Load
12. Audio
13. Accessibility
14. Polish
```

---

# 18. 不允许的 12 关扩容捷径

禁止：

- 每关复制一份核心脚本
- Level Script 硬编码大量 Event ID
- 用关卡脚本直接修改 GameState
- 用随机数决定 Ninja 路线
- 用 UI 文案充当 Gameplay state
- 通过“加血 / 减速 / 无限资源”硬撑难度

允许：

- 新 LevelData
- 新 RouteData
- 新 EventData
- 新 VariantData
- 新环境组合
- 新结算台词

---

# 19. System DoD

```text
[ ] L01-L12 可加载
[ ] 所有 LevelData 可解析
[ ] 所有 RouteData 可运行
[ ] 所有 EventPoint 可触发
[ ] Reset 无残留
[ ] Save/Load 不破坏进度
[ ] LevelValidator 12 关全绿
[ ] L12 Boss 可结束
[ ] Chapter Progress 正常
```
