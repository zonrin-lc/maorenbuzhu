extends Node2D
class_name LayoutBookRenderer

# Editor/headless tool for producing the scene-layout reference pages.
# It loads the actual level scene, hides gameplay UI, adds a visual-only route
# overlay and a page frame. It never mutates LevelData/RouteData/EventData.
#
# Headless:
# godot --path . --headless --script tools/layout_book_renderer.gd -- L05
# The script writes res://art/layout_book/rendered/L05_scene.png.
#
# The same renderer can be used in the editor by instantiating this node.

const Manifest = preload("res://tools/layout_book_manifest.gd")

const OUT_DIR := "res://art/layout_book/rendered"
const W := 1600
const H := 1000
const MAP_RECT := Rect2(286, 150, 990, 612)
const BG := Color("#081a2a")
const PANEL := Color("#f6f5ee")
const NAVY := Color("#071a31")
const ORANGE := Color("#f3ad21")
const BLUE := Color("#22a8e8")
const GREEN := Color("#5ed04f")
const RED := Color("#e94b4b")
const DARK := Color("#17212d")
const LIGHT := Color("#e8edf2")

var level_id := "L05"
var level_root: Node2D
var level_data: LevelData
var main_route := PackedVector2Array()
var backup_route := PackedVector2Array()
var shortcut_pairs: Array = []
var event_points: Array = []
var render_view: SubViewport
var page_root: Node2D

func _ready() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() > 0:
        level_id = String(args[0])
    call_deferred("_render")

func _render() -> void:
    var meta: Dictionary = Manifest.LEVELS.get(level_id, {})
    var scene_path := String(Manifest.LEVELS.get(level_id, {}).get("scene", ""))
    if scene_path.is_empty():
        push_error("Unknown level: " + level_id)
        get_tree().quit(1)
        return

    var packed := load(scene_path) as PackedScene
    if packed == null:
        push_error("Cannot load scene: " + scene_path)
        get_tree().quit(1)
        return

    level_root = packed.instantiate() as Node2D
    if level_root == null:
        push_error("Scene is not Node2D: " + scene_path)
        get_tree().quit(1)
        return
    add_child(level_root)
    await get_tree().process_frame
    await get_tree().process_frame

    level_data = level_root.get("level_data") as LevelData
    if level_data != null and level_data.ninja_route != null:
        main_route = PackedVector2Array(level_data.ninja_route.waypoints)
    backup_route = PackedVector2Array(Manifest.BACKUP_ROUTES.get(level_id, []))
    shortcut_pairs = Manifest.SHORTCUTS.get(level_id, [])
    _collect_events()

    # Remove live gameplay UI and developer overlays from the art crop.
    var ui := level_root.get_node_or_null("UI")
    if ui:
        ui.visible = false
    var lp := level_root.get_node_or_null("LayoutPresentation")
    if lp:
        lp.visible = false
    var geom := level_root.get_node_or_null("LayoutGeometry")
    if geom:
        geom.visible = false
    var nav := level_root.get_node_or_null("Navigation")
    if nav:
        nav.visible = false

    # Hide live actors: the formal page uses small actor/role markers rather
    # than a random animation frame.
    for child in level_root.get_children():
        if child is CharacterBody2D or child.name in ["Cat", "Ninja", "Dog", "GuardA", "GuardB"]:
            child.visible = false

    await _build_page()
    await get_tree().process_frame
    await get_tree().process_frame

    var image := get_viewport().get_texture().get_image()
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
    var out := OUT_DIR + "/" + level_id + "_scene_layout.png"
    image.save_png(out)
    print("LAYOUT_BOOK_SAVED " + out)
    get_tree().quit()

func _collect_events() -> void:
    event_points.clear()
    if level_data == null or level_data.ninja_route == null:
        return
    for data in level_data.events:
        var idx := clampi(data.route_index, 0, level_data.ninja_route.waypoints.size() - 1)
        var p: Vector2 = level_data.ninja_route.waypoints[idx]
        event_points.append({"id": String(data.event_id), "name": String(data.display_name), "pos": p, "type": String(data.event_type)})

func _build_page() -> void:
    page_root = Node2D.new()
    page_root.name = "LayoutBookPage"
    add_child(page_root)
    page_root.z_index = 1000
    _draw_page_background()
    _draw_header()
    await _draw_map_panel()
    _draw_left_panel()
    _draw_right_panel()
    _draw_bottom_panel()

func _draw_page_background() -> void:
    var bg := ColorRect.new()
    bg.position = Vector2.ZERO
    bg.size = Vector2(W, H)
    bg.color = PANEL
    page_root.add_child(bg)

func _draw_header() -> void:
    var bar := ColorRect.new()
    bar.position = Vector2(0, 0)
    bar.size = Vector2(W, 112)
    bar.color = NAVY
    page_root.add_child(bar)
    _label("猫忍不住", Vector2(30, 18), 34, Color.WHITE, true)
    var meta: Dictionary = Manifest.LEVELS.get(level_id, {})
    _label(String(meta.get("chapter_title", "")), Vector2(315, 20), 26, Color.WHITE, true)
    _label(String(meta.get("display_name", "")), Vector2(315, 58), 15, Color("#a9bed3"))
    _label(level_id, Vector2(1160, 20), 32, Color.WHITE, true)
    _label(String(meta.get("target_time", "")), Vector2(1270, 22), 20, Color.WHITE, true)
    _label(String(meta.get("objective", "")), Vector2(1160, 62), 15, Color("#bcd0df"))

func _draw_map_panel() -> void:
    var frame := ColorRect.new()
    frame.position = MAP_RECT.position - Vector2(8, 8)
    frame.size = MAP_RECT.size + Vector2(16, 16)
    frame.color = NAVY
    page_root.add_child(frame)

    var crop := TextureRect.new()
    crop.position = MAP_RECT.position
    crop.size = MAP_RECT.size
    crop.texture = await _capture_level_art()
    crop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    crop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    page_root.add_child(crop)

    var overlay := RouteOverlay.new()
    overlay.position = MAP_RECT.position
    overlay.scale = Vector2(MAP_RECT.size.x / 1100.0, MAP_RECT.size.y / 680.0)
    overlay.main_route = main_route
    overlay.backup_route = backup_route
    overlay.shortcut_pairs = shortcut_pairs
    overlay.event_points = event_points
    overlay.start_point = main_route[0] if main_route.size() > 0 else Vector2(110, 500)
    overlay.goal_point = main_route[main_route.size() - 1] if main_route.size() > 0 else Vector2(1000, 300)
    page_root.add_child(overlay)

func _capture_level_art() -> Texture2D:
    # Capture the live scene from a dedicated 1100x680 SubViewport.
    render_view = SubViewport.new()
    render_view.size = Vector2i(1100, 680)
    render_view.transparent_bg = false
    render_view.render_target_update_mode = SubViewport.UPDATE_ONCE
    render_view.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
    add_child(render_view)
    var art_root := Node2D.new()
    render_view.add_child(art_root)
    level_root.reparent(art_root)
    level_root.position = Vector2.ZERO
    await get_tree().process_frame
    var tex := render_view.get_texture()
    level_root.reparent(self)
    render_view.queue_free()
    return tex

func _draw_left_panel() -> void:
    _panel(Rect2(24, 142, 245, 550), "1. 关卡概览")
    var meta: Dictionary = Manifest.LEVELS.get(level_id, {})
    _body([
        "南侧起点，北侧终点。",
        "主线负责安全且明确的",
        "剧情节奏；备用线用于",
        "引开敌人；猫捷径承担",
        "高风险高收益。",
        "",
        "学习目标",
        "• " + String(meta.get("objective", "")),
        "",
        "路线规则",
        "• 主线：橙色实线",
        "• 备用：蓝色虚线",
        "• 猫捷径：绿色虚线",
        "",
        "网格：16×16 px",
        "视角：2D 正交顶视"
    ], Vector2(42, 190), 15)

func _draw_right_panel() -> void:
    _panel(Rect2(1295, 142, 280, 550), "2. 图例 / 机制")
    _body([
        "路线",
        "━ 主线（安全但危险多）",
        "┄ 备用线（中风险）",
        "┄ 猫捷径（高风险高收益）",
        "",
        "关键标记",
        "🐱 起点 / 猫",
        "⚑ 终点",
        "● 检查点",
        "⚠ 危险事件",
        "",
        "事件",
    ], Vector2(1314, 190), 14)
    var y := 535.0
    for i in range(mini(event_points.size(), 6)):
        _label("%02d  %s" % [i + 1, String(event_points[i].name)], Vector2(1315, y), 12, DARK)
        y += 22

func _draw_bottom_panel() -> void:
    _panel(Rect2(24, 710, 1551, 265), "3. 三猫爪路线体系 / 生产备注")
    _mini_route(Vector2(45, 760), Vector2(360, 175), "主线", ORANGE, main_route, "安全但危险更多；按关卡节奏推进")
    _mini_route(Vector2(390, 760), Vector2(360, 175), "备用线", BLUE, backup_route, "中风险；适合引开敌人")
    var shortcut := PackedVector2Array()
    if shortcut_pairs.size() > 0:
        shortcut = PackedVector2Array([shortcut_pairs[0][0], shortcut_pairs[0][1]])
    _mini_route(Vector2(735, 760), Vector2(360, 175), "猫捷径", GREEN, shortcut, "猫专属；节省路程但暴露风险更高")
    _panel(Rect2(1110, 750, 445, 195), "4. 关卡生产信息")
    var notes := [
        "目标时长：" + String(Manifest.LEVELS.get(level_id, {}).get("target_time", "")),
        "事件数量：" + str(event_points.size()),
        "实际 Ninja Route 点：" + str(main_route.size()),
        "猫捷径：" + str(shortcut_pairs.size()) + " 条",
        "底图：实际关卡 Scene / Ninja Adventure 素材",
        "路线层：独立设计标注，不改变游戏逻辑"
    ]
    _body(notes, Vector2(1130, 795), 13)

func _panel(rect: Rect2, title: String) -> void:
    var bg := ColorRect.new()
    bg.position = rect.position
    bg.size = rect.size
    bg.color = Color.WHITE
    page_root.add_child(bg)
    var head := ColorRect.new()
    head.position = rect.position
    head.size = Vector2(rect.size.x, 38)
    head.color = NAVY
    page_root.add_child(head)
    _label(title, rect.position + Vector2(14, 7), 17, Color.WHITE, true)

func _body(lines: Array, pos: Vector2, size: int) -> void:
    var y := pos.y
    for line in lines:
        _label(String(line), Vector2(pos.x, y), size, DARK)
        y += size + 7

func _label(value: String, pos: Vector2, size: int, color: Color, bold := false) -> void:
    var l := Label.new()
    l.position = pos
    l.text = value
    l.add_theme_font_size_override("font_size", size)
    l.add_theme_color_override("font_color", color)
    if bold:
        l.add_theme_color_override("font_shadow_color", Color(0,0,0,0.25))
        l.add_theme_constant_override("shadow_offset_x", 1)
        l.add_theme_constant_override("shadow_offset_y", 1)
    page_root.add_child(l)

func _mini_route(pos: Vector2, size: Vector2, title: String, color: Color, route: PackedVector2Array, note: String) -> void:
    var panel := ColorRect.new()
    panel.position = pos
    panel.size = size
    panel.color = Color("#eef1f3")
    page_root.add_child(panel)
    _label(title, pos + Vector2(12, 8), 17, color, true)
    var r := RouteMini.new()
    r.position = pos + Vector2(8, 34)
    r.size = Vector2(size.x - 16, 82)
    r.route = route
    r.color_line = color
    page_root.add_child(r)
    _label(note, pos + Vector2(12, 125), 12, DARK)

class RouteOverlay extends Node2D:
    var main_route := PackedVector2Array()
    var backup_route := PackedVector2Array()
    var shortcut_pairs: Array = []
    var event_points: Array = []
    var start_point := Vector2.ZERO
    var goal_point := Vector2.ZERO
    func _draw() -> void:
        _poly(main_route, ORANGE, 5.0, false)
        _poly(backup_route, BLUE, 4.0, true)
        for pair in shortcut_pairs:
            if pair.size() >= 2:
                _segment(pair[0], pair[1], GREEN, 4.0, true)
        if start_point != Vector2.ZERO:
            draw_circle(start_point, 13, Color("#ef4752"))
            draw_string(ThemeDB.fallback_font, start_point + Vector2(-7,5), "①", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
        if goal_point != Vector2.ZERO:
            draw_circle(goal_point, 14, Color("#35c789"))
            draw_string(ThemeDB.fallback_font, goal_point + Vector2(-7,5), "②", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
        for i in range(event_points.size()):
            var p: Vector2 = event_points[i].pos
            draw_circle(p, 9, Color("#e94b4b"))
            draw_string(ThemeDB.fallback_font, p + Vector2(-4,4), str(i+1), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.WHITE)
    func _poly(points: PackedVector2Array, color: Color, width: float, dashed: bool) -> void:
        for i in range(points.size()-1):
            _segment(points[i], points[i+1], color, width, dashed)
    func _segment(a: Vector2, b: Vector2, color: Color, width: float, dashed: bool) -> void:
        if not dashed:
            draw_line(a,b,color,width,true)
            return
        var d := b-a
        var len := d.length()
        if len < 1: return
        var dir := d/len
        var step := 18.0
        var cur := 0.0
        while cur < len:
            var endv := minf(cur+9.0,len)
            draw_line(a+dir*cur,a+dir*endv,color,width,true)
            cur += step

class RouteMini extends Control:
    var route := PackedVector2Array()
    var color_line := Color.WHITE
    func _draw() -> void:
        if route.size()<2:return
        var minv:=Vector2(9999,9999)
        var maxv:=Vector2(-9999,-9999)
        for p in route:
            minv=minv.min(p);maxv=maxv.max(p)
        var span=maxv-minv
        span.x=maxf(span.x,1);span.y=maxf(span.y,1)
        for i in range(route.size()-1):
            var a=Vector2((route[i].x-minv.x)/span.x*size.x, (route[i].y-minv.y)/span.y*size.y)
            var b=Vector2((route[i+1].x-minv.x)/span.x*size.x, (route[i+1].y-minv.y)/span.y*size.y)
            draw_line(a,b,color_line,4,true)
