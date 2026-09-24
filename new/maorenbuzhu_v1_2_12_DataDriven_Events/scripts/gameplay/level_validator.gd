class_name LevelValidator
extends RefCounted

func validate_level(level_data: LevelData) -> Array[String]:
    var errors: Array[String] = []
    if level_data == null:
        return ["LEVEL_DATA_MISSING"]
    if level_data.level_id == StringName():
        errors.append("LEVEL_ID_EMPTY")
    if level_data.display_name.is_empty():
        errors.append("DISPLAY_NAME_EMPTY")
    if level_data.ninja_route == null:
        errors.append("ROUTE_MISSING")
    elif level_data.ninja_route.waypoints.size() < 2:
        errors.append("ROUTE_TOO_SHORT")
    if level_data.events.is_empty():
        errors.append("EVENTS_EMPTY")
    var last_route_index := -1
    for e in level_data.events:
        if e == null:
            errors.append("EVENT_NULL")
            continue
        if e.event_id == StringName():
            errors.append("EVENT_ID_EMPTY")
        if e.timeout < 0.0:
            errors.append("EVENT_TIMEOUT_INVALID:" + String(e.event_id))
        if e.route_index < last_route_index:
            errors.append("EVENT_ROUTE_ORDER_INVALID:" + String(e.event_id))
        if e.event_type == &"BOSS_CALTROP" and e.timeout != 0.0:
            errors.append("BOSS_CALTROP_TIMEOUT_INVALID")
        last_route_index = max(last_route_index, e.route_index)
    return errors
