class_name VariantData
extends Resource

## Variant B 确定性脚本变体（GDD §5.3）：只允许改变 Route 分支 / NPC 起始位置 /
## Event 时间窗口 / 资源初始位置 / 一条依赖关系；禁止改变操作方式、失败语义、
## 评分公式与 EventLog schema。

@export var variant_id: StringName
@export var route_overrides: Dictionary = {}
@export var event_overrides: Dictionary = {}
@export var npc_overrides: Dictionary = {}
@export var timer_overrides: Dictionary = {}
@export var suspicion_modifier: float = 1.0
@export var is_hard: bool = false
