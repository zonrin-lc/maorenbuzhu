# 《猫忍不住》v1.2.5
## Data Resource `.tres` 示例包

以下示例用于程序直接照着创建资源。字段名与 `DataResource_Spec` 保持一致。

---

## 1. L01 LevelData

文件：

`res://data/levels/ch01_village/L01_first_job.tres`

```ini
[gd_resource type="Resource" script_class="LevelData" load_steps=5 format=3]

[resource]
level_id = &"L01"
chapter_id = &"CH01"
display_name = "第一份差事"
scene_path = "res://scenes/levels/ch01/L01_first_job.tscn"
intro_time = 10.0
target_time = 60.0
ninja_route = ExtResource("1")
events = Array[ExtResource("2")]([ExtResource("2"), ExtResource("3"), ExtResource("4")])
shortcuts = []
score_rules = ExtResource("5")
```

> 实际项目中由 Godot 编辑器生成 ext_resource ID，不要手写与项目文件冲突的 UUID。

---

## 2. L01 绊绳 EventPointData

文件：

`res://data/events/L01_E01_TRIPWIRE.tres`

```ini
[gd_resource type="Resource" script_class="EventPointData"]

[resource]
event_id = &"L01_E01_TRIPWIRE"
event_type = &"TRIPWIRE"
classification = &"CRITICAL"
actor_id = &"NINJA_BLUE"
trigger_radius = 24.0
hesitation_time = 0.0
timeout = 5.0
interaction_time = 0.8
required_item = &"NONE"
fail_code = &"FAIL_TOO_LATE"
success_flags = [&"L01_TRIPWIRE_SAFE"]
failure_flags = [&"L01_TRIPWIRE_FAILED"]
caused_event_ids = []
risk_level = &"BALANCED"
high_risk = true
allow_standard_solution = true
allow_risky_solution = true
banter_tags = [&"TRIPWIRE", &"NEAR_MISS"]
```

---

## 3. L06 Dog EventPointData

```ini
[gd_resource type="Resource" script_class="EventPointData"]

[resource]
event_id = &"L06_E02_DOG"
event_type = &"DOG"
classification = &"CRITICAL"
actor_id = &"DOG"
trigger_radius = 40.0
hesitation_time = 3.0
timeout = 5.0
interaction_time = 0.0
required_item = &"FISH"
fail_code = &"FAIL_WRONG_ORDER"
success_flags = [&"L06_DOG_DIVERTED"]
failure_flags = []
caused_event_ids = [&"L06_E03_GUARD_SHIFT"]
risk_level = &"RISKY"
high_risk = true
allow_standard_solution = true
allow_risky_solution = true
banter_tags = [&"DOG", &"CHAIN"]
```

---

## 4. L07 Guard A → Guard B 依赖

### Guard A

```ini
[resource]
event_id = &"L07_E01_GUARD_A"
event_type = &"GUARD"
classification = &"CRITICAL"
actor_id = &"GUARD_A"
interaction_time = 0.0
success_flags = [&"L07_GUARD_A_DEPARTED"]
caused_event_ids = [&"L07_E03_GUARD_B"]
risk_level = &"BALANCED"
high_risk = false
```

### Guard B

```ini
[resource]
event_id = &"L07_E03_GUARD_B"
event_type = &"GUARD"
classification = &"CRITICAL"
actor_id = &"GUARD_B"
interaction_time = 0.0
success_flags = [&"L07_GUARD_B_SHIFTED"]
risk_level = &"BALANCED"
```

换岗延迟不要写进 EventPoint 文本，而应进入 RouteData / branch rule。

---

## 5. L12 BossData

文件：

`res://data/boss/BOSS_GATEKEEPER.tres`

```ini
[gd_resource type="Resource" script_class="BossData"]

[resource]
boss_id = &"BOSS_GATEKEEPER"
max_hp = 100
crane_damage = 40
caltrop_damage = 30
gourd_delay = 10.0
emergency_window = 1.75
emergency_enabled = true
phase2_caltrop_window = 3.0
retreat_on_emergency = true
```

---

## 6. L12 Boss 事件

### 吊车

```text
L12_E01_CRANE
prepare_only = true
phase_trigger = BOSS_PHASE_1
```

### 酒葫芦

```text
L12_E02_GOURD
prepare_only = true
phase_trigger = BOSS_INTRO
```

### 蒺藜

```text
L12_E03_CALTROP
prepare_only = false
phase_trigger = BOSS_PHASE_2
validator = BOSS_PHASE2_ACTION
```

---

## 7. 建议的脚本接口

### LevelManager

```gdscript
func load_level(data: LevelData) -> void
func reset_level() -> void
func complete_level() -> void
```

### EventPoint

```gdscript
func configure(data: EventPointData) -> void
func activate() -> void
func resolve(action_id: StringName) -> void
func fail(code: StringName) -> void
```

### WorldState

```gdscript
func set_flag(flag_id: StringName, value: bool) -> void
func get_flag(flag_id: StringName) -> bool
func reset() -> void
```

### ScoreSystem

```gdscript
func evaluate(result: RunResult) -> int
```

### LevelValidator

```gdscript
func validate(level_data: LevelData) -> ValidationReport
```

---

## 8. Godot Inspector 检查顺序

打开任意 LevelData 后：

```text
Identity
→ Timing
→ Route
→ Events
→ Shortcuts
→ WorldState
→ Score
→ Variant
→ Audio
→ Banter
→ QA
```

这样设计师不需要进入脚本文件寻找参数。
