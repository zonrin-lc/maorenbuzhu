class_name RebindManager
extends Node

signal rebind_started(action: String)
signal rebind_applied(action: String, old_event: InputEvent, new_event: InputEvent)
signal rebind_cancelled(action: String, reason: String)
# 跨 Action 冲突：保存前审计发现同一物理输入已被其它 action 占用时发出，
# UI 据此提示“与哪个 action 冲突”。reason 同步以 rebind_cancelled 发出，
# 格式为 "cross_action_conflict:<conflicting_action>"。
signal rebind_conflict(action: String, conflicting_action: String, new_event: InputEvent)

const REBINDABLE_ACTIONS := [
    "move_up", "move_down", "move_left", "move_right",
    "sprint", "interact", "carry", "meow", "emote", "jump", "pause", "retry"
]

# 冲突审计覆盖可重绑 action 以及占用同键位的 UI action（confirm/cancel 与 gameplay 默认有共享键）。
const CONFLICT_AUDIT_ACTIONS := [
    "move_up", "move_down", "move_left", "move_right",
    "sprint", "interact", "carry", "meow", "emote", "jump", "pause", "retry",
    "confirm", "cancel",
]

func begin_rebind(action: String) -> bool:
    if action not in REBINDABLE_ACTIONS:
        return false
    rebind_started.emit(action)
    return true

func get_events(action: String) -> Array[InputEvent]:
    return InputMap.action_get_events(action)

func apply_binding(action: String, new_event: InputEvent) -> bool:
    if action not in REBINDABLE_ACTIONS:
        return false
    var events := InputMap.action_get_events(action)
    var old_event: InputEvent = events[0] if not events.is_empty() else null
    if _would_break_required_actions(action, new_event):
        rebind_cancelled.emit(action, "required_action_conflict")
        return false
    var conflicting := _find_cross_action_conflict(action, new_event)
    if not conflicting.is_empty():
        rebind_conflict.emit(action, conflicting, new_event)
        rebind_cancelled.emit(action, "cross_action_conflict:%s" % conflicting)
        return false
    InputMap.action_erase_events(action)
    InputMap.action_add_event(action, new_event)
    rebind_applied.emit(action, old_event, new_event)
    return true

func restore_defaults(default_event_map: Dictionary) -> void:
    for action in REBINDABLE_ACTIONS:
        if not default_event_map.has(action):
            continue
        InputMap.action_erase_events(action)
        for event in default_event_map[action]:
            InputMap.action_add_event(action, event.duplicate())

func _would_break_required_actions(action: String, event: InputEvent) -> bool:
    if action == "pause" and event == null:
        return true
    return false

func _find_cross_action_conflict(action: String, event: InputEvent) -> String:
    if event == null:
        return ""
    for other in CONFLICT_AUDIT_ACTIONS:
        if other == action:
            continue
        for existing in InputMap.action_get_events(other):
            if _is_same_physical_input(existing, event):
                return other
    return ""

func _is_same_physical_input(a: InputEvent, b: InputEvent) -> bool:
    if a is InputEventKey and b is InputEventKey:
        var ka: int = a.physical_keycode if a.physical_keycode != 0 else a.keycode
        var kb: int = b.physical_keycode if b.physical_keycode != 0 else b.keycode
        return ka == kb
    if a is InputEventJoypadButton and b is InputEventJoypadButton:
        return a.button_index == b.button_index
    if a is InputEventJoypadMotion and b is InputEventJoypadMotion:
        return a.axis == b.axis and signf(a.axis_value) == signf(b.axis_value)
    if a is InputEventMouseButton and b is InputEventMouseButton:
        return a.button_index == b.button_index
    return false
