class_name GameInputManager
extends Node

signal device_changed(device: String)

const DEVICE_KEYBOARD_MOUSE := "KEYBOARD_MOUSE"
const DEVICE_GAMEPAD := "GAMEPAD"
const DEVICE_TOUCH := "TOUCH"

var last_device := DEVICE_KEYBOARD_MOUSE

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    set_process_input(true)

func _input(event: InputEvent) -> void:
    var device := _device_for_event(event)
    if device.is_empty():
        return
    set_last_device(device)

func get_move_vector() -> Vector2:
    return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func is_pressed(action: StringName) -> bool:
    return Input.is_action_pressed(action)

func is_just_pressed(action: StringName) -> bool:
    return Input.is_action_just_pressed(action)

func set_last_device(device: String) -> void:
    if device == last_device:
        return
    if device not in [DEVICE_KEYBOARD_MOUSE, DEVICE_GAMEPAD, DEVICE_TOUCH]:
        return
    last_device = device
    device_changed.emit(device)

func is_touch_device() -> bool:
    return last_device == DEVICE_TOUCH

func is_gamepad_device() -> bool:
    return last_device == DEVICE_GAMEPAD

func is_keyboard_mouse_device() -> bool:
    return last_device == DEVICE_KEYBOARD_MOUSE

func _device_for_event(event: InputEvent) -> String:
    if event is InputEventScreenTouch or event is InputEventScreenDrag:
        return DEVICE_TOUCH
    if event is InputEventJoypadButton or event is InputEventJoypadMotion:
        return DEVICE_GAMEPAD
    if event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion or event is InputEventMouseWheel:
        return DEVICE_KEYBOARD_MOUSE
    return ""
