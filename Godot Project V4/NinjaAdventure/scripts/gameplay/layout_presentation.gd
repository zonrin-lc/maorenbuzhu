class_name LayoutPresentation
extends Node2D

# v1.5.7：把白盒布局层变成“读图演出层”。
# 开局读图时清晰显示分区与路线；读图结束后淡到极低存在感，避免像开发调试网格。

var level_id: StringName = &""
var route_points := PackedVector2Array()
var zones: Array = []
var reading := true
var presentation_alpha := 1.0
var target_alpha := 1.0
var focus_position := Vector2(-9999, -9999)
var focus_radius := 34.0

func setup(p_level_id: StringName, p_route_points: Array, p_zones: Array) -> void:
    level_id = p_level_id
    route_points = PackedVector2Array(p_route_points)
    zones = p_zones
    reading = true
    presentation_alpha = 1.0
    target_alpha = 1.0
    queue_redraw()

func set_reading_mode(active: bool, focus: Vector2 = Vector2(-9999, -9999)) -> void:
    reading = active
    target_alpha = 1.0 if active else 0.10
    focus_position = focus
    queue_redraw()

func set_focus(focus: Vector2) -> void:
    focus_position = focus
    queue_redraw()

func _process(delta: float) -> void:
    presentation_alpha = move_toward(presentation_alpha, target_alpha, delta * 2.4)
    queue_redraw()

func _draw() -> void:
    if presentation_alpha <= 0.01:
        return

    # 分区：读图清晰，实际游戏只留下很轻的材质感。
    for zone in zones:
        var rect: Rect2 = zone[1]
        draw_rect(rect, Color(1, 1, 1, 0.025 * presentation_alpha), true)
        draw_rect(rect, Color(1, 1, 1, 0.10 * presentation_alpha), false, 1.0)
        var label := String(zone[0])
        draw_string(ThemeDB.fallback_font, rect.position + Vector2(8, 18), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 1, 1, 0.42 * presentation_alpha))

    if route_points.size() >= 2:
        for i in range(route_points.size() - 1):
            draw_line(route_points[i], route_points[i + 1], Color(1, 1, 1, 0.10 * presentation_alpha), 2.0, true)
        for i in route_points.size():
            var p := route_points[i]
            draw_circle(p, 5.0, Color(1, 1, 1, 0.10 * presentation_alpha))

    if route_points.size() >= 2:
        for i in range(route_points.size() - 1):
            _draw_corridor(route_points[i], route_points[i + 1], 44.0)

    if reading and focus_position.x > -1000:
        var pulse := 1.0 + sin(Time.get_ticks_msec() / 180.0) * 0.10
        draw_circle(focus_position, focus_radius * pulse, Color(0.98, 0.72, 0.28, 0.08 * presentation_alpha), false, 3.0)
        draw_arc(focus_position, focus_radius * 1.18 * pulse, -PI * 0.8, PI * 0.25, 30, Color(0.98, 0.72, 0.28, 0.48 * presentation_alpha), 3.0)
        draw_line(focus_position + Vector2(-10, -10), focus_position + Vector2(10, 10), Color(0.98, 0.88, 0.55, 0.25 * presentation_alpha), 2.0)
        draw_line(focus_position + Vector2(-10, 10), focus_position + Vector2(10, -10), Color(0.98, 0.88, 0.55, 0.25 * presentation_alpha), 2.0)

func _draw_corridor(a: Vector2, b: Vector2, width: float) -> void:
    var d := b - a
    if d.length() < 1.0:
        return
    var n := d.normalized().orthogonal() * width * 0.5
    var poly := PackedVector2Array([a + n, b + n, b - n, a - n])
    draw_colored_polygon(poly, Color(1, 1, 1, 0.018 * presentation_alpha))
