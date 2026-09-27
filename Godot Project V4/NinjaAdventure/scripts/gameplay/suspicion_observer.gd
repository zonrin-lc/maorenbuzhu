class_name SuspicionObserver
extends Node2D

@export var observer_path: NodePath = NodePath("../Ninja")
@export var subject_path: NodePath = NodePath("../Cat")
@export var vision_radius := 100.0
@export var fov_degrees := 90.0
@export var close_radius := 24.0

var observer: Node2D
var subject: Node2D

func _ready() -> void:
    observer = get_node_or_null(observer_path) as Node2D
    subject = get_node_or_null(subject_path) as Node2D
    queue_redraw()

func _process(_delta: float) -> void:
    if observer == null:
        observer = get_node_or_null(observer_path) as Node2D
    if subject == null:
        subject = get_node_or_null(subject_path) as Node2D
    if observer != null:
        global_position = observer.global_position
        rotation = observer.get("facing").angle() if observer.get("facing") is Vector2 else 0.0
    queue_redraw()

func sees_subject() -> bool:
    return vision_band() != &"NONE"

func vision_band() -> StringName:
    if observer == null or subject == null:
        return &"NONE"
    var offset := subject.global_position - observer.global_position
    var dist := offset.length()
    if dist <= close_radius:
        return &"CLOSE"
    if dist > vision_radius:
        return &"NONE"
    var facing_variant = observer.get("facing")
    var facing_vec: Vector2 = facing_variant if facing_variant is Vector2 else Vector2.RIGHT
    if facing_vec.length_squared() <= 0.001:
        facing_vec = Vector2.RIGHT
    var dot := facing_vec.normalized().dot(offset.normalized())
    if dot < cos(deg_to_rad(fov_degrees * 0.5)):
        return &"NONE"
    if dot >= cos(deg_to_rad(22.5)):
        return &"CENTER"
    return &"EDGE"

func suspicion_for_action(action_duration: float) -> float:
    match vision_band():
        &"CLOSE":
            return clampf(action_duration * 60.0, 30.0, 60.0)
        &"CENTER":
            return clampf(action_duration * 60.0, 30.0, 60.0)
        &"EDGE":
            return 30.0
        _:
            return 0.0

func _draw() -> void:
    if observer == null or subject == null:
        return
    var band := vision_band()
    var alpha := 0.08 if band == &"NONE" else 0.15
    var half := deg_to_rad(fov_degrees * 0.5)
    draw_colored_polygon(PackedVector2Array([
        Vector2.ZERO,
        Vector2(cos(-half), sin(-half)) * vision_radius,
        Vector2(cos(half), sin(half)) * vision_radius
    ]), Color(1.0, 0.78, 0.28, alpha))
    draw_arc(Vector2.ZERO, vision_radius, -half, half, 24, Color(1.0, 0.78, 0.28, 0.35), 1.5)
    draw_line(Vector2.ZERO, Vector2(cos(-half), sin(-half)) * vision_radius, Color(1.0, 0.78, 0.28, 0.30), 1.0)
    draw_line(Vector2.ZERO, Vector2(cos(half), sin(half)) * vision_radius, Color(1.0, 0.78, 0.28, 0.30), 1.0)
    draw_circle(Vector2.ZERO, close_radius, Color(1.0, 0.55, 0.25, 0.10), false, 1.0)
