class_name DogController
extends Node2D

signal barked()
signal lure_started()
signal lure_ended()

@export var patrol_speed := 45.0
@export var lure_speed := 90.0
@export var lure_duration := 20.0

var home_position := Vector2.ZERO
var target_position := Vector2.ZERO
var state: StringName = &"IDLE"
var lure_timer := 0.0

func setup(start_position: Vector2) -> void:
    position = start_position
    home_position = start_position
    target_position = start_position
    state = &"IDLE"
    lure_timer = 0.0
    queue_redraw()

func lure_to(target: Vector2) -> void:
    target_position = target
    state = &"LURED"
    lure_timer = lure_duration
    lure_started.emit()
    queue_redraw()

func bark() -> void:
    barked.emit()
    queue_redraw()

func _process(delta: float) -> void:
    match state:
        &"LURED":
            position = position.move_toward(target_position, lure_speed * delta)
            lure_timer -= delta
            if lure_timer <= 0.0:
                state = &"RETURN"
                target_position = home_position
                lure_ended.emit()
        &"RETURN":
            position = position.move_toward(home_position, patrol_speed * delta)
            if position.distance_to(home_position) < 2.0:
                state = &"IDLE"
    queue_redraw()

func _draw() -> void:
    var body := Color("#a16207") if state != &"LURED" else Color("#eab308")
    draw_circle(Vector2.ZERO, 16.0, body)
    draw_circle(Vector2(-5, -4), 2.0, Color.BLACK)
    draw_circle(Vector2(5, -4), 2.0, Color.BLACK)
    draw_arc(Vector2.ZERO, 21.0, -PI * 0.7, -PI * 0.3, 12, Color("#fde68a"), 2.0)
