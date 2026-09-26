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
var facing := Vector2.RIGHT
var sprite: Sprite2D
var anim_time := 0.0

func _ready() -> void:
    sprite = SpriteAnimator.attach_character(self, load("res://assets/actors/samurai_blue/sprite_sheet.png"))

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
    var moving := false
    match state:
        &"ACTIVE":
            position.x += direction * patrol_speed * delta
            facing = Vector2(direction, 0.0)
            moving = true
            var left := rest_position + patrol_left
            var right := rest_position + patrol_right
            if position.x >= right.x:
                direction = -1.0
            elif position.x <= left.x:
                direction = 1.0
        &"DISTRACTED":
            facing = (lure_position - position).normalized()
            moving = true
            position = position.move_toward(lure_position, patrol_speed * 2.0 * delta)
            timer -= delta
            if timer <= 0.0:
                position = rest_position
                state = &"ACTIVE"
                state_changed.emit(state)
    sprite.modulate = Color.WHITE if state == &"ACTIVE" else Color(0.6, 0.6, 0.7)
    anim_time += delta
    SpriteAnimator.update_character(sprite, facing, moving, anim_time)
    queue_redraw()

func _draw() -> void:
    pass
