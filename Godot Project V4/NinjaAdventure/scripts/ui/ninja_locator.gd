class_name NinjaLocator
extends Control

var ninja: Node2D
@export var edge_padding: float = 28.0

func _ready() -> void:
    var arrow := TextureRect.new()
    arrow.texture = load("res://assets/ui/arrow.png")
    arrow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    arrow.set_anchors_preset(Control.PRESET_FULL_RECT)
    arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(arrow)

func bind_ninja(target: Node2D) -> void:
    ninja = target

func _process(_delta: float) -> void:
    if ninja == null:
        return
    var viewport_size := get_viewport_rect().size
    var local_target := get_viewport().get_canvas_transform() * ninja.global_position
    if local_target.x >= 0.0 and local_target.x <= viewport_size.x and local_target.y >= 0.0 and local_target.y <= viewport_size.y:
        visible = false
        return
    visible = true
    var center := viewport_size * 0.5
    var direction := local_target - center
    if direction.length() < 0.001:
        return
    direction = direction.normalized()
    global_position = center + direction * minf((viewport_size.x - edge_padding) * 0.5, (viewport_size.y - edge_padding) * 0.5)
    rotation = direction.angle() + PI * 0.5
