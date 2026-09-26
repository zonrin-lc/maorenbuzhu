class_name WorldState
extends RefCounted

var flags: Dictionary = {}

func set_flag(flag_id: StringName, value: bool = true) -> void:
    flags[String(flag_id)] = value

func get_flag(flag_id: StringName) -> bool:
    return bool(flags.get(String(flag_id), false))

func reset() -> void:
    flags.clear()
