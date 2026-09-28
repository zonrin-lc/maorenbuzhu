class_name DogController
extends Node2D

signal barked()
signal lure_started()
signal lure_ended()
signal arrived_at_target(target: Vector2)

@export var patrol_speed := 45.0
@export var lure_speed := 90.0
@export var lure_duration := 20.0

var home_position := Vector2.ZERO
var target_position := Vector2.ZERO
var state: StringName = &"IDLE"
var lure_timer := 0.0
var facing := Vector2.RIGHT
var _arrived_emitted := false
var sprite: Sprite2D
var anim_time := 0.0
var anim_driver: AnimationFeedbackDriver

func _ready() -> void:
    sprite = SpriteAnimator.attach_animal(self, load("res://assets/actors/dog/sprite_sheet.png"))
    anim_driver = AnimationFeedbackDriver.new()
    anim_driver.name = "AnimationFeedback"
    add_child(anim_driver)
    anim_driver.setup(sprite, &"animal")

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
    _arrived_emitted = false
    if anim_driver != null:
        anim_driver.play(AnimationFeedbackDriver.State.ACTION, 0.45)
    lure_started.emit()
    queue_redraw()

func bark() -> void:
    barked.emit()
    if anim_driver != null:
        anim_driver.play(AnimationFeedbackDriver.State.EMOTE, 0.35)
    queue_redraw()

func _process(delta: float) -> void:
    var moving := false
    match state:
        &"LURED":
            facing = (target_position - position).normalized()
            moving = true
            position = position.move_toward(target_position, lure_speed * delta)
            if not _arrived_emitted and position.distance_to(target_position) <= 2.0:
                _arrived_emitted = true
                arrived_at_target.emit(target_position)
            lure_timer -= delta
            if lure_timer <= 0.0:
                state = &"RETURN"
                target_position = home_position
                lure_ended.emit()
        &"RETURN":
            facing = (home_position - position).normalized()
            moving = true
            position = position.move_toward(home_position, patrol_speed * delta)
            if position.distance_to(home_position) < 2.0:
                state = &"IDLE"
    anim_time += delta
    if anim_driver != null:
        anim_driver.set_base_state(AnimationFeedbackDriver.State.MOVE if moving else AnimationFeedbackDriver.State.IDLE)
    SpriteAnimator.update_animal(sprite, facing, moving, anim_time)
    queue_redraw()

func _draw() -> void:
    draw_arc(Vector2.ZERO, 21.0, -PI * 0.7, -PI * 0.3, 12, Color("#fde68a") if state != &"LURED" else Color("#eab308"), 2.0)
