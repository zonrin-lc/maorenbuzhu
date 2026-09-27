class_name RebindManager
extends Node

signal rebind_started(action: String)
signal rebind_applied(action: String, old_event: InputEvent, new_event: InputEvent)
signal rebind_cancelled(action: String, reason: String)

const REBINDABLE_ACTIONS := [
    "move_up", "move_down", "move_left", "move_right",
    "sprint", "interact", "carry", "meow", "emote", "jump", "pause", "retry"
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
