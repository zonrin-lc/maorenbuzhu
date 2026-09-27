class_name DockEventPoint
extends Area2D

signal resolved(data: EventPointData, action_id: StringName)
signal failed(data: EventPointData, fail_code: StringName)

var data: EventPointData
var level_manager: Node
var resolved_state := false
var timer := 0.0
var interaction_progress := 0.0
var interacting := false

func setup(event_data: EventPointData, manager: Node) -> void:
    data = event_data
    level_manager = manager
    queue_redraw()

func _process(delta: float) -> void:
    if resolved_state or level_manager == null or level_manager.level_finished or level_manager.level_failed:
        return
    var ninja: NinjaController = level_manager.ninja
    var cat: CatController = level_manager.cat
    if ninja == null or cat == null:
        return
    var ninja_in_range := global_position.distance_to(ninja.global_position) <= data.trigger_radius
    timer = timer + delta if ninja_in_range else 0.0

    var action := _input_action(cat)
    if action != &"":
        if not interacting and global_position.distance_to(cat.global_position) <= 52.0:
            interacting = true
            interaction_progress = 0.0
            level_manager.on_player_action_started(data, action)
        if interacting and global_position.distance_to(cat.global_position) <= 60.0:
            interaction_progress += delta
            if interaction_progress >= data.interaction_time:
                resolve(action)
        elif interacting:
            _cancel()

    if ninja_in_range and timer >= data.timeout:
        fail(data.fail_code)
    queue_redraw()

func _input_action(cat: CatController) -> StringName:
    match data.event_type:
        &"GUARD":
            return &"MEOW" if Input.is_key_pressed(KEY_F) else &""
        &"DOG":
            return &"FEED" if Input.is_key_pressed(KEY_E) and cat.carry_item == &"FISH" else &""
        &"POISON":
            return &"PLACE_ANTIDOTE" if Input.is_key_pressed(KEY_E) and cat.carry_item == &"ANTIDOTE" else &""
        &"BRIDGE", &"CALTRAP":
            return &"PUSH" if Input.is_key_pressed(KEY_E) else &""
        _:
            return &"INTERACT" if Input.is_key_pressed(KEY_E) else &""

func resolve(action_id: StringName) -> void:
    if resolved_state:
        return
    resolved_state = true
    interacting = false
    resolved.emit(data, action_id)
    queue_redraw()

func fail(code: StringName) -> void:
    if resolved_state:
        return
    resolved_state = true
    interacting = false
    failed.emit(data, code)
    queue_redraw()

func _cancel() -> void:
    interacting = false
    interaction_progress = 0.0

func _draw() -> void:
    if data == null:
        return
    var c := Color("#22c55e") if resolved_state else Color("#ef4444")
    draw_circle(Vector2.ZERO, 14.0, c)
    draw_circle(Vector2.ZERO, data.trigger_radius, Color(1, 1, 1, 0.04))
    if interacting:
        draw_arc(Vector2.ZERO, 22.0, -PI * 0.5, -PI * 0.5 + TAU * clamp(interaction_progress / max(0.01, data.interaction_time), 0.0, 1.0), 24, Color("#fbbf24"), 4.0)
