class_name CatTunnel
extends Area2D

signal used

@export var entry_point := Vector2.ZERO
@export var exit_point := Vector2.ZERO
@export var travel_time := 0.35
@export var one_way := true

var _cat: CatController
var _busy := false
var _cooldown := 0.0
var _entry_shape: CollisionShape2D

func setup(p_entry: Vector2, p_exit: Vector2, p_size: Vector2 = Vector2(150, 34)) -> void:
    entry_point = p_entry
    exit_point = p_exit
    position = entry_point
    var shape := RectangleShape2D.new()
    shape.size = p_size
    _entry_shape = CollisionShape2D.new()
    _entry_shape.shape = shape
    add_child(_entry_shape)
    collision_layer = 0
    collision_mask = 1
    monitoring = true
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    queue_redraw()

func _process(delta: float) -> void:
    _cooldown = maxf(0.0, _cooldown - delta)
    if _cat == null or _busy or _cooldown > 0.0:
        return
    _activate(_cat)

func _on_body_entered(body: Node) -> void:
    if body is CatController:
        _cat = body
        _activate(body)

func _on_body_exited(body: Node) -> void:
    if body == _cat and not _busy:
        _cat = null

func _activate(cat: CatController) -> void:
    if _busy or _cooldown > 0.0 or cat == null:
        return
    if cat.global_position.distance_to(entry_point) > 90.0:
        return
    _busy = true
    _cooldown = 0.8
    _cat = cat
    if not cat.start_action(&"CAT_TUNNEL", travel_time):
        _busy = false
        return
    var target := exit_point
    var tween := create_tween()
    tween.tween_property(cat, "global_position", target, travel_time).set_trans(Tween.TRANS_SINE)
    tween.parallel().tween_property(cat, "scale", Vector2(0.82, 0.82), travel_time * 0.5)
    tween.tween_property(cat, "scale", Vector2.ONE, travel_time * 0.5)
    tween.tween_callback(func():
        _busy = false
        _cat = null
        used.emit()
        queue_redraw()
    )
    queue_redraw()

func _draw() -> void:
    var dir := (exit_point - entry_point).normalized()
    var n := dir.orthogonal()
    draw_rect(Rect2(-42, -14, 84, 28), Color(0.10, 0.34, 0.28, 0.55), true)
    draw_rect(Rect2(-42, -14, 84, 28), Color(0.50, 0.90, 0.72, 0.40), false, 2.0)
    var c := Vector2.ZERO
    var d := dir * 16.0
    var side := n * 7.0
    draw_line(c - d, c + d, Color(0.95, 0.77, 0.25, 0.65), 2.0, true)
    draw_line(c + d, c + d - side - dir * 7.0, Color(0.95, 0.77, 0.25, 0.65), 2.0, true)
    draw_line(c + d, c + d + side - dir * 7.0, Color(0.95, 0.77, 0.25, 0.65), 2.0, true)
