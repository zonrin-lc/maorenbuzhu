class_name EventPoint
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
    var ninja = level_manager.ninja
    var cat = level_manager.cat
    if ninja == null or cat == null:
        return

    var ninja_in_range := global_position.distance_to(ninja.global_position) <= data.trigger_radius
    if ninja_in_range:
        timer += delta
    else:
        timer = 0.0

    if data.event_type == &"GUARD":
        if ninja_in_range and not resolved_state and timer >= data.timeout:
            fail(data.fail_code)
        queue_redraw()
        return

    if global_position.distance_to(cat.global_position) <= 48.0 and Input.is_action_pressed("interact"):
        if not interacting:
            interacting = true
            interaction_progress = 0.0
            level_manager.on_player_action_started(data, &"INTERACT")

    if interacting:
        if global_position.distance_to(cat.global_position) > 58.0:
            _cancel_action(data)
        else:
            interaction_progress += delta
            if interaction_progress >= data.interaction_time:
                var action_id := &"BITE" if data.event_type == &"TRIPWIRE" else &"PUSH"
                resolve(action_id)

    if ninja_in_range and not resolved_state and timer >= data.timeout:
        fail(data.fail_code)
    queue_redraw()

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

func _cancel_action(event_data: EventPointData) -> void:
    if interacting:
        level_manager.on_player_action_cancelled(event_data)
    interacting = false
    interaction_progress = 0.0

func _draw() -> void:
    if data == null:
        return
    var base_color := Color("#22c55e") if resolved_state else Color("#ef4444")
    if data.event_type == &"GUARD" and level_manager != null and level_manager.guard != null and not level_manager.guard.active:
        base_color = Color("#22c55e")
    draw_circle(Vector2.ZERO, 13.0, base_color)
    draw_circle(Vector2.ZERO, data.trigger_radius, Color(1, 1, 1, 0.04))
    var label := String(data.display_name)
    var font := ThemeDB.fallback_font
    draw_string(font, Vector2(-52, -24), label, HORIZONTAL_ALIGNMENT_CENTER, 104, 14, Color("#f8fafc"))
    if interacting:
        draw_arc(Vector2.ZERO, 21.0, -PI * 0.5, -PI * 0.5 + TAU * clamp(interaction_progress / max(0.01, data.interaction_time), 0.0, 1.0), 24, Color("#fbbf24"), 4.0)
