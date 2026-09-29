class_name LayoutDesign
extends Node2D

# 分区标签是世界空间中文绘制，走项目 CJK 字体。
const UI_FONT := preload("res://theme/ui_font.tres")

# Runtime whitebox-to-production guide layer based on the approved layout diagrams.
# It is intentionally subtle and sits behind gameplay actors and event feedback.

var level_id: StringName
var route_points: PackedVector2Array
var zones: Array = []

func setup(p_level_id: StringName, p_route_points: Array, p_zones: Array) -> void:
    level_id = p_level_id
    route_points = PackedVector2Array(p_route_points)
    zones = p_zones
    queue_redraw()

func _draw() -> void:
    # Designed to read as environment zoning rather than a debug grid.
    for zone in zones:
        var rect: Rect2 = zone[1]
        draw_rect(rect, Color(1, 1, 1, 0.025), true)
        draw_rect(rect, Color(1, 1, 1, 0.10), false, 1.0)
        var label := String(zone[0])
        draw_string(UI_FONT, rect.position + Vector2(8, 18), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 1, 1, 0.42))

    if route_points.size() >= 2:
        for i in range(route_points.size() - 1):
            draw_line(route_points[i], route_points[i + 1], Color(1, 1, 1, 0.10), 2.0, true)
        for i in route_points.size():
            var p := route_points[i]
            draw_circle(p, 5.0, Color(1, 1, 1, 0.10))

    # Chapter 2/3 route-reading emphasis: a faint corridor band.
    if route_points.size() >= 2:
        for i in range(route_points.size() - 1):
            _draw_corridor(route_points[i], route_points[i + 1], 44.0)

func _draw_corridor(a: Vector2, b: Vector2, width: float) -> void:
    var d := b - a
    if d.length() < 1.0:
        return
    var n := d.normalized().orthogonal() * width * 0.5
    var poly := PackedVector2Array([a + n, b + n, b - n, a - n])
    draw_colored_polygon(poly, Color(1, 1, 1, 0.018))
