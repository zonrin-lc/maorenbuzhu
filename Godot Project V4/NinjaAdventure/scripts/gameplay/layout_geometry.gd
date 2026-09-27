class_name LayoutGeometry
extends Node2D

# Production whitebox geometry derived from the Chapter 01/02/03 layout blueprints.
# This layer is intentionally deterministic: no random map generation is used.
# Walls are real StaticBody2D collisions; water/bridge/tunnel regions are visual spatial guides.

const MAP_RECT := Rect2(40, 140, 1020, 460)
const WALL_COLOR := Color(0.08, 0.09, 0.12, 0.72)
const WALL_EDGE := Color(0.65, 0.68, 0.76, 0.38)
const WATER_COLOR := Color(0.08, 0.28, 0.42, 0.62)
const BRIDGE_COLOR := Color(0.48, 0.32, 0.18, 0.88)
const TUNNEL_COLOR := Color(0.18, 0.52, 0.40, 0.42)
const SHORTCUT_COLOR := Color(0.90, 0.68, 0.22, 0.40)

var level_id: StringName = &""
var layout: Dictionary = {}
var route_points := PackedVector2Array()
var collision_root: StaticBody2D
var start_point := Vector2.ZERO
var goal_point := Vector2.ZERO

# Each level stays inside the current 1100x680 gameplay canvas while preserving
# the topology in the approved whitebox diagrams.
const LEVEL_LAYOUTS := {
    &"L01": {
        "walls": [
            Rect2(215, 205, 24, 95), Rect2(215, 380, 24, 100),
            Rect2(215, 205, 190, 24), Rect2(215, 456, 190, 24),
            Rect2(430, 178, 300, 24), Rect2(430, 454, 300, 24),
            Rect2(735, 178, 24, 100), Rect2(735, 430, 24, 48),
            Rect2(980, 250, 24, 110), Rect2(980, 420, 24, 55)
        ],
        "water": [Rect2(760, 280, 210, 200)],
        "bridges": [Rect2(820, 365, 120, 42)],
        "tunnels": [Rect2(330, 480, 150, 34)],
        "shortcuts": [Rect2(820, 365, 120, 42)],
        "start": Vector2(140, 390), "goal": Vector2(980, 390)
    },
    &"L02": {
        "walls": [
            Rect2(255, 205, 24, 95), Rect2(255, 355, 24, 80),
            Rect2(255, 205, 185, 24), Rect2(255, 420, 185, 24),
            Rect2(416, 205, 24, 95), Rect2(416, 355, 24, 85),
            Rect2(470, 178, 240, 24), Rect2(470, 455, 240, 24),
            Rect2(710, 178, 24, 92), Rect2(710, 415, 24, 64),
            Rect2(905, 325, 24, 170), Rect2(1010, 325, 24, 170)
        ],
        "water": [Rect2(735, 300, 160, 195)],
        "bridges": [Rect2(820, 385, 82, 42)],
        "tunnels": [Rect2(440, 470, 170, 34)],
        "shortcuts": [Rect2(440, 470, 170, 34)],
        "start": Vector2(140, 340), "goal": Vector2(990, 420)
    },
    &"L03": {
        "walls": [
            Rect2(300, 175, 260, 24), Rect2(300, 410, 150, 24),
            Rect2(300, 175, 24, 85), Rect2(300, 325, 24, 109),
            Rect2(445, 325, 205, 24), Rect2(626, 325, 24, 95),
            Rect2(626, 470, 24, 44), Rect2(445, 490, 150, 24),
            Rect2(640, 330, 180, 24), Rect2(640, 500, 180, 24),
            Rect2(805, 330, 24, 100), Rect2(805, 470, 24, 54),
            Rect2(820, 330, 150, 24), Rect2(820, 500, 150, 24)
        ],
        "water": [Rect2(820, 355, 150, 145)],
        "bridges": [Rect2(850, 402, 95, 40)],
        "tunnels": [Rect2(585, 350, 48, 155)],
        "shortcuts": [Rect2(585, 350, 48, 155)],
        "start": Vector2(140, 300), "goal": Vector2(990, 420)
    },
    &"L04": {
        "walls": [
            Rect2(215, 205, 24, 85), Rect2(215, 360, 24, 105),
            Rect2(215, 205, 220, 24), Rect2(215, 465, 220, 24),
            Rect2(435, 205, 24, 85), Rect2(435, 370, 24, 95),
            Rect2(380, 205, 24, 90), Rect2(380, 355, 24, 40),
            Rect2(500, 382, 220, 24), Rect2(500, 540, 220, 24),
            Rect2(500, 382, 24, 50), Rect2(500, 480, 24, 84),
            Rect2(700, 382, 24, 54), Rect2(700, 500, 24, 64),
            Rect2(750, 355, 24, 70), Rect2(750, 500, 24, 55),
            Rect2(965, 360, 24, 70), Rect2(965, 490, 24, 65)
        ],
        "water": [Rect2(775, 370, 180, 185)],
        "bridges": [Rect2(800, 435, 120, 45)],
        "tunnels": [Rect2(430, 485, 215, 34)],
        "shortcuts": [Rect2(430, 485, 215, 34)],
        "start": Vector2(140, 340), "goal": Vector2(980, 460)
    },
    &"L05": {
        "walls": [
            Rect2(190, 205, 235, 24), Rect2(190, 390, 235, 24),
            Rect2(190, 205, 24, 88), Rect2(190, 330, 24, 84),
            Rect2(365, 190, 24, 110), Rect2(365, 335, 24, 79),
            Rect2(610, 355, 24, 90), Rect2(610, 485, 24, 45),
            Rect2(625, 355, 175, 24), Rect2(625, 510, 175, 24),
            Rect2(815, 200, 24, 120), Rect2(815, 370, 24, 160),
            Rect2(950, 350, 24, 180)
        ],
        "water": [Rect2(625, 385, 175, 125), Rect2(735, 210, 140, 145)],
        "bridges": [Rect2(650, 440, 135, 42)],
        "tunnels": [Rect2(425, 515, 150, 36)],
        "shortcuts": [Rect2(425, 515, 150, 36)],
        "start": Vector2(110, 500), "goal": Vector2(1010, 320)
    },
    &"L06": {
        "walls": [
            Rect2(190, 205, 230, 24), Rect2(190, 390, 230, 24),
            Rect2(190, 205, 24, 88), Rect2(190, 330, 24, 84),
            Rect2(440, 190, 260, 24), Rect2(440, 390, 260, 24),
            Rect2(440, 190, 24, 95), Rect2(440, 340, 24, 74),
            Rect2(700, 355, 24, 175), Rect2(700, 355, 220, 24),
            Rect2(700, 506, 220, 24), Rect2(920, 355, 24, 175),
            Rect2(950, 210, 24, 100), Rect2(950, 390, 24, 140)
        ],
        "water": [Rect2(720, 380, 185, 115)],
        "bridges": [Rect2(760, 420, 125, 44)],
        "tunnels": [Rect2(420, 420, 115, 34)],
        "shortcuts": [Rect2(420, 420, 115, 34)],
        "start": Vector2(110, 500), "goal": Vector2(990, 320)
    },
    &"L07": {
        "walls": [
            Rect2(185, 255, 220, 24), Rect2(185, 440, 220, 24),
            Rect2(185, 255, 24, 90), Rect2(185, 385, 24, 79),
            Rect2(390, 130, 24, 85), Rect2(390, 285, 24, 179),
            Rect2(550, 130, 24, 85), Rect2(550, 285, 24, 179),
            Rect2(700, 245, 190, 24), Rect2(700, 430, 190, 24),
            Rect2(880, 245, 24, 90), Rect2(880, 385, 24, 69),
            Rect2(790, 165, 24, 80), Rect2(790, 330, 24, 124)
        ],
        "water": [Rect2(715, 270, 160, 150)],
        "bridges": [Rect2(745, 325, 110, 40)],
        "tunnels": [Rect2(405, 470, 185, 34)],
        "shortcuts": [Rect2(405, 470, 185, 34)],
        "start": Vector2(110, 480), "goal": Vector2(1000, 350)
    },
    &"L08": {
        "walls": [
            Rect2(175, 275, 235, 24), Rect2(175, 455, 235, 24),
            Rect2(175, 275, 24, 85), Rect2(175, 405, 24, 74),
            Rect2(350, 175, 24, 95), Rect2(350, 340, 24, 139),
            Rect2(550, 175, 24, 85), Rect2(550, 325, 24, 154),
            Rect2(570, 360, 175, 24), Rect2(570, 520, 175, 24),
            Rect2(745, 350, 24, 55), Rect2(745, 475, 24, 69),
            Rect2(750, 180, 24, 145), Rect2(750, 325, 180, 24),
            Rect2(905, 225, 24, 105), Rect2(905, 430, 24, 95)
        ],
        "water": [Rect2(595, 185, 140, 155), Rect2(760, 370, 145, 150)],
        "bridges": [Rect2(600, 400, 130, 42)],
        "tunnels": [Rect2(410, 490, 155, 34)],
        "shortcuts": [Rect2(410, 490, 155, 34)],
        "start": Vector2(100, 500), "goal": Vector2(960, 320)
    },
    &"L09": {
        "walls": [
            Rect2(180, 295, 360, 24), Rect2(180, 500, 360, 24),
            Rect2(180, 295, 24, 75), Rect2(180, 425, 24, 99),
            Rect2(370, 215, 24, 80), Rect2(370, 360, 24, 164),
            Rect2(535, 175, 24, 90), Rect2(535, 365, 24, 160),
            Rect2(700, 215, 24, 130), Rect2(700, 410, 24, 115),
            Rect2(930, 245, 24, 55), Rect2(930, 345, 24, 135)
        ],
        "water": [Rect2(555, 260, 130, 120)],
        "bridges": [Rect2(565, 335, 115, 40)],
        "tunnels": [Rect2(430, 525, 180, 34)],
        "shortcuts": [Rect2(430, 525, 180, 34)],
        "start": Vector2(110, 540), "goal": Vector2(940, 300)
    },
    &"L10": {
        "walls": [
            Rect2(195, 285, 250, 24), Rect2(195, 510, 250, 24),
            Rect2(195, 285, 24, 90), Rect2(195, 430, 24, 104),
            Rect2(390, 355, 250, 24), Rect2(390, 535, 250, 24),
            Rect2(390, 355, 24, 70), Rect2(390, 465, 24, 70),
            Rect2(525, 205, 24, 150), Rect2(525, 375, 24, 160),
            Rect2(760, 195, 24, 80), Rect2(760, 350, 24, 185),
            Rect2(875, 195, 24, 80), Rect2(875, 350, 24, 185),
            Rect2(895, 165, 135, 24), Rect2(895, 355, 135, 24)
        ],
        "water": [Rect2(655, 380, 105, 150)],
        "bridges": [Rect2(665, 425, 90, 40)],
        "tunnels": [Rect2(445, 540, 160, 34)],
        "shortcuts": [Rect2(445, 540, 160, 34)],
        "start": Vector2(110, 540), "goal": Vector2(980, 260)
    },
    &"L11": {
        "walls": [
            Rect2(255, 165, 230, 24), Rect2(255, 320, 230, 24),
            Rect2(255, 165, 24, 70), Rect2(255, 275, 24, 69),
            Rect2(650, 115, 220, 24), Rect2(650, 275, 220, 24),
            Rect2(650, 115, 24, 80), Rect2(650, 235, 24, 40),
            Rect2(420, 275, 250, 24), Rect2(420, 455, 250, 24),
            Rect2(420, 275, 24, 90), Rect2(420, 415, 24, 64),
            Rect2(760, 250, 205, 24), Rect2(760, 420, 205, 24),
            Rect2(760, 250, 24, 70), Rect2(760, 370, 24, 74),
            Rect2(265, 430, 220, 24), Rect2(265, 565, 220, 24),
            Rect2(500, 440, 24, 60), Rect2(500, 545, 24, 39),
            Rect2(930, 115, 24, 165)
        ],
        "water": [Rect2(520, 325, 120, 115), Rect2(775, 285, 160, 120)],
        "bridges": [Rect2(800, 330, 125, 42)],
        "tunnels": [Rect2(490, 585, 190, 34)],
        "shortcuts": [Rect2(490, 585, 190, 34)],
        "start": Vector2(100, 540), "goal": Vector2(1000, 250)
    },
    &"L12": {
        "walls": [
            Rect2(175, 255, 220, 24), Rect2(175, 420, 220, 24),
            Rect2(175, 255, 24, 75), Rect2(175, 365, 24, 79),
            Rect2(390, 195, 210, 24), Rect2(390, 360, 210, 24),
            Rect2(390, 195, 24, 65), Rect2(390, 310, 24, 74),
            Rect2(565, 240, 24, 65), Rect2(565, 375, 24, 44),
            Rect2(625, 390, 275, 24), Rect2(625, 545, 275, 24),
            Rect2(625, 390, 24, 80), Rect2(625, 505, 24, 64),
            Rect2(890, 390, 24, 180), Rect2(760, 220, 24, 70),
            Rect2(1030, 120, 20, 155), Rect2(900, 120, 94, 24),
            Rect2(760, 200, 210, 24)
        ],
        "water": [Rect2(630, 425, 245, 105)],
        "bridges": [Rect2(690, 455, 170, 42)],
        "tunnels": [Rect2(390, 445, 185, 34)],
        "shortcuts": [Rect2(390, 445, 185, 34)],
        "start": Vector2(110, 540), "goal": Vector2(990, 250)
    }
}

func setup(p_level_id: StringName, p_route_points: Array = []) -> void:
    level_id = p_level_id
    route_points = PackedVector2Array(p_route_points)
    layout = LEVEL_LAYOUTS.get(level_id, {})
    start_point = layout.get("start", Vector2(100, 500))
    goal_point = layout.get("goal", Vector2(1000, 300))
    _build_collision()
    queue_redraw()

func _build_collision() -> void:
    collision_root = StaticBody2D.new()
    collision_root.name = "LayoutCollision"
    collision_root.collision_layer = 1
    collision_root.collision_mask = 1
    add_child(collision_root)
    for i in range(layout.get("walls", []).size()):
        var rect: Rect2 = layout["walls"][i]
        if _wall_opens_route(rect):
            continue
        var shape := RectangleShape2D.new()
        shape.size = rect.size
        var cs := CollisionShape2D.new()
        cs.name = "Wall_%02d" % i
        cs.position = rect.position + rect.size * 0.5
        cs.shape = shape
        collision_root.add_child(cs)

func _draw() -> void:
    if layout.is_empty():
        return
    for rect in layout.get("water", []):
        draw_rect(rect, WATER_COLOR, true)
        draw_line(rect.position + Vector2(10, 10), rect.position + Vector2(rect.size.x - 10, 10), Color(0.42, 0.72, 0.84, 0.25), 2.0)
        draw_line(rect.position + Vector2(8, rect.size.y - 12), rect.position + Vector2(rect.size.x - 8, rect.size.y - 12), Color(0.42, 0.72, 0.84, 0.18), 2.0)
    for rect in layout.get("bridges", []):
        draw_rect(rect, BRIDGE_COLOR, true)
        var x: float = rect.position.x + 8.0
        while x < rect.end.x - 4.0:
            draw_line(Vector2(x, rect.position.y + 5), Vector2(x, rect.end.y - 5), Color(0.20, 0.12, 0.06, 0.55), 2.0)
            x += 16.0
    for rect in layout.get("tunnels", []):
        draw_rect(rect, TUNNEL_COLOR, true)
        draw_line(rect.position + Vector2(4, rect.size.y * 0.5), Vector2(rect.end.x - 4, rect.position.y + rect.size.y * 0.5), SHORTCUT_COLOR, 2.0, true)
        _draw_arrow(Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y + rect.size.y * 0.5), Vector2.RIGHT)
    for rect in layout.get("walls", []):
        if _wall_opens_route(rect):
            continue
        draw_rect(rect, WALL_COLOR, true)
        draw_rect(rect, WALL_EDGE, false, 1.0)
    draw_circle(start_point, 11.0, Color(0.35, 0.95, 0.70, 0.28))
    draw_arc(start_point, 16.0, 0, TAU, 24, Color(0.35, 0.95, 0.70, 0.36), 2.0)
    draw_circle(goal_point, 12.0, Color(0.98, 0.72, 0.28, 0.26))
    draw_arc(goal_point, 18.0, 0, TAU, 24, Color(0.98, 0.72, 0.28, 0.36), 2.0)
    for rect in layout.get("shortcuts", []):
        draw_arc(rect.get_center(), min(rect.size.x, rect.size.y) * 0.38, -PI * 0.75, PI * 0.15, 18, Color(0.98, 0.72, 0.28, 0.18), 2.0)


func _wall_opens_route(rect: Rect2) -> bool:
    if route_points.size() == 0:
        return false
    var corridor := rect.grow(34.0)
    for point in route_points:
        if corridor.has_point(point):
            return true
    # Also carve the narrowest part of the wall along each route segment.
    # Sampling keeps this Godot-4-only script simple and deterministic.
    for i in range(route_points.size() - 1):
        var a := route_points[i]
        var b := route_points[i + 1]
        for sample in range(1, 9):
            var p := a.lerp(b, float(sample) / 9.0)
            if corridor.has_point(p):
                return true
    return false

func _draw_arrow(center: Vector2, direction: Vector2) -> void:
    var d := direction.normalized() * 10.0
    var n := d.orthogonal() * 0.55
    draw_line(center - d, center + d, SHORTCUT_COLOR, 2.0, true)
    draw_line(center + d, center + d - n - d * 0.35, SHORTCUT_COLOR, 2.0, true)
    draw_line(center + d, center + d + n - d * 0.35, SHORTCUT_COLOR, 2.0, true)
