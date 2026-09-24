# 《猫忍不住》v1.2.5
## Data Resource 数据资源制作规范

> 目的：把 v1.2.4 的 12 关白盒设计进一步落成 Godot 4 的 Data Resource 制作层。
>
> 原则：**数据控制内容，脚本控制行为，Scene 控组成。**
>
> 本文不是新增玩法，不改变 v1.2 已冻结的核心规则；只定义数据结构、命名、字段、依赖与 12 关实例。

---

# 0. 资源目录

```text
res://
├─ data/
│  ├─ levels/
│  │  ├─ ch01_village/
│  │  ├─ ch02_dock/
│  │  └─ ch03_castle/
│  ├─ events/
│  ├─ routes/
│  ├─ shortcuts/
│  ├─ world_flags/
│  ├─ score/
│  ├─ variants/
│  ├─ boss/
│  └─ banter/
│
├─ scenes/
│  ├─ levels/
│  ├─ actors/
│  ├─ events/
│  └─ ui/
│
└─ scripts/
   ├─ data/
   ├─ gameplay/
   ├─ actors/
   └─ debug/
```

建议数据脚本：

```text
LevelData.gd
RouteData.gd
EventPointData.gd
ShortcutData.gd
WorldFlagData.gd
ScoreRuleData.gd
VariantData.gd
BossData.gd
BanterSetData.gd
```

---

# 1. Data Resource 总原则

## 1.1 禁止把关卡内容硬编码进控制器

错误：

```gdscript
if level_id == "L07":
    guard_b_delay = 8.0
```

正确：

```gdscript
level_data.route_data.guard_b.switch_delay
```

## 1.2 Resource 只描述事实和参数

禁止写：

```text
player_should_go_here
correct_solution
best_route
```

允许写：

```text
route_id
trigger_event_id
caused_event_id
window_start
window_end
```

即：记录系统需要知道的事实，不记录攻略答案。

---

# 2. LevelData

文件：

```text
LevelData.gd
```

建议继承：

```gdscript
class_name LevelData
extends Resource
```

## 2.1 字段

| 字段 | 类型 | 必填 | 说明 |
|---|---|---:|---|
| level_id | StringName | ✓ | 唯一 ID |
| chapter_id | StringName | ✓ | CH01/CH02/CH03 |
| display_name | String | ✓ | 关卡名称 |
| scene_path | String | ✓ | `.tscn` |
| intro_time | float | ✓ | 读图阶段秒数 |
| target_time | float | ✓ | 猫爪 C 时间条件 |
| ninja_route | Resource[RouteData] | ✓ | 主路线 |
| events | Array[EventPointData] | ✓ | 事件列表 |
| shortcuts | Array[ShortcutData] | ✓ | 捷径 |
| world_flags | Array[WorldFlagData] | ✓ | 初始/关卡事实 |
| score_rules | ScoreRuleData | ✓ | 评分规则 |
| variant | Resource[VariantData] | ✓ | 剧本变体 |
| audio_map_id | StringName | ✓ | 音频配置 |
| banter_set_id | StringName | ✓ | 吹牛池 |
| difficulty_modifier | Dictionary | ✓ | Hard/Hard+ 参数入口 |
| validator_rules | Array[StringName] | ✓ | LevelValidator 规则 |

---

# 3. RouteData

## 3.1 作用

描述忍者和需要脚本化 NPC 的**固定路线**。

```gdscript
class_name RouteData
extends Resource
```

## 3.2 字段

| 字段 | 类型 | 说明 |
|---|---|---|
| route_id | StringName | 唯一路线 ID |
| actor_id | StringName | Ninja / GuardA / GuardB / Dog |
| waypoints | Array[Vector2] | 路线锚点 |
| loop | bool | 是否循环 |
| move_speed | float | 基础速度 |
| stop_points | Array[StringName] | 停留点 |
| branch_rules | Array[StringName] | 仅引用预设分支规则 |
| return_delay | float | 回岗延迟 |
| variant_routes | Array[StringName] | Variant B 路线引用 |

### 示例

```text
ROUTE_L07_NINJA_MAIN
actor = NINJA_BLUE
speed = 60
loop = false
branch_rules = [BRANCH_GUARD_B_SHIFT]
```

---

# 4. EventPointData

每个核心事件点一个 Resource。

```gdscript
class_name EventPointData
extends Resource
```

## 4.1 字段

| 字段 | 类型 | 说明 |
|---|---|---|
| event_id | StringName | 唯一 ID |
| event_type | StringName | TRIPWIRE / GUARD / DOG / POISON / ... |
| classification | StringName | CRITICAL / STANDARD / OPTIONAL |
| actor_id | StringName | 主要关联 actor |
| trigger_radius | float | 触发半径 |
| hesitation_time | float | 忍者犹豫秒数 |
| timeout | float | 超时阈值 |
| interaction_time | float | 猫处理时间 |
| required_item | StringName | 所需道具，可空 |
| fail_code | StringName | 失败原因 |
| success_flags | Array[StringName] | 成功后写入世界状态 |
| failure_flags | Array[StringName] | 失败后写入世界状态 |
| caused_event_ids | Array[StringName] | 后续因果事件 |
| risk_level | StringName | SAFE / BALANCED / RISKY |
| high_risk | bool | 是否计入高风险救场 |
| allow_standard_solution | bool | 是否标准解 |
| allow_risky_solution | bool | 是否风险解 |
| banter_tags | Array[StringName] | 结算关键词 |
| validator_rules | Array[StringName] | 事件级 QA |

---

# 5. ShortcutData

## 5.1 字段

| 字段 | 类型 | 说明 |
|---|---|---|
| shortcut_id | StringName | 唯一 ID |
| entrance_marker | NodePath / StringName | 入口 |
| exit_marker | NodePath / StringName | 出口 |
| required_ability | StringName | CAT_TUNNEL / JUMP / NONE |
| time_saving | float | 理论节省时间 |
| visibility_risk | float | 进入捷径的怀疑风险 |
| usable_when | Array[StringName] | 可用世界状态 |
| mastery_tag | StringName | 是否计入 shortcut_or_dependency_mastery |

---

# 6. WorldFlagData

只存世界事实。

```text
WF_L07_GUARD_A_DEPARTED
WF_L07_GUARD_B_SHIFTED
WF_L07_DOG_FED
WF_L07_BRIDGE_OPEN
```

禁止：

```text
WF_PLAYER_SHOULD_FEED_DOG_FIRST
```

## 字段

| 字段 | 类型 | 说明 |
|---|---|---|
| flag_id | StringName | 唯一 ID |
| default_value | bool | 初始值 |
| reset_on_retry | bool | 重试是否恢复 |
| persistent | bool | 是否跨事件持久化 |
| debug_label | String | Debug 显示名称 |

---

# 7. ScoreRuleData

## 7.1 固定规则

### Paw 1

```text
mission_complete
```

### Paw 2

```text
mission_complete
AND ninja_hp >= 2
AND max_suspicion < 80
```

### Paw 3

基础资格：

```text
mission_complete
AND ninja_hp >= 2
```

普通关：A-F 满足 4 项。

第三章 Boss 关：A-G 满足 4 项。

```text
A = ninja_hp == 3
B = max_suspicion < 50
C = elapsed_time <= target_time
D = high_risk_rescue >= 1
E = chain_rescue >= 1
F = shortcut_or_dependency_mastery == true
G = boss_mechanics_success >= 2
```

## 7.2 字段

| 字段 | 类型 |
|---|---|
| target_time | float |
| paw2_hp_min | int |
| paw2_suspicion_max | float |
| paw3_base_hp_min | int |
| paw3_required_count | int |
| condition_ids | Array[StringName] |
| boss_condition_ids | Array[StringName] |

---

# 8. VariantData

变体必须：

- 手工制作
- 可预测
- 数据驱动
- 不随机改变地图答案

字段：

| 字段 | 类型 |
|---|---|
| variant_id | StringName |
| route_overrides | Dictionary |
| event_overrides | Dictionary |
| npc_overrides | Dictionary |
| timer_overrides | Dictionary |
| suspicion_modifier | float |
| is_hard | bool |

推荐命名：

```text
L01_VA
L01_VB
...
L12_VA
L12_VB
```

---

# 9. BossData

只供 L12 使用。

| 字段 | 类型 | 说明 |
|---|---|---|
| boss_id | StringName | BOSS_GATEKEEPER |
| max_hp | int | Boss HP |
| phase_durations | Dictionary | Phase 时间 |
| crane_damage | int | 吊车伤害 |
| caltrop_damage | int | 蒺藜伤害 |
| gourd_delay | float | 酒葫芦延迟 |
| emergency_window | float | 1.5–2.0s |
| emergency_enabled | bool | 固定 true |
| phase2_caltrop_window | float | 战中处理窗口 |
| retreat_on_emergency | bool | true |

---

# 10. BanterSetData

吹牛不随机选空模板，而是根据 EventLog Tags 匹配。

```text
Importance
→ Tags
→ Compatible Template
→ Fill Params
```

字段：

| 字段 | 类型 |
|---|---|
| set_id | StringName |
| template_ids | Array[StringName] |
| required_tags | Array[StringName] |
| priority | int |
| fallback_template | StringName |

优先级保持：

```text
Emergency
>
Near Death
>
Boss
>
Chain
>
Route Change
>
Normal Success
```

---

# 11. 12 关实际 Data Resource 配置表

> 以下是第一版制作数据，不代表最终数值锁定；数值调节必须通过 Resource 修改，禁止直接改脚本。

| Level | 名称 | 事件数 | Target | 主要机制 | 主路线标签 |
|---|---|---:|---:|---|---|
| L01 | 第一份差事 | 3 | 60s | 绊绳/守卫/水沟 | ACTION_BASIC |
| L02 | 他总是踩同一个坑 | 4 | 55s | 连续事件/赶场 | ACTION_RUSH |
| L03 | 谁在看猫 | 4 | 65s | 视线/怀疑/卖萌 | SUSPICION |
| L04 | 村口大事故 | 5 | 70s | 顺序/双解 | ORDER_BASIC |
| L05 | 月夜码头 | 5 | 85s | 搬运/鱼/狗/桥 | CARRY |
| L06 | 狗也能当队友 | 5 | 80s | Dog 联动 | NPC_LINK |
| L07 | 谁先走 | 6 | 95s | Guard A/B 换岗 | DEPENDENCY |
| L08 | 最后一班船 | 7 | 110s | 多线程/运输 | MULTI_THREAD |
| L09 | 雷雨夜 | 6 | 90s | 雷雨/守卫/炸药 | PRESSURE |
| L10 | 炸药不能乱碰 | 7 | 100s | 连锁事故 | CHAIN_REACTION |
| L11 | 越靠近城门越忙 | 8 | 120s | 三线程 | MULTI_THREAD_HARD |
| L12 | 守门武士 | 3 + Boss | 125s | 三机关/Boss | BOSS |

---

# 12. L01-L12 Resource 文件清单

```text
res://data/levels/ch01_village/L01_first_job.tres
res://data/levels/ch01_village/L02_same_trap.tres
res://data/levels/ch01_village/L03_who_is_watching.tres
res://data/levels/ch01_village/L04_village_accident.tres

res://data/levels/ch02_dock/L05_moonlit_dock.tres
res://data/levels/ch02_dock/L06_dog_ally.tres
res://data/levels/ch02_dock/L07_who_goes_first.tres
res://data/levels/ch02_dock/L08_last_boat.tres

res://data/levels/ch03_castle/L09_storm_night.tres
res://data/levels/ch03_castle/L10_dont_touch_dynamite.tres
res://data/levels/ch03_castle/L11_busy_gate.tres
res://data/levels/ch03_castle/L12_gatekeeper_boss.tres
```

---

# 13. 事件 ID 命名规则

```text
L01_E01_TRIPWIRE
L01_E02_GUARD
L01_E03_WATERGAP

L07_E01_GUARD_A
L07_E02_DOG
L07_E03_GUARD_B
L07_E04_BRIDGE
L07_E05_POISON
L07_E06_CALTRop

L12_E01_CRANE
L12_E02_GOURD
L12_E03_CALTRop
```

统一：

```text
LEVEL + E## + TYPE
```

---

# 14. Route ID 命名

```text
L01_ROUTE_NINJA_MAIN
L02_ROUTE_NINJA_MAIN
L03_ROUTE_NINJA_MAIN
L04_ROUTE_NINJA_MAIN

L06_ROUTE_DOG
L07_ROUTE_GUARD_A
L07_ROUTE_GUARD_B
L08_ROUTE_DOG

L11_ROUTE_GUARD_A
L11_ROUTE_GUARD_B
L12_ROUTE_BOSS_CHARGE
```

---

# 15. 关键事件数据实例

## 15.1 L01 绊绳

```text
id = L01_E01_TRIPWIRE
classification = CRITICAL
interaction_time = 0.8
hesitation_time = 0
risk_level = BALANCED
high_risk = true
fail_code = FAIL_TOO_LATE
success_flags = [L01_TRIPWIRE_SAFE]
```

## 15.2 L06 狗

```text
id = L06_E02_DOG
classification = CRITICAL
interaction_time = 0
required_item = FISH
risk_level = RISKY
high_risk = true
caused_event_ids = [L06_E03_GUARD_SHIFT]
```

标准解：鱼引狗。

风险解：猫做诱饵。

## 15.3 L07 Guard A

```text
id = L07_E01_GUARD_A
classification = CRITICAL
risk_level = BALANCED
success_flags = [L07_GUARD_A_DEPARTED]
caused_event_ids = [L07_E03_GUARD_B]
```

## 15.4 L12 蒺藜

```text
id = L12_E03_CALTROP
classification = CRITICAL
risk_level = RISKY
high_risk = true
validator_rules = [BOSS_PHASE2_ACTION]
```

---

# 16. Event Dependency 表示法

设计工具中建议使用：

```text
caused_event_ids
```

而不是在 EventPoint 中写大段逻辑。

例如：

```text
E01 Guard A
    ↓ caused_event
E03 Guard B
    ↓ caused_event
E04 Bridge
```

脚本只负责：

```text
读取事件完成事实
→ 写 WorldFlag
→ 触发下一个事件允许状态
```

---

# 17. Resource 加载规则

LevelManager：

```text
load LevelData
↓
load RouteData
↓
register EventPointData
↓
apply WorldFlagData
↓
bind ScoreRuleData
↓
load VariantData
↓
spawn Scene
```

禁止 EventPoint 自己再去寻找整个 Level 数据文件。

推荐依赖方向：

```text
LevelManager
   ↓
LevelData
   ├─ RouteData
   ├─ EventPointData
   ├─ ShortcutData
   ├─ WorldFlagData
   ├─ ScoreRuleData
   └─ VariantData
```

避免循环依赖。

---

# 18. LevelValidator 数据检查

每次运行关卡前自动检查：

### ID

```text
Level ID 唯一
Event ID 唯一
Route ID 唯一
Flag ID 唯一
```

### 引用

```text
Event -> caused_event 存在
Event -> required_item 存在
Shortcut -> marker 存在
Level -> scene_path 存在
```

### 逻辑

```text
主路线存在
Goal 存在
MissionComplete 出口存在
失败出口存在
Critical Event 至少一个标准解
Critical Event 至少一个风险解
```

### Boss

L12 必须：

```text
Crane
Gourd
Caltrop
Emergency
Boss Phase 1/2/3
```

---

# 19. 编辑器下可视化字段

建议为关键字段增加 `@export_category`：

```gdscript
@export_category("Identity")
@export var level_id: StringName
@export var display_name: String

@export_category("Timing")
@export var intro_time: float
@export var target_time: float

@export_category("Gameplay")
@export var events: Array[EventPointData]
@export var shortcuts: Array[ShortcutData]

@export_category("Scoring")
@export var score_rules: ScoreRuleData

@export_category("QA")
@export var validator_rules: Array[StringName]
```

目标：设计师打开 `.tres` 就能看到可编辑字段，不需要进入脚本。

---

# 20. 制作 SOP

创建一关时严格按：

```text
01 创建 LevelData
02 创建 RouteData
03 创建 EventPointData
04 创建 ShortcutData
05 创建 WorldFlagData
06 创建 ScoreRuleData
07 创建 VariantData
08 在 .tscn 放入实际节点
09 将 Node 引用绑定到 Data ID
10 运行 LevelValidator
11 白盒通关
12 录入 Playtest 结果
13 再进入美术
```

禁止顺序：

```text
先做精美地图
→ 再想事件
→ 再补脚本
```

---

# 21. 第一批程序工作包

优先级：

## P0

```text
LevelData.gd
RouteData.gd
EventPointData.gd
WorldFlagData.gd
ScoreRuleData.gd
VariantData.gd
LevelManager.gd
LevelValidator.gd
```

## P1

```text
ShortcutData.gd
BossData.gd
BanterSetData.gd
DebugDataOverlay.gd
```

## P2

```text
ReplayData.gd
ShareCardData.gd
```

---

# 22. 第一批资源制作顺序

```text
L01 全部 Data Resource
↓
L01 Playable
↓
复制模板到 L02-L04
↓
Chapter 01 Gate
↓
复制到 L05-L08
↓
Chapter 02 Gate
↓
复制到 L09-L12
↓
Boss Gate
```

不要同时独立创建 12 套 Resource。

---

# 23. v1.2.5 验收标准

本阶段完成的定义不是“写完字段”，而是：

```text
[ ] 每关存在 LevelData
[ ] 每个核心事件存在 EventPointData
[ ] 每条忍者主路线存在 RouteData
[ ] 捷径有 ShortcutData
[ ] 世界状态有 WorldFlagData
[ ] 三猫爪有 ScoreRuleData
[ ] Variant 有独立 Resource
[ ] L12 有 BossData
[ ] 所有 ID 唯一
[ ] 所有引用合法
[ ] LevelValidator 可扫描
[ ] L01 可仅依赖 Data + Scene 跑通
```

---

# 24. 下一阶段

v1.2.5 完成后，进入：

> **v1.2.6 Godot 原型工程层**

目标是直接生成：

```text
res://data/...
res://scenes/...
res://scripts/...
```

并以 L01 为模板建立第一套：

```text
LevelData
+
RouteData
+
EventPointData
+
WorldState
+
NinjaController
+
CatController
+
ScoreSystem
+
LevelValidator
```

形成第一条真正可运行的垂直切片。
