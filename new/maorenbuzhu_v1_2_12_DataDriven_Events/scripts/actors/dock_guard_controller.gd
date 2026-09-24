class_name DockGuardController
extends Node2D

signal state_changed(state_id: StringName)

@export var patrol_speed := 35.0
@export var return_delay := 6.0

var rest_position := Vector2.ZERO
var patrol_left := Vector2(-90, 0)
var patrol_right := Vector2(90, 0)
var direction := 1.0
var state: StringName = &"ACTIVE"
var timer := 0.0
var lure_position := Vector2.ZERO

func setup(center: Vector2) -> void:
    position = center
    rest_position = center
    state = &"ACTIVE"
    timer = 0.0
    direction = 1.0
    queue_redraw()

func depart(target: Vector2, duration: float = return_delay) -> void:
    lure_position = target
    timer = duration
    state = &"DISTRACTED"
    state_changed.emit(state)

func _process(delta: float) -> void:
    match state:
        &"ACTIVE":
            position.x += direction * patrol_speed * delta
            var left := rest_position + patrol_left
            var right := rest_position + patrol_right
            if position.x >= right.x:
                direction = -1.0
            elif position.x <= left.x:
                direction = 1.0
        &"DISTRACTED":
            position = position.move_toward(lure_position, patrol_speed * 2.0 * delta)
            timer -= delta
            if timer <= 0.0:
                position = rest_position
                state = &"ACTIVE"
                state_changed.emit(state)
    queue_redraw()

func _draw() -> void:
    var c := Color("#dc2626") if state == &"ACTIVE" else Color("#64748b")
    draw_circle(Vector2.ZERO, 17.0, c)
    draw_rect(Rect2(-8, -4, 16, 8), Color("#fecaca") if state == &"ACTIVE" else Color("#cbd5e1"))
    draw_circle(Vector2(-5, -5), 1.6, Color.BLACK)
    draw_circle(Vector2(5, -5), 1.6, Color.BLACK)
