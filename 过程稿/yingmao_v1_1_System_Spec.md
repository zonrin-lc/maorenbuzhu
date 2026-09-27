# 《影猫》v1.1 制作执行包 · System Spec

> 状态：Production Candidate 基线
>
> 目标：将 Master GDD 的冻结规则落成 Godot 4 可直接实施的 Scene / Script / Data Resource / Signal / State Machine 规范。

---

# 0. 实现边界

本文件新增的是工程实现规范，不修改玩法规则。

原则：

```text
Data 控内容
Script 控行为
Scene 控组成
EventBus 控广播
EventLog 控事实记录
WorldState 控世界事实
```

---

# 1. Godot 工程目录

```text
res://
├─ scenes/
│  ├─ boot/
│  │  └─ Boot.tscn
│  ├─ core/
│  │  ├─ GameRoot.tscn
│  │  ├─ LevelRoot.tscn
│  │  └─ DebugRoot.tscn
│  ├─ actors/
│  │  ├─ Cat.tscn
│  │  ├─ Ninja.tscn
│  │  ├─ Guard.tscn
│  │  ├─ Dog.tscn
│  │  └─ Boss.tscn
│  ├─ interactables/
│  │  ├─ EventPoint.tscn
│  │  ├─ JumpPoint.tscn
│  │  ├─ CatTunnel.tscn
│  │  ├─ Carryable.tscn
│  │  ├─ Tripwire.tscn
│  │  ├─ Caltrop.tscn
│  │  ├─ Poison.tscn
│  │  ├─ Bridge.tscn
│  │  └─ BossMechanic.tscn
│  ├─ ui/
│  │  ├─ HUD.tscn
│  │  ├─ SuspicionIndicator.tscn
│  │  ├─ ActionPrompt.tscn
│  │  ├─ NinjaStatus.tscn
│  │  ├─ ResultPanel.tscn
│  │  └─ IzakayaResult.tscn
│  └─ meta/
│     └─ Title.tscn
├─ scripts/
│  ├─ core/
│  ├─ actors/
│  ├─ gameplay/
│  ├─ systems/
│  ├─ ui/
│  ├─ meta/
│  └─ debug/
└─ data/
   ├─ levels/
   ├─ events/
   ├─ routes/
   ├─ actors/
   ├─ scoring/
   ├─ dialogue/
   ├─ audio/
   ├─ achievements/
   └─ variants/
```

---

# 2. Autoload

## 2.1 GameState

文件：`scripts/core/game_state.gd`

职责：

- 当前 GameFlow
- 当前 level_id
- 当前尝试编号
- 玩家解锁
- Hard Mode
- 玩家猫技艺
- 当前存档槽元数据

禁止：

- 存放临时场景对象
- 存放 Node 引用
- 存放 EventPoint 实例

## 2.2 EventBus

文件：`scripts/core/event_bus.gd`

建议 Signals：

```gdscript
signal gameplay_started(level_id: String)
signal event_started(event_id: String)
signal event_resolved(event_id: String, success: bool)
signal suspicion_changed(value: float)
signal ninja_hp_changed(current: int, previous: int)
signal world_state_changed(key: String, value: Variant)
signal level_completed(level_id: String)
signal level_failed(level_id: String, fail_code: String)
signal boss_phase_changed(phase: int)
signal settlement_ready(result: Dictionary)
```

## 2.3 AudioManager

职责：

```text
BGM
SFX
VOICE
AMBIENCE
UI
TENSION
```

提供：

```gdscript
play_bgm(id: String)
play_sfx(id: String)
play_voice(id: String)
set_layer(id: String, enabled: bool)
set_mix_profile(id: String)
```

## 2.4 SaveManager

只接受 Serializable Data。

禁止直接序列化 Node Tree。

---

# 3. GameRoot Scene

`GameRoot.tscn`

建议节点：

```text
GameRoot (Node)
├─ SessionController
├─ WorldState
├─ ScoreSystem
├─ EventLogSystem
├─ SuspicionSystem
├─ LevelValidator
├─ AudioBridge
├─ HUD
└─ CurrentLevel (Node)
```

Script：`game_root.gd`

职责：

- 创建关卡
- 注入 LevelData
- 初始化 WorldState
- 注册 EventPoint
- 控制成功/失败/重试

---

# 4. LevelRoot Scene

`LevelRoot.tscn`

```text
LevelRoot
├─ World
│  ├─ TileMap / TileMapLayer
│  ├─ Props
│  └─ Decor
├─ Navigation
├─ Actors
│  ├─ Cat
│  ├─ Ninja
│  ├─ NPCs
│  └─ Boss
├─ Interactables
│  ├─ EventPoints
│  ├─ JumpPoints
│  ├─ CatTunnels
│  └─ Carryables
├─ Routes
├─ Goals
├─ Collectibles
└─ SpawnMarkers
```

关卡实例只绑定对应 `LevelData`。

---

# 5. Cat.tscn

建议：

```text
Cat (CharacterBody2D)
├─ Sprite2D / AnimatedSprite2D
├─ CollisionShape2D
├─ InteractionArea (Area2D)
├─ MeowArea (Area2D)
├─ PickupAnchor (Marker2D)
├─ CarryVisual (Node2D)
├─ ActionTimer
└─ Audio
```

Script：`cat_controller.gd`

## 5.1 输入

```text
Move = WASD / Left Stick
Sprint = Shift / RT
Interact = E / South Button
Carry = Q / West Button
Meow = F / East Button
Emote = Ctrl / North Button
JumpPoint = E
Tunnel = E
Pause = Esc / Menu
```

键位可重绑定。

## 5.2 Cat State

```text
FREE
SPRINT
CARRY
INTERACT
MEOW
EMOTE
JUMP
TUNNEL
DISABLED
```

状态切换不得改变数值规则。

## 5.3 移动伪代码

```gdscript
func _physics_process(delta):
    var input_vec := input_reader.get_vector()
    var speed := cat_data.move_speed

    if sprint_requested and can_sprint():
        state = CatState.SPRINT
        speed = cat_data.sprint_speed
        stamina.consume(cat_data.sprint_cost * delta)
    elif carrying:
        speed *= cat_data.carry_speed_mult

    velocity = input_vec * speed
    move_and_slide()
```

---

# 6. Ninja.tscn

```text
Ninja (CharacterBody2D)
├─ Sprite2D / AnimatedSprite2D
├─ CollisionShape2D
├─ RouteFollower
├─ EventReceiver
├─ Hurtbox
├─ Health
├─ SuspicionObserver
├─ EmotePlayer
└─ Audio
```

Script：`ninja_controller.gd`

## 6.1 状态

```text
ROUTE
APPROACH_EVENT
EVENT_REACTION
DAMAGED
SEARCH
RECOVER
GOAL
DEAD
BOSS_COMBAT
```

## 6.2 禁止

- 自由寻路
- 随机路线
- 随机危险反应
- 随机攻击

## 6.3 允许

- WorldState → AlternativeRoute
- Personality Modifier
- 固定情绪

## 6.4 RouteData

Route 节点只描述：

```text
Path2D
Waypoint[]
EventTrigger[]
AlternativeRoute[]
Timing
PersonalityModifier
```

不得在 RouteData 中写“玩家应该怎么处理”。

---

# 7. NPC 状态机

## 7.1 Guard

```text
PATROL
NOTICE
ALERT
SEARCH
LEAVE
RETURN
DISABLED
```

入口来自：

- player_action_seen
- meow
- dog_bark
- world_state change

## 7.2 Dog

```text
IDLE
NOTICE
BARK
CHASE
DISTRACTED
FED
RETURN
```

Dog 是“因果节点”，而不是纯敌人。

## 7.3 NPC 设计原则

```text
输入事实
→ 固定规则
→ 可预测行为
```

---

# 8. SuspicionSystem

文件：`suspicion_system.gd`

字段：

```gdscript
var current_value: float
var max_value: float
var last_source_event_id: String
var state: SuspicionState
```

枚举：

```gdscript
enum SuspicionState {
    NORMAL,
    NOTICE,
    ALERT,
    HIGH_ALERT,
    BROKEN_COVER
}
```

## 8.1 重要语义

```text
看到猫 ≠ 怀疑增加

看到猫进行人类式操作 → 增加

猫离开 → 停止该暴露动作继续增加

离开 ≠ 当前值归零

卖萌 → 清除当前累积值
```

## 8.2 对外接口

```gdscript
func add_suspicion(amount: float, source_event_id: String) -> void
func clear_by_emote() -> void
func get_state() -> SuspicionState
func get_max_value() -> float
```

---

# 9. EventPoint

Scene：`EventPoint.tscn`

```text
EventPoint (Area2D)
├─ CollisionShape2D
├─ TriggerMarker
├─ DangerVisual
├─ SuccessVisual
└─ DebugLabel
```

Script：`event_point.gd`

绑定：`EventData.tres`

## 9.1 EventData schema

```gdscript
class_name EventData
extends Resource

@export var event_id: String
@export var event_type: String
@export var classification: String # CRITICAL / STANDARD / OPTIONAL
@export var timeout: float
@export var risk_level: String
@export var solutions: Array[Resource]
@export var failure_codes: Array[String]
@export var required_world_flags: Dictionary
@export var success_world_flags: Dictionary
@export var caused_event_id: String = ""
@export var shortcut_tag: String = ""
@export var high_risk: bool = false
```

## 9.2 Event 生命周期

```text
INACTIVE
↓
ARMED
↓
TRIGGERED
↓
ACTIVE
↓
RESOLVED / FAILED
↓
LOCKED / RESET
```

---

# 10. WorldState

文件：`world_state.gd`

允许保存：

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

禁止：

```text
player_should_do_X
```

### API

```gdscript
func set_flag(key: String, value: Variant) -> void
func get_flag(key: String, default_value: Variant = false) -> Variant
func has_flag(key: String) -> bool
func reset_level_flags() -> void
```

所有 WorldState 改动产生 `world_state_changed`。

---

# 11. Carryable

Scene：`Carryable.tscn`

状态：

```text
WORLD
HELD
DROPPED
CONSUMED
DISABLED
```

字段：

```text
item_id
carry_speed_mult
allowed_drop_tags
consume_on_success
required_by_event
```

典型对象：

- crate
- antidote / potion
- fish
- boss item

---

# 12. JumpPoint

Scene：`JumpPoint.tscn`

```text
JumpPoint
├─ EntryArea
├─ ExitMarker
├─ PreviewArrow
└─ FX
```

Data：

```text
jump_id
entry_position
exit_position
cooldown
allowed_actor = Cat
```

JumpPoint 是猫的移动捷径，不应成为忍者路径。

---

# 13. CatTunnel

Scene：`CatTunnel.tscn`

```text
CatTunnel
├─ Entry
├─ Exit
├─ Collision
└─ FX
```

规则：

- 只允许猫进入
- 不阻断忍者路线
- 可作为第二/第三关“预先到场”的空间表达

---

# 14. ScoreSystem

文件：`score_system.gd`

输入：

- mission_complete
- ninja_hp
- max_suspicion
- elapsed_time
- high_risk_rescue
- chain_rescue
- shortcut_or_dependency_mastery
- boss_mechanics_success

输出：

```gdscript
paw_count: int
risk_style: String
score_summary: Dictionary
```

### 14.1 Risk Style

```text
SAFE
BALANCED
RISKY
```

仅用于结算、成就、猫技艺和 Replay 标签，不直接提供额外数值奖励。

---

# 15. EventLog

文件：`event_log.gd`

核心结构：

```gdscript
{
  "timestamp": 0.0,
  "level_id": "",
  "event_id": "",
  "actor_id": "",
  "event_type": "",
  "action": "",
  "success": false,
  "risk_level": "",
  "high_risk": false,
  "player_position": Vector2.ZERO,
  "ninja_position": Vector2.ZERO,
  "ninja_hp_before": 3,
  "ninja_hp_after": 3,
  "suspicion_before": 0.0,
  "suspicion_after": 0.0,
  "world_changes": {},
  "caused_event_id": "",
  "route_change": "",
  "shortcut_used": "",
  "carry_item": "",
  "carry_duration": 0.0,
  "emergency_window": 0.0,
  "mood": ""
}
```

禁止把 UI 动画字段塞进核心日志。

---

# 16. Fail Code

```gdscript
const FAIL_TOO_LATE = "FAIL_TOO_LATE"
const FAIL_WRONG_ORDER = "FAIL_WRONG_ORDER"
const FAIL_SUSPICION = "FAIL_SUSPICION"
const FAIL_NINJA_DEATH = "FAIL_NINJA_DEATH"
const FAIL_BOSS_FINISHER = "FAIL_BOSS_FINISHER"
const FAIL_ROUTE_BLOCKED = "FAIL_ROUTE_BLOCKED"
const FAIL_TIMEOUT = "FAIL_TIMEOUT"
```

失败发生时，必须产生：

```text
fail_code
source_event_id
player_action
ninja_state
world_state_delta
```

---

# 17. BossController

Scene：`Boss.tscn`

```text
Boss
├─ Sprite
├─ Hurtbox
├─ PhaseController
├─ AttackController
├─ MechanicReceiver
├─ Health
└─ Audio
```

Script：`boss_controller.gd`

## 17.1 Phase

```text
INTRO
PREPARE
PHASE_1
PHASE_2
PHASE_3
DEFEATED
RETREAT
```

### Phase 1

吊车可触发。

### Phase 2

蒺藜最佳触发窗口。

### Phase 3

根据 Boss HP 决定结束演出。

### Emergency

Boss Finish + Ninja HP <= 1 时出现 1.5–2 秒窗口。

---

# 18. Boss Mechanic Resource

`BossMechanicData.gd`

```gdscript
@export var mechanic_id: String
@export var prep_allowed: bool
@export var active_phase: int
@export var trigger_window: float
@export var damage: int
@export var effect_type: String
@export var success_world_flag: String
@export var fail_code: String
```

默认数据：

| mechanic_id | prep | active_phase | damage/effect |
|---|---:|---:|---|
| crane | true | 1 | -40 boss HP 等价事件影响 |
| caltrop | true | 2 | -30 boss HP 等价事件影响 |
| gourd | true | intro | 延迟 10s |

实际伤害值仍以最终关卡平衡表校准。

---

# 19. Settlement System

Scene：`IzakayaResult.tscn`

```text
IzakayaResult
├─ NinjaEntry
├─ BoastPanel
├─ EventMontage
├─ CatReaction
├─ PawResult
└─ ContinueButton
```

数据：

`BoastTemplateData.tres`

```text
template_id
importance
required_tags
forbidden_tags
text
voice_id
animation_id
```

选择优先级：

```text
Emergency
> Near Death
> Boss
> Chain
> Route Change
> Ordinary Success
```

---

# 20. UI / HUD

HUD 只回答：

```text
我在哪？
忍者在哪？
忍者安全吗？
我现在能做什么？
```

不显示：

```text
正确答案
应该先做谁
攻略箭头
```

推荐节点：

```text
HUD
├─ NinjaMarker
├─ NinjaHealthIcon
├─ SuspicionIndicator
├─ ActionPrompt
├─ CarryPrompt
├─ AbilityHints
├─ GoalMarker
└─ PauseButton
```

怀疑不显示数字。

---

# 21. AudioMap

Data Resource：`AudioMapData.tres`

字段：

```text
level_id
bgm_id
tension_bgm_id
ambient_profile
event_sfx_map
voice_map
result_jingle
```

要求：关键危险至少有两种反馈：

```text
视觉/动画
+
声音
```

且不能只靠颜色区分。

---

# 22. SaveData

建议 Schema：

```text
version
unlocked_levels
unlocked_cat_skins
fish_collected
achievements
cat_skills
hard_mode_unlocked
hard_plus_unlocked
best_results_by_level
settings
input_bindings
```

不保存：

- 当前运行场景 Node 引用
- EventPoint runtime 状态
- 当前粒子状态
- 临时动画状态

---

# 23. LevelData Resource

`LevelData.gd`

```gdscript
@export var level_id: String
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
```

---

# 24. LevelModifier

用于少量关卡差异：

```gdscript
@export var ninja_speed_mult := 1.0
@export var hesitation_mult := 1.0
@export var suspicion_gain_mult := 1.0
@export var event_timeout_mult := 1.0
@export var target_time_offset := 0.0
```

v1.1 Hard Mode：

- Ninja +10%
- 犹豫 -0.5s
- Boss Prepare -2s
- 怀疑收益 +10%
- 提示减少

---

# 25. LevelValidator

必须能自动检查：

```text
[ ] LevelData 存在
[ ] RouteData 存在
[ ] 至少一个 Goal
[ ] 所有 EventPoint ID 唯一
[ ] EventPoint 引用资源存在
[ ] WorldState key 存在
[ ] 关键事件有 success/fail 出口
[ ] 关键事件有至少 2 条处理路径
[ ] 所有必需资产存在
[ ] 所有 AudioMap key 存在
[ ] ScoreRule 可计算
[ ] Restart 不残留 WorldState
[ ] Boss 关卡 Boss 结束条件存在
```

Debug 输出：

```text
[LEVEL VALIDATOR]
L03_CASTLE : PASS 42 / FAIL 0 / WARN 2
```

---

# 26. 系统联调顺序

严格按以下顺序：

```text
1. Cat Movement
2. Ninja Route
3. EventPoint
4. WorldState
5. NPC State Machine
6. Suspicion
7. Score
8. Boss
9. Settlement
10. Save/Load
11. Audio
12. Accessibility
13. Polish
```

未通过前一层，不进入下一层深度美术。

---

# 27. 系统 DoD

任何脚本任务完成必须包含：

```text
[ ] 主路径
[ ] 异常路径
[ ] Reset
[ ] Signal
[ ] Debug 日志
[ ] Data Resource 接口
[ ] Scene 示例
[ ] 至少 1 条自动测试或验证规则
```

---

# 28. 不允许的“方便做法”

禁止：

- 在关卡脚本中硬编码 Event ID 分支作为唯一真相
- 在 NPC 脚本中硬编码具体关卡流程
- 用随机数决定 Ninja 路线
- 用 UI 文本直接驱动 Gameplay
- 用 Node 引用持久化 Save
- 把攻略建议写入 WorldState

允许：

- 小型本地 helper
- 表现层动画状态
- 临时 debug shortcut

---

# 29. System Spec 完成清单

```text
[ ] Cat
[ ] Ninja
[ ] Guard
[ ] Dog
[ ] EventPoint
[ ] WorldState
[ ] Suspicion
[ ] Score
[ ] EventLog
[ ] FailCode
[ ] JumpPoint
[ ] CatTunnel
[ ] Carryable
[ ] Boss
[ ] Settlement
[ ] Save
[ ] Input
[ ] Audio
[ ] Accessibility
[ ] LevelValidator
```
