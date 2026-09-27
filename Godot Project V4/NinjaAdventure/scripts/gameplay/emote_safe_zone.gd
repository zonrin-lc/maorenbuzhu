class_name EmoteSafeZone
extends Node2D

@export var radius := 54.0

func _process(delta: float) -> void:
    queue_redraw()

func contains(point: Vector2) -> bool:
    return global_position.distance_to(point) <= radius

func _draw() -> void:
    var pulse := 0.08 + (sin(Time.get_ticks_msec() * 0.004) * 0.025 + 0.025)
    draw_circle(Vector2.ZERO, radius, Color(0.35, 0.85, 0.62, pulse))
    draw_arc(Vector2.ZERO, radius, 0.0, TAU, 36, Color(0.45, 0.95, 0.72, 0.55), 2.0)
    draw_arc(Vector2.ZERO, radius * 0.72, 0.0, TAU, 36, Color(0.45, 0.95, 0.72, 0.22), 1.0)
    var font := ThemeDB.fallback_font
    draw_string(font, Vector2(-42, -radius - 10), "卖萌安全位", HORIZONTAL_ALIGNMENT_CENTER, 84, 13, Color(0.82, 1.0, 0.88, 0.85))
