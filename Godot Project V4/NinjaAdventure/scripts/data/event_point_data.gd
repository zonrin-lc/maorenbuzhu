class_name EventPointData
extends Resource

@export var event_id: StringName
@export var event_type: StringName = &"TRIPWIRE"
@export var display_name: String = ""
@export var classification: StringName = &"CRITICAL"
@export var actor_id: StringName = &"NINJA_BLUE"
@export var route_index: int = 1
@export var trigger_radius: float = 34.0
@export var hesitation_time: float = 0.0
@export var timeout: float = 3.0
@export var interaction_time: float = 0.8
@export var fail_code: StringName = &"FAIL_TOO_LATE"
@export var success_flags: Array[StringName] = []
@export var failure_flags: Array[StringName] = []
@export var caused_event_ids: Array[StringName] = []
@export var risk_level: StringName = &"SAFE"
@export var high_risk: bool = false
@export var allow_standard_solution: bool = true
@export var allow_risky_solution: bool = false
@export var required_action: StringName = &"INTERACT"
@export var suspicion_override: float = -1.0 # -1 uses EventBehaviorData; otherwise exact per-event suspicion value
@export var banter_tags: Array[StringName] = []

# v1.2.11 unified event architecture
@export var event_group: StringName = &"MAIN" # MAIN / BOSS_PREP / BOSS_COMBAT / OPTIONAL
@export var activation_phase: int = 0 # 0 = any, otherwise matches gameplay phase
@export var activation_flag: StringName = &"" # optional WorldState prerequisite
@export var consume_carry_item: StringName = &"" # optional item consumed on success
@export var non_blocking: bool = false # event never blocks Ninja route

@export var success_effects: Array[Resource] = [] # EventEffectData resources; behavior stays data-driven
@export var resolved_offset: Vector2 = Vector2.ZERO # whitebox visual motion applied to the event prop on success
@export var resolved_motion_time: float = 0.42
