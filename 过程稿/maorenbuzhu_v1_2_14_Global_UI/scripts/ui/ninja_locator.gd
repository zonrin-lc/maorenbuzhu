class_name NinjaLocator
extends Control

var ninja: Node2D
@export var edge_padding: float = 28.0

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
