class_name SuspicionEye
extends Control

var suspicion: float = 0.0

func set_suspicion(value: float) -> void:
    suspicion = clampf(value, 0.0, 100.0)
    queue_redraw()

func _draw() -> void:
    var center := size * 0.5
    var radius := minf(size.x, size.y) * 0.38
    draw_circle(center, radius, Color(0.92, 0.90, 0.82, 1.0))
    var pupil_scale := lerpf(0.9, 0.28, suspicion / 100.0)
    draw_circle(center, radius * pupil_scale, Color(0.12, 0.10, 0.08, 1.0))
    if suspicion >= 50.0:
        draw_arc(center, radius * 1.15, 0.0, TAU, 48, Color(0.3, 0.3, 0.3, 0.65), 2.0)
    if suspicion >= 80.0:
        draw_circle(center, radius * 1.28, Color(0.8, 0.8, 0.8, 0.16), false, 3.0)
