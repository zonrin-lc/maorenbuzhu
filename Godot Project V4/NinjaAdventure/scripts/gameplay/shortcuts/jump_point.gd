class_name JumpPoint
extends Area2D

signal used

# 捷径提示是世界空间中文绘制，走项目 CJK 字体。
const UI_FONT := preload("res://theme/ui_font.tres")

@export var entry_point := Vector2.ZERO
@export var exit_point := Vector2.ZERO
@export var travel_time := 0.24
@export var label_text := "木箱捷径"

var _cat: CatController
var _busy := false
var _cooldown := 0.0
var _crate: Sprite2D

func setup(p_entry: Vector2, p_exit: Vector2) -> void:
    entry_point = p_entry
    exit_point = p_exit
    position = entry_point
    var shape := RectangleShape2D.new()
    shape.size = Vector2(52, 52)
    var cs := CollisionShape2D.new()
    cs.shape = shape
    add_child(cs)
    collision_layer = 0
    collision_mask = 1
    monitoring = true
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    var tex := load("res://assets/props/crate.png") as Texture2D
    if tex != null:
        _crate = Sprite2D.new()
        _crate.name = "ShortcutCrate"
        _crate.texture = tex
        var s := 44.0 / maxf(tex.get_width(), tex.get_height())
        _crate.scale = Vector2(s, s)
        add_child(_crate)
    queue_redraw()

func _process(delta: float) -> void:
    _cooldown = maxf(0.0, _cooldown - delta)
    if _cat == null or _busy or _cooldown > 0.0:
        return
    if Input.is_action_just_pressed("jump"):
        _activate(_cat)

func _on_body_entered(body: Node) -> void:
    if body is CatController:
        _cat = body
        queue_redraw()

func _on_body_exited(body: Node) -> void:
    if body == _cat and not _busy:
        _cat = null
        queue_redraw()

func _activate(cat: CatController) -> void:
    if _busy or _cooldown > 0.0 or cat == null:
        return
    _busy = true
    _cooldown = 0.8
    if not cat.start_action(&"JUMP", travel_time):
        _busy = false
        return
    var original_scale := cat.scale
    var tween := create_tween()
    tween.tween_property(cat, "global_position", exit_point, travel_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.parallel().tween_property(cat, "scale", original_scale * 1.12, travel_time * 0.35)
    tween.tween_property(cat, "scale", original_scale, travel_time * 0.65)
    tween.tween_callback(func():
        _busy = false
        _cat = null
        used.emit()
        queue_redraw()
    )

func _draw() -> void:
    draw_circle(Vector2.ZERO, 28.0, Color(0.86, 0.63, 0.18, 0.18))
    draw_arc(Vector2.ZERO, 28.0, 0.0, TAU, 28, Color(0.96, 0.77, 0.28, 0.65), 2.0)
    draw_arc(Vector2.ZERO, 20.0, PI, TAU, 20, Color(0.40, 0.76, 0.54, 0.45), 2.0)
    if _cat != null and not _busy:
        var font := UI_FONT
        draw_string(font, Vector2(-45, 45), label_text, HORIZONTAL_ALIGNMENT_CENTER, 90, 12, Color(0.96, 0.90, 0.70, 0.85))
