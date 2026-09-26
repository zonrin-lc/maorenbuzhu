class_name InputDisplay
extends RefCounted

static func get_binding_label(action: StringName) -> String:
    var events := InputMap.action_get_events(action)
    if events.is_empty():
        return "—"
    return _event_to_label(events[0])

static func _event_to_label(event: InputEvent) -> String:
    if event is InputEventKey:
        return OS.get_keycode_string(event.physical_keycode if event.physical_keycode != 0 else event.keycode)
    if event is InputEventMouseButton:
        return "Mouse %d" % event.button_index
    if event is InputEventJoypadButton:
        return "Pad %d" % event.button_index
    if event is InputEventJoypadMotion:
        return "Axis %d" % event.axis
    return "Custom"
