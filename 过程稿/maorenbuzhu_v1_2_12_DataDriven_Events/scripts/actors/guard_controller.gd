class_name GuardController
extends Node2D

signal distracted()

@export var patrol_left := Vector2(-100, 0)
@export var patrol_right := Vector2(100, 0)
@export var patrol_speed := 35.0
@export var return_delay := 6.0

var active := true
var direction := 1.0
var distract_timer := 0.0
var rest_position := Vector2.ZERO
var meow_position := Vector2.ZERO

func setup(center: Vector2) -> void:
    position = center
    rest_position = center

func distract(source_position: Vector2) -> void:
    if not active:
        return
    active = false
    distract_timer = return_delay
    meow_position = source_position
    distracted.emit()
    queue_redraw()

func _process(delta: float) -> void:
    if not active:
        if meow_position != Vector2.ZERO:
            position = position.move_toward(meow_position, patrol_speed * 2.0 * delta)
        distract_timer -= delta
        if distract_timer <= 0.0:
            position = rest_position
            active = true
            meow_position = Vector2.ZERO
        queue_redraw()
        return
    var left := rest_position + patrol_left
    var right := rest_position + patrol_right
    position.x += direction * patrol_speed * delta
    if position.x >= right.x:
        direction = -1.0
    elif position.x <= left.x:
        direction = 1.0
    queue_redraw()

func _draw() -> void:
    var c := Color("#b91c1c") if active else Color("#64748b")
    draw_circle(Vector2.ZERO, 17.0, c)
    draw_rect(Rect2(-8, -4, 16, 8), Color("#fca5a5") if active else Color("#cbd5e1"))
    draw_circle(Vector2(-5, -5), 1.6, Color.BLACK)
    draw_circle(Vector2(5, -5), 1.6, Color.BLACK)
