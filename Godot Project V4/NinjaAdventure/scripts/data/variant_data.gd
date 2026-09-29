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

## 加载时调用（_apply_variant 前）：Variant B 是确定性脚本变体，字段类型必须合法，
## 否则打印错误并返回 false（GDD §5.3：变体只允许数据型覆盖）。
func validate() -> bool:
    var ok := true
    for key in npc_overrides:
        if not key is StringName:
            push_error("VariantData %s: npc_overrides 键必须是 StringName（事件 ID 或 &\"DOG\"），实际是 %s" % [variant_id, key])
            ok = false
        if not npc_overrides[key] is Vector2:
            push_error("VariantData %s: npc_overrides[%s] 必须是 Vector2（出生点坐标），实际是 %s" % [variant_id, key, type_string(typeof(npc_overrides[key]))])
            ok = false
    for key in event_overrides:
        if not event_overrides[key] is Dictionary:
            push_error("VariantData %s: event_overrides[%s] 必须是 Dictionary（字段覆盖表）" % [variant_id, key])
            ok = false
    return ok
