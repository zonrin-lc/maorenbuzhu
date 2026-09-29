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
var facing := Vector2.RIGHT
var sprite: Sprite2D
var anim_time := 0.0
var anim_driver: AnimationFeedbackDriver

func _ready() -> void:
    sprite = SpriteAnimator.attach_character(self, load("res://assets/actors/samurai_red/sprite_sheet.png"))
    anim_driver = AnimationFeedbackDriver.new()
    anim_driver.name = "AnimationFeedback"
    add_child(anim_driver)
    anim_driver.setup(sprite, &"character")

func setup(center: Vector2) -> void:
    position = center
    rest_position = center

func distract(source_position: Vector2) -> void:
    if not active:
        return
    active = false
    distract_timer = return_delay
    if anim_driver != null:
        anim_driver.play(AnimationFeedbackDriver.State.ACTION, 0.40)
    meow_position = source_position
    distracted.emit()
    queue_redraw()

# 玩法回归发现：事件结算脚本长期以 depart(pos, duration) 调用守卫，但此方法不存在
# （调用只会报错且守卫原地不动）。语义与 distract 一致：走向目标点，离场 duration 秒后返岗。
func depart(source_position: Vector2, duration: float = 6.0) -> void:
    var old_delay := return_delay
    return_delay = duration
    distract(source_position)
    return_delay = old_delay

func _process(delta: float) -> void:
    var moving := false
    if not active:
        if meow_position != Vector2.ZERO:
            facing = (meow_position - position).normalized()
            moving = true
            position = position.move_toward(meow_position, patrol_speed * 2.0 * delta)
        distract_timer -= delta
        if distract_timer <= 0.0:
            position = rest_position
            active = true
            meow_position = Vector2.ZERO
    else:
        var left := rest_position + patrol_left
        var right := rest_position + patrol_right
        position.x += direction * patrol_speed * delta
        facing = Vector2(direction, 0.0)
        moving = true
        if position.x >= right.x:
            direction = -1.0
        elif position.x <= left.x:
            direction = 1.0
    if anim_driver != null:
        anim_driver.set_base_modulate(Color.WHITE if active else Color(0.6, 0.6, 0.7))
        anim_driver.set_base_state(AnimationFeedbackDriver.State.MOVE if moving else AnimationFeedbackDriver.State.IDLE)
    anim_time += delta
    SpriteAnimator.update_character(sprite, facing, moving, anim_time)
    queue_redraw()

func _draw() -> void:
    pass
