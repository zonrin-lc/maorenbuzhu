class_name EventBehaviorRegistry
extends RefCounted

static var _cache: Dictionary = {}

static func get_behavior(event_type: StringName) -> EventBehaviorData:
    if _cache.has(event_type):
        return _cache[event_type]
    var path := "res://data/event_behaviors/%s.tres" % String(event_type).to_lower()
    var resource := load(path) as EventBehaviorData
    if resource == null:
        resource = EventBehaviorData.new()
        resource.event_type = event_type
    _cache[event_type] = resource
    return resource

static func action_for(data: EventPointData) -> StringName:
    if data.required_action != &"INTERACT":
        return data.required_action
    return get_behavior(data.event_type).default_action

static func suspicion_for(data: EventPointData) -> float:
    if data.suspicion_override >= 0.0:
        return data.suspicion_override
    return get_behavior(data.event_type).suspicion

static func is_boss_combat(data: EventPointData) -> bool:
    return data.event_group == &"BOSS_COMBAT" or data.event_type == &"BOSS_CALTROP"

static func is_boss_prep(data: EventPointData) -> bool:
    return data.event_group == &"BOSS_PREP" or data.event_type in [&"BOSS_CRANE", &"BOSS_GOURD"]
