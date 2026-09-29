class_name NinjaController
extends CharacterBody2D

signal route_changed(route_index: int)
signal damaged(hp: int)
signal reached_goal()

var route: RouteData
var waypoint_index := 0
var level_manager: Node
var hp := 3
var waiting_for_event := false
var facing := Vector2.RIGHT
var sprite: Sprite2D
var anim_time := 0.0
var anim_driver: AnimationFeedbackDriver

func _ready() -> void:
    sprite = SpriteAnimator.attach_character(self, load("res://assets/actors/ninja_blue/sprite_sheet.png"))
    anim_driver = AnimationFeedbackDriver.new()
    anim_driver.name = "AnimationFeedback"
    add_child(anim_driver)
    anim_driver.setup(sprite, &"character")

func setup(route_data: RouteData, manager: Node) -> void:
    route = route_data
    level_manager = manager
    waypoint_index = 0
    position = route.waypoints[0] if route.waypoints.size() > 0 else Vector2.ZERO

func _physics_process(_delta: float) -> void:
    if route == null or route.waypoints.size() < 2 or waiting_for_event or level_manager.level_finished or level_manager.level_failed or level_manager.reading_phase:
        velocity = Vector2.ZERO
        if anim_driver != null:
            anim_driver.set_base_state(AnimationFeedbackDriver.State.ALERT if waiting_for_event else AnimationFeedbackDriver.State.IDLE)
        queue_redraw()
        return
    # 玩法回归发现：已到终点后不再取下一个路点（此前每帧越界访问 waypoints[size]，
    # L12 Boss 战期间关卡未结束会持续报错）。
    if waypoint_index >= route.waypoints.size() - 1:
        velocity = Vector2.ZERO
        queue_redraw()
        return
    if level_manager.is_ninja_at_blocking_event(waypoint_index):
        waiting_for_event = true
        velocity = Vector2.ZERO
        queue_redraw()
        return
    var target: Vector2 = route.waypoints[waypoint_index + 1]
    var delta_pos := target - position
    if delta_pos.length() < 5.0:
        waypoint_index += 1
        route_changed.emit(waypoint_index)
        if waypoint_index >= route.waypoints.size() - 1:
            reached_goal.emit()
            if anim_driver != null:
                anim_driver.play(AnimationFeedbackDriver.State.VICTORY, 0.90)
            level_manager.ninja_reached_goal()
            velocity = Vector2.ZERO
        return
    facing = delta_pos.normalized()
    velocity = facing * route.move_speed
    if anim_driver != null:
        anim_driver.set_base_state(AnimationFeedbackDriver.State.MOVE)
    move_and_slide()
    queue_redraw()

func _process(delta: float) -> void:
    anim_time += delta
    SpriteAnimator.update_character(sprite, facing, velocity.length() > 1.0, anim_time)

func release_event() -> void:
    waiting_for_event = false

func replace_scripted_route(points: Array, next_route_index: int = -1) -> void:
    if route == null or points.is_empty():
        return
    # 玩法回归发现两处问题：直接给共享 .tres 的 typed Array[Vector2] 赋未类型化 Array 会报错
    # 且污染资源缓存（重开关卡后 validator 会拿到改过的数据）。先复制再赋值。
    route = route.duplicate()
    var typed_points: Array[Vector2] = []
    typed_points.assign(points)
    route.waypoints = typed_points
    if next_route_index >= 0:
        waypoint_index = clampi(next_route_index, 0, max(0, route.waypoints.size() - 2))
    else:
        var closest_index := 0
        var closest_distance := INF
        for i in range(route.waypoints.size()):
            var d := global_position.distance_squared_to(route.waypoints[i])
            if d < closest_distance:
                closest_distance = d
                closest_index = i
        waypoint_index = clampi(closest_index, 0, max(0, route.waypoints.size() - 2))
    waiting_for_event = false
    route_changed.emit(waypoint_index)
    queue_redraw()

func take_damage(amount: int = 1) -> void:
    hp = max(0, hp - amount)
    if anim_driver != null:
        anim_driver.play(AnimationFeedbackDriver.State.DEATH if hp <= 0 else AnimationFeedbackDriver.State.HIT, 1.0 if hp <= 0 else 0.38)
    damaged.emit(hp)
    if hp <= 0:
        level_manager.on_ninja_dead()

func is_facing_point(point: Vector2) -> bool:
    var to_point := (point - global_position).normalized()
    return facing.dot(to_point) >= 0.0

func _draw() -> void:
    pass
