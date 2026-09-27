class_name CatController
extends CharacterBody2D

signal action_started(action_id: StringName)
signal action_finished(action_id: StringName)
signal meow_triggered()
signal emote_triggered()

@export var speed := 90.0
@export var sprint_speed := 160.0
@export var stamina_max := 100.0
@export var sprint_cost := 25.0
@export var stamina_regen := 20.0
@export var emote_cooldown := 20.0

var stamina := stamina_max
var carry_item: StringName = &""
var action_id: StringName = &""
var action_remaining := 0.0
var meow_cooldown := 0.0
var facing := Vector2.RIGHT
var meow_was_down := false
var emote_was_down := false
var sprite: Sprite2D
var anim_time := 0.0

@export var skin := "cat_black"

func _ready() -> void:
    sprite = SpriteAnimator.attach_animal(self, load("res://assets/actors/%s/sprite_sheet.png" % skin))

func _physics_process(delta: float) -> void:
    var manager = get_parent()
    if manager != null and manager.get("reading_phase") == true:
        velocity = Vector2.ZERO
        return
    meow_cooldown = max(0.0, meow_cooldown - delta)
    if action_remaining > 0.0:
        action_remaining = max(0.0, action_remaining - delta)
        velocity = Vector2.ZERO
        if action_remaining == 0.0:
            var finished := action_id
            action_id = &""
            action_finished.emit(finished)
        queue_redraw()
        return

    var input_vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var sprinting := Input.is_action_pressed("sprint") and input_vec.length() > 0.0 and stamina > 0.0
    var move_speed := sprint_speed if sprinting else speed
    if sprinting:
        stamina = max(0.0, stamina - sprint_cost * delta)
    else:
        stamina = min(stamina_max, stamina + stamina_regen * delta)
    if input_vec.length() > 0.05:
        facing = input_vec.normalized()
    velocity = input_vec.normalized() * move_speed
    move_and_slide()
    var meow_down := Input.is_action_pressed("meow")
    if meow_down and not meow_was_down:
        meow_triggered.emit()
    meow_was_down = meow_down

    var emote_down := Input.is_action_pressed("emote")
    if emote_down and not emote_was_down and meow_cooldown <= 0.0:
        meow_cooldown = emote_cooldown
        emote_triggered.emit()
    emote_was_down = emote_down
    anim_time += delta
    SpriteAnimator.update_animal(sprite, facing, velocity.length() > 1.0, anim_time)
    queue_redraw()

func start_action(new_action: StringName, duration: float) -> bool:
    if action_remaining > 0.0:
        return false
    action_id = new_action
    action_remaining = duration
    action_started.emit(new_action)
    return true

func _draw() -> void:
    if action_remaining > 0.0:
        draw_arc(Vector2.ZERO, 24.0, -PI * 0.9, -PI * 0.1, 18, Color("#fbbf24"), 3.0)
