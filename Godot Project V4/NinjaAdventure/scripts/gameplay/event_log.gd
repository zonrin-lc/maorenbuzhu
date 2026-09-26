class_name EventLog
extends RefCounted

var entries: Array[Dictionary] = []

func append_event(payload: Dictionary) -> void:
    entries.append(payload.duplicate(true))

func clear() -> void:
    entries.clear()

func count_tag(tag: StringName) -> int:
    var n := 0
    for e in entries:
        if tag in e.get("tags", []):
            n += 1
    return n
