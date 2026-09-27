extends Node

# 结算上下文：关卡 → 居酒屋结算的一次性传参（pending_result 消费即清空）
var result: Dictionary = {}
var event_log: Array[Dictionary] = []
var next_scene_path := ""
var current_scene_path := ""
var first_clear := true

func has_pending() -> bool:
    return not result.is_empty()

func set_pending(p_result: Dictionary, p_log: Array[Dictionary], p_next: String, p_current: String, p_first: bool) -> void:
    result = p_result
    event_log = p_log
    next_scene_path = p_next
    current_scene_path = p_current
    first_clear = p_first

func clear() -> void:
    result = {}
    event_log = []
    next_scene_path = ""
    current_scene_path = ""
    first_clear = true
