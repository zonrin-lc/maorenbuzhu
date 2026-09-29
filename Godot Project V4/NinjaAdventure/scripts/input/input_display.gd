class_name InputDisplay
extends RefCounted

const TOUCH_LABELS := {
    "interact": "互动",
    "carry": "叼取",
    "meow": "喵叫",
    "emote": "卖萌",
    "sprint": "疾跑",
    "jump": "跳跃",
    "pause": "暂停",
    "retry": "重开",
    "confirm": "确定",
    "cancel": "取消",
    "move_up": "摇杆↑",
    "move_down": "摇杆↓",
    "move_left": "摇杆←",
    "move_right": "摇杆→",
}

const ACTION_TO_INPUT := {
    "BITE": "interact",
    "PUSH": "interact",
    "FEED": "interact",
    "PLACE_ANTIDOTE": "interact",
    "SEND_DOG": "interact",
    "JUMP": "jump",
    "CAT_TUNNEL": "jump",
    "MEOW": "meow",
    "EMOTE": "emote",
}

const GAMEPAD_FALLBACKS := {
    "interact": "A",
    "carry": "X",
    "meow": "B",
    "emote": "Y",
    "jump": "LB",
    "sprint": "RB",
    "pause": "START",
    "retry": "LS",
    "confirm": "A",
    "cancel": "B",
}

static func current_device() -> String:
    var tree := Engine.get_main_loop() as SceneTree
    if tree == null:
        return "KEYBOARD_MOUSE"
    var node := tree.root.get_node_or_null("GameInputManager")
    return node.last_device if node != null else "KEYBOARD_MOUSE"

static func get_binding_label(action: StringName) -> String:
    return get_device_binding_label(action, current_device())

static func get_device_binding_label(action: StringName, device: String) -> String:
    var action_key := String(action)
    if ACTION_TO_INPUT.has(action_key):
        action_key = str(ACTION_TO_INPUT[action_key])
    match device:
        "TOUCH":
            return str(TOUCH_LABELS.get(action_key, "触控"))
        "GAMEPAD":
            for event in InputMap.action_get_events(action):
                if event is InputEventJoypadButton:
                    return _joypad_button_label(event.button_index)
                if event is InputEventJoypadMotion:
                    return _joypad_motion_label(event.axis, event.axis_value)
            return str(GAMEPAD_FALLBACKS.get(action_key, "—"))
        _:
            for event in InputMap.action_get_events(action):
                if event is InputEventKey or event is InputEventMouseButton:
                    return _event_to_label(event)
            return "—"

static func get_action_prompt(action: StringName, suffix: String = "") -> String:
    var label := get_binding_label(action)
    return label + suffix

static func get_device_name(device: String) -> String:
    match device:
        "TOUCH": return "触控"
        "GAMEPAD": return "手柄"
        _: return "键鼠"

static func _event_to_label(event: InputEvent) -> String:
    if event is InputEventKey:
        return OS.get_keycode_string(event.physical_keycode if event.physical_keycode != 0 else event.keycode)
    if event is InputEventMouseButton:
        return "鼠标 %d" % event.button_index
    if event is InputEventJoypadButton:
        return _joypad_button_label(event.button_index)
    if event is InputEventJoypadMotion:
        return _joypad_motion_label(event.axis, event.axis_value)
    return "Custom"

static func _joypad_button_label(index: int) -> String:
    # SDL 手柄枚举（与 project.godot 的 button_index 对齐）：0=A 1=B 2=X 3=Y
    # 4=BACK 5=GUIDE 6=START 7=LS 8=RS 9=LB 10=RB 11-14=D-pad
    match index:
        0: return "A"
        1: return "B"
        2: return "X"
        3: return "Y"
        4: return "BACK"
        5: return "GUIDE"
        6: return "START"
        7: return "LS"
        8: return "RS"
        9: return "LB"
        10: return "RB"
        11: return "D↑"
        12: return "D↓"
        13: return "D←"
        14: return "D→"
        _: return "Pad %d" % index

static func _joypad_motion_label(axis: int, value: float) -> String:
    var direction := "+" if value >= 0.0 else "-"
    return "Axis%d%s" % [axis, direction]
