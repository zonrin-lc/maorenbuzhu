class_name GameInputManager
extends Node

signal device_changed(device: String)

const DEVICE_KEYBOARD_MOUSE := "KEYBOARD_MOUSE"
const DEVICE_GAMEPAD := "GAMEPAD"
const DEVICE_TOUCH := "TOUCH"

var last_device := DEVICE_KEYBOARD_MOUSE

func get_move_vector() -> Vector2:
    return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func is_pressed(action: StringName) -> bool:
    return Input.is_action_pressed(action)

func is_just_pressed(action: StringName) -> bool:
    return Input.is_action_just_pressed(action)

func set_last_device(device: String) -> void:
    if device == last_device:
        return
    last_device = device
    device_changed.emit(device)
