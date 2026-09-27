class_name EventBehaviorData
extends Resource

@export var event_type: StringName
@export var default_action: StringName = &"INTERACT"
@export var suspicion: float = 10.0
@export var default_interaction_time: float = 0.8
@export var default_event_group: StringName = &"MAIN"
@export var default_non_blocking: bool = false
