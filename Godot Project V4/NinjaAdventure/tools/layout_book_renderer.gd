extends Node2D
class_name LayoutBookRenderer

# 《猫忍不住》Level Design Bible 页面渲染器
# - 底图：加载真实关卡 Scene，并隐藏运行时 UI / 角色
# - 数据：读取真实 LevelData / RouteData / EventPointData
# - 标注：主线为真实 Ninja Route；备用线与猫捷径为设计标注层
# - 输出：1600×1000 的单页关卡设计图
#
# CLI:
#   godot --path . --scene res://tools/layout_book_renderer.tscn -- L05
#
# 注意：该工具只生成文档，不修改游戏关卡逻辑。

const Manifest = preload("res://tools/layout_book_manifest.gd")

const OUT_DIR := "res://art/layout_book/rendered"
const W := 1600
const H := 1000

const PAPER := Color("#f3f0e7")
const PAPER_2 := Color("#e9e4d7")
const NAVY := Color("#0b2038")
const NAVY_2 := Color("#173653")
const INK := Color("#172331")
const MUTED := Color("#5f6f7d")
const LINE := Color("#c9c3b4")
const WHITE := Color("#ffffff")
const ORANGE := Color("#f0a51d")
const BLUE := Color("#2aa8e8")
const GREEN := Color("#56c95f")
const RED := Color("#e54b4b")
const PURPLE := Color("#7c68d9")
const CYAN := Color("#46c7c7")
const SOFT_ORANGE := Color("#fff1c9")
const SOFT_BLUE := Color("#e4f4fb")
const SOFT_GREEN := Color("#e5f7e6")
const SOFT_RED := Color("#fde7e7")

const MAP_RECT := Rect2(292, 146, 930, 560)
const LEFT_RECT := Rect2(24, 146, 246, 560)
const RIGHT_RECT := Rect2(1246, 146, 330, 560)
const BOTTOM_RECT := Rect2(24, 722, 1552, 252)

const LEVEL_ORDER := ["L01","L02","L03","L04","L05","L06","L07","L08","L09","L10","L11","L12"]

# 这些是当前 SceneArtBuilder 中实际使用的道具资源；功能描述是关卡设计文档层面的
# 使用方式，不会改动运行逻辑。
const PROP_ITEMS := {
    "L01": [
        ["小树", "地标", "视觉引导 / 遮挡", "res://assets/tilesets/nature.png"],
        ["鱼网", "摆件", "区域识别 / 绕行", "res://assets/props/fish_net.png"],
        ["木箱", "摆件", "掩体 / 路径组织", "res://assets/props/crate.png"]
    ],
    "L02": [
        ["小树", "地标", "视觉引导 / 遮挡", "res://assets/tilesets/nature.png"],
        ["鱼网", "摆件", "区域识别 / 绕行", "res://assets/props/fish_net.png"],
        ["木箱", "摆件", "掩体 / 路径组织", "res://assets/props/crate.png"]
    ],
    "L03": [
        ["大树", "地标", "遮挡 / 分割视线", "res://assets/tilesets/nature.png"],
        ["木箱", "摆件", "掩体 / 取物位", "res://assets/props/crate.png"],
        ["鱼网", "摆件", "区域识别 / 绕行", "res://assets/props/fish_net.png"]
    ],
    "L04": [
        ["樱花树", "地标", "空间识别 / 遮挡", "res://assets/tilesets/nature.png"],
        ["鱼网", "摆件", "视觉分区 / 绕行", "res://assets/props/fish_net.png"],
        ["木箱", "摆件", "掩体 / 事件载体", "res://assets/props/crate.png"]
    ],
    "L05": [
        ["鱼", "任务物", "搬运目标 / 路线节奏", "res://assets/props/fish.png"],
        ["鱼网", "摆件", "码头地标 / 路线分界", "res://assets/props/fish_net.png"],
        ["木箱", "摆件", "掩体 / 路径组织", "res://assets/props/crate.png"],
        ["葫芦", "互动物", "事件载体 / 容错点", "res://assets/props/gourd.png"],
        ["铁蒺藜", "机关", "伤害 / 禁行威胁", "res://assets/props/caltrop.png"]
    ],
    "L06": [
        ["鱼", "任务物", "搬运目标 / 路线节奏", "res://assets/props/fish.png"],
        ["木箱", "摆件", "掩体 / 转角", "res://assets/props/crate.png"],
        ["铁蒺藜", "机关", "伤害 / 禁行威胁", "res://assets/props/caltrop.png"]
    ],
    "L07": [
        ["鱼", "任务物", "搬运目标 / 诱导", "res://assets/props/fish.png"],
        ["木箱", "摆件", "掩体 / 事件载体", "res://assets/props/crate.png"],
        ["生命罐", "资源物", "恢复 / 容错", "res://assets/props/life_pot.png"]
    ],
    "L08": [
        ["鱼", "任务物", "搬运目标 / 资源冲突", "res://assets/props/fish.png"],
        ["木箱", "摆件", "掩体 / 多线程节点", "res://assets/props/crate.png"],
        ["生命罐", "资源物", "恢复 / 容错", "res://assets/props/life_pot.png"],
        ["铁蒺藜", "机关", "伤害 / 路线压缩", "res://assets/props/caltrop.png"]
    ],
    "L09": [
        ["鱼网", "摆件", "区域识别 / 遮挡", "res://assets/props/fish_net.png"],
        ["炸药箱", "机关", "连锁危险 / 区域控制", "res://assets/props/dynamite_crate.png"],
        ["枯树", "地标", "暴雨氛围 / 路线分界", "res://assets/tilesets/nature.png"]
    ],
    "L10": [
        ["炸药箱", "机关", "连锁危险 / 预判点", "res://assets/props/dynamite_crate.png"],
        ["铁蒺藜", "机关", "伤害 / 路线压缩", "res://assets/props/caltrop.png"],
        ["生命罐", "资源物", "恢复 / 风险补偿", "res://assets/props/life_pot.png"]
    ],
    "L11": [
        ["炸药箱", "机关", "连锁危险 / 并行线程", "res://assets/props/dynamite_crate.png"],
        ["铁蒺藜", "机关", "伤害 / 路线压缩", "res://assets/props/caltrop.png"],
        ["生命罐", "资源物", "恢复 / 风险补偿", "res://assets/props/life_pot.png"]
    ],
    "L12": [
        ["葫芦", "Boss物", "战斗触发 / 交互", "res://assets/props/gourd.png"],
        ["炸药箱", "Boss物", "连锁控制 / 反制窗口", "res://assets/props/dynamite_crate.png"],
        ["铁蒺藜", "Boss机关", "区域压缩 / 惩罚", "res://assets/props/caltrop.png"],
        ["吊车", "Boss机关", "空间控制 / Boss 机制", "res://assets/props/crane.png"]
    ]
}

const CHAPTER_COPY := {
    "CH01": {
        "sub": "村口风云",
        "tone": "基础认知 → 视线管理 → 顺序解谜",
        "skill": "移动 / 跑位 / 视线 / 基础绕行"
    },
    "CH02": {
        "sub": "月下码头",
        "tone": "搬运压力 → NPC 联动 → 多线程调度",
        "skill": "搬运 / 引诱 / 事件顺序 / 路线切换"
    },
    "CH03": {
        "sub": "天守阁",
        "tone": "环境压力 → 连锁事故 → Boss 规则战",
        "skill": "预判 / 潜行 / 并行 / 战中补救"
    }
}

var level_id := "L05"
var level_root: Node2D
var level_data: LevelData
var main_route := PackedVector2Array()
var backup_route := PackedVector2Array()
var shortcut_pairs: Array = []
var event_points: Array = []
var actor_names: Array = []
var scene_layer_counts := {}
var page_root: Node2D
var cjk_font: Font

func _ready() -> void:
    _setup_font()
    var args := OS.get_cmdline_user_args()
    if args.size() > 0:
        level_id = String(args[0])
    call_deferred("_render")

func _setup_font() -> void:
    var font := SystemFont.new()
    font.font_names = PackedStringArray(["Noto Sans CJK SC", "Noto Sans CJK JP", "Noto Sans CJK TC"])
    cjk_font = font

func _render() -> void:
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
    _collect_scene_structure()
    _hide_gameplay_overlays()

    await _build_page()
    await get_tree().process_frame
    await get_tree().process_frame

    var image := get_viewport().get_texture().get_image()
    image.convert(Image.FORMAT_RGBA8)

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
        var count := level_data.ninja_route.waypoints.size()
        if count == 0:
            continue
        var idx := clampi(data.route_index, 0, count - 1)
        var p: Vector2 = level_data.ninja_route.waypoints[idx]
        event_points.append({
            "id": String(data.event_id),
            "name": String(data.display_name),
            "pos": p,
            "type": String(data.event_type),
            "risk": String(data.risk_level),
            "high_risk": bool(data.high_risk),
            "required": String(data.required_action),
            "group": String(data.event_group)
        })

func _collect_scene_structure() -> void:
    actor_names.clear()
    scene_layer_counts.clear()
    scene_layer_counts["底图 / SceneArt"] = 0
    scene_layer_counts["碰撞 / Walls"] = 0
    scene_layer_counts["事件 / Events"] = 0
    scene_layer_counts["角色 / Actors"] = 0
    scene_layer_counts["UI / Runtime"] = 0

    var top := level_root.get_children()
    for child in top:
        var n := String(child.name)
        if n == "SceneArt":
            scene_layer_counts["底图 / SceneArt"] += 1
        elif n == "Walls":
            scene_layer_counts["碰撞 / Walls"] += 1
        elif n == "Events":
            scene_layer_counts["事件 / Events"] += 1
        elif n == "UI":
            scene_layer_counts["UI / Runtime"] += 1

        if child is CharacterBody2D or n in ["Cat", "Ninja", "Dog", "GuardA", "GuardB"]:
            actor_names.append(n)
            scene_layer_counts["角色 / Actors"] += 1

        if child is CanvasLayer or child is Control or n.to_lower().find("touch") >= 0 or n.to_lower().find("pause") >= 0:
            child.visible = false

    # 这是生产文档中的建议分层，而非对运行时节点结构做修改。
    scene_layer_counts["交互 / 机关"] = PROP_ITEMS.get(level_id, []).size()
    scene_layer_counts["标注 / Design"] = 1

func _hide_gameplay_overlays() -> void:
    var ui := level_root.get_node_or_null("UI")
    if ui:
        ui.visible = false
    for node_name in ["LayoutPresentation", "LayoutGeometry", "Navigation"]:
        var n := level_root.get_node_or_null(node_name)
        if n:
            n.visible = false

    for child in level_root.get_children():
        if child is CharacterBody2D or child.name in ["Cat", "Ninja", "Dog", "GuardA", "GuardB"]:
            child.visible = false
        if child is CanvasLayer or child is Control or child.name.to_lower().find("touch") >= 0 or child.name.to_lower().find("pause") >= 0:
            child.visible = false

func _build_page() -> void:
    page_root = Node2D.new()
    page_root.name = "LevelDesignBiblePage"
    page_root.z_index = 1000
    add_child(page_root)

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
    bg.color = PAPER
    page_root.add_child(bg)

    var grid := GridPaper.new()
    grid.position = Vector2.ZERO
    grid.size = Vector2(W, H)
    grid.modulate.a = 0.38
    page_root.add_child(grid)

func _draw_header() -> void:
    var bar := ColorRect.new()
    bar.position = Vector2.ZERO
    bar.size = Vector2(W, 118)
    bar.color = NAVY
    page_root.add_child(bar)

    var accent := ColorRect.new()
    accent.position = Vector2(24, 20)
    accent.size = Vector2(8, 78)
    accent.color = ORANGE
    page_root.add_child(accent)

    _label("猫忍不住", Vector2(50, 18), 34, WHITE, true)
    _label("LEVEL DESIGN BIBLE", Vector2(50, 61), 13, Color("#b6c6d5"), true)

    var meta: Dictionary = Manifest.LEVELS.get(level_id, {})
    var chapter := String(meta.get("chapter", ""))
    var chapter_meta: Dictionary = CHAPTER_COPY.get(chapter, {})

    _label(chapter, Vector2(330, 18), 16, ORANGE, true)
    _label(String(meta.get("chapter_title", "")), Vector2(390, 16), 24, WHITE, true)
    _label(String(meta.get("display_name", "")), Vector2(390, 53), 17, Color("#d1dde7"))
    _label(String(chapter_meta.get("tone", "")), Vector2(390, 79), 12, Color("#9fb3c7"))

    _badge(Vector2(1130, 19), Vector2(95, 30), level_id, ORANGE, NAVY)
    _badge(Vector2(1234, 19), Vector2(142, 30), String(meta.get("target_time", "")), WHITE, NAVY)
    _label(String(meta.get("objective", "")), Vector2(1132, 62), 13, Color("#d1dde7"))

func _draw_map_panel() -> void:
    _panel(MAP_RECT, "01 真实场景 / ROUTE MAP", NAVY)

    var crop := TextureRect.new()
    crop.position = MAP_RECT.position + Vector2(8, 48)
    crop.size = Vector2(MAP_RECT.size.x - 16, MAP_RECT.size.y - 56)
    page_root.visible = false
    crop.texture = await _capture_level_art()
    page_root.visible = true
    crop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    crop.stretch_mode = TextureRect.STRETCH_SCALE
    page_root.add_child(crop)

    var overlay := RouteOverlay.new()
    overlay.position = crop.position
    overlay.scale = Vector2(crop.size.x / 1100.0, crop.size.y / 680.0)
    overlay.main_route = main_route
    overlay.backup_route = backup_route
    overlay.shortcut_pairs = shortcut_pairs
    overlay.event_points = event_points
    overlay.start_point = main_route[0] if main_route.size() > 0 else Vector2(110, 500)
    overlay.goal_point = main_route[main_route.size() - 1] if main_route.size() > 0 else Vector2(1000, 300)
    overlay.font = cjk_font
    page_root.add_child(overlay)

    _label("A", crop.position + Vector2(24, 28), 18, WHITE, true)
    _label("入口区", crop.position + Vector2(47, 30), 11, WHITE, true)
    _label("B", crop.position + Vector2(crop.size.x * 0.49, 28), 18, WHITE, true)
    _label("核心处理区", crop.position + Vector2(crop.size.x * 0.49 + 24, 30), 11, WHITE, true)
    _label("C", crop.position + Vector2(crop.size.x - 84, 28), 18, WHITE, true)
    _label("脱离区", crop.position + Vector2(crop.size.x - 61, 30), 11, WHITE, true)

func _capture_level_art() -> Texture2D:
    await get_tree().process_frame
    await get_tree().process_frame
    var image := get_viewport().get_texture().get_image()
    image.convert(Image.FORMAT_RGBA8)
    image.resize(1100, 680, Image.INTERPOLATE_NEAREST)
    return ImageTexture.create_from_image(image)

func _draw_left_panel() -> void:
    _panel(LEFT_RECT, "02 章节卡 / CHAPTER CARD", NAVY)

    var meta: Dictionary = Manifest.LEVELS.get(level_id, {})
    var chapter := String(meta.get("chapter", ""))
    var cm: Dictionary = CHAPTER_COPY.get(chapter, {})

    _label(chapter, Vector2(42, 202), 28, ORANGE, true)
    _label(String(cm.get("sub", "")), Vector2(42, 238), 20, INK, true)
    _label("关卡 " + level_id, Vector2(42, 274), 13, MUTED, true)

    _rule(Vector2(42, 306), Vector2(252, 306))
    _label("训练目标", Vector2(42, 332), 13, NAVY_2, true)
    _wrap_label(String(cm.get("skill", "")), Vector2(42, 357), 206, 14, INK)

    _label("本关定位", Vector2(42, 414), 13, NAVY_2, true)
    _wrap_label(String(meta.get("objective", "")), Vector2(42, 439), 206, 15, INK)

    _label("数据状态", Vector2(42, 500), 13, NAVY_2, true)
    _kv(Vector2(42, 528), "Ninja Route", str(main_route.size()) + " 点")
    _kv(Vector2(42, 556), "事件", str(event_points.size()) + " 个")
    _kv(Vector2(42, 584), "场景物件", str(PROP_ITEMS.get(level_id, []).size()) + " 项")
    _kv(Vector2(42, 612), "角色", str(actor_names.size()) + " 个")
    _kv(Vector2(42, 640), "网格", "16 × 16 px")
    _kv(Vector2(42, 668), "视角", "2D 正交顶视")

func _draw_right_panel() -> void:
    _panel(RIGHT_RECT, "03 机关物与物件 / OBJECTS", NAVY)

    var items: Array = PROP_ITEMS.get(level_id, [])
    var y := 194.0
    var row_h := 52.0
    for i in range(mini(items.size(), 4)):
        var item: Array = items[i]
        _prop_row(Vector2(1262, y), Vector2(298, 48), i + 1, item)
        y += row_h

    _rule(Vector2(1262, 412), Vector2(1558, 412))
    _label("事件链 / EVENT CHAIN", Vector2(1262, 434), 12, NAVY_2, true)

    y = 458
    for i in range(mini(event_points.size(), 3)):
        var e: Dictionary = event_points[i]
        _event_chip(Vector2(1262, y), Vector2(298, 25), i + 1, e)
        y += 28
    if event_points.size() > 3:
        _label("+ %d 个事件见地图编号" % (event_points.size() - 3), Vector2(1262, 544), 9, MUTED)

    _label("垂直分层 / Z-LAYER", Vector2(1262, 568), 12, NAVY_2, true)
    var layer := VerticalLayer.new()
    layer.position = Vector2(1262, 588)
    layer.size = Vector2(298, 112)
    layer.counts = scene_layer_counts
    layer.font = cjk_font
    page_root.add_child(layer)

func _draw_bottom_panel() -> void:
    _panel(BOTTOM_RECT, "04 三猫爪路线体系 / THREE-PAW ROUTE SYSTEM", NAVY)

    _route_card(Vector2(42, 774), Vector2(468, 172), "主线", ORANGE, main_route,
        "实际 Ninja Route", "标准解法 / 节奏基准", "真实数据")
    _route_card(Vector2(528, 774), Vector2(468, 172), "备用线", BLUE, backup_route,
        "设计标注", "引开 / 绕行 / 调度", "文档层")
    var shortcut := PackedVector2Array()
    if shortcut_pairs.size() > 0:
        shortcut = PackedVector2Array([shortcut_pairs[0][0], shortcut_pairs[0][1]])
    _route_card(Vector2(1014, 774), Vector2(468, 172), "猫捷径", GREEN, shortcut,
        "设计标注", "高机动 / 高收益 / 高风险", "猫专属")

    _label("生产备注", Vector2(1500, 798), 11, MUTED, true)
    _label("底图来自实际 Scene", Vector2(1500, 824), 10, INK)
    _label("路线与事件为数据绑定", Vector2(1500, 846), 10, INK)
    _label("标注层不修改玩法逻辑", Vector2(1500, 868), 10, INK)
    _label("用途：策划 / 美术 / 程序", Vector2(1500, 900), 10, INK)

func _route_card(pos: Vector2, size: Vector2, title: String, accent: Color, route: PackedVector2Array,
        source: String, desc: String, state: String) -> void:
    var box := ColorRect.new()
    box.position = pos
    box.size = size
    box.color = Color("#fffdf8")
    page_root.add_child(box)

    var stripe := ColorRect.new()
    stripe.position = pos
    stripe.size = Vector2(6, size.y)
    stripe.color = accent
    page_root.add_child(stripe)

    _label(title, pos + Vector2(16, 10), 18, accent, true)
    _label(source, pos + Vector2(88, 12), 10, MUTED, true)

    var r := RouteMini.new()
    r.position = pos + Vector2(18, 42)
    r.size = Vector2(265, 86)
    r.route = route
    r.color_line = accent
    page_root.add_child(r)

    var dist := _route_distance(route)
    _label("路程", pos + Vector2(302, 50), 10, MUTED, true)
    _label("%.0f px" % dist, pos + Vector2(302, 68), 16, INK, true)
    _label("风险", pos + Vector2(302, 96), 10, MUTED, true)
    _risk_bar(pos + Vector2(302, 113), 100, accent, title)
    _label(state, pos + Vector2(302, 140), 10, accent, true)
    _label(desc, pos + Vector2(16, 148), 10, INK)

func _prop_row(pos: Vector2, size: Vector2, idx: int, item: Array) -> void:
    var bg := ColorRect.new()
    bg.position = pos
    bg.size = size
    bg.color = Color("#fffdf8")
    page_root.add_child(bg)

    var tex_path := String(item[3])
    var tex := load(tex_path) as Texture2D
    if tex:
        var image := TextureRect.new()
        image.position = pos + Vector2(8, 8)
        image.size = Vector2(38, 38)
        image.texture = tex
        image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        page_root.add_child(image)

    _label("%02d" % idx, pos + Vector2(54, 7), 10, MUTED, true)
    _label(String(item[0]), pos + Vector2(75, 6), 13, INK, true)
    _badge(pos + Vector2(75, 28), Vector2(50, 18), String(item[1]), ORANGE, WHITE)
    _label(String(item[2]), pos + Vector2(135, 31), 9, MUTED)

func _prop_icon(pos: Vector2, item: Array) -> void:
    var bg := ColorRect.new()
    bg.position = pos
    bg.size = Vector2(38, 38)
    bg.color = Color("#ece5d6")
    page_root.add_child(bg)
    var glyph := "物"
    if String(item[1]) == "地标":
        glyph = "地"
    elif String(item[1]) == "机关":
        glyph = "机"
    elif String(item[1]) == "任务物":
        glyph = "任"
    var l := Label.new()
    l.position = pos + Vector2(9, 5)
    l.text = glyph
    l.add_theme_font_size_override("font_size", 22)
    l.add_theme_color_override("font_color", ORANGE)
    if cjk_font:
        l.add_theme_font_override("font", cjk_font)
    page_root.add_child(l)

func _event_chip(pos: Vector2, size: Vector2, idx: int, e: Dictionary) -> void:
    var color := RED if bool(e.get("high_risk", false)) else NAVY_2
    var bgc := SOFT_RED if bool(e.get("high_risk", false)) else Color("#f0f3f5")

    var bg := ColorRect.new()
    bg.position = pos
    bg.size = size
    bg.color = bgc
    page_root.add_child(bg)

    _label("%02d" % idx, pos + Vector2(7, 5), 9, color, true)
    _label(String(e.get("name", "")), pos + Vector2(31, 4), 10, INK, true)
    _label(String(e.get("type", "")), pos + Vector2(205, 5), 8, color, true)

func _risk_bar(pos: Vector2, width: float, accent: Color, title: String) -> void:
    var bg := ColorRect.new()
    bg.position = pos
    bg.size = Vector2(width, 8)
    bg.color = Color("#d8d4cb")
    page_root.add_child(bg)

    var fill := ColorRect.new()
    fill.position = pos
    fill.size = Vector2(width * (0.85 if title == "猫捷径" else (0.55 if title == "备用线" else 0.35)), 8)
    fill.color = accent
    page_root.add_child(fill)

func _panel(rect: Rect2, title: String, header_color: Color) -> void:
    var bg := ColorRect.new()
    bg.position = rect.position
    bg.size = rect.size
    bg.color = WHITE
    page_root.add_child(bg)

    var head := ColorRect.new()
    head.position = rect.position
    head.size = Vector2(rect.size.x, 42)
    head.color = header_color
    page_root.add_child(head)

    _label(title, rect.position + Vector2(14, 8), 15, WHITE, true)

func _rule(a: Vector2, b: Vector2) -> void:
    var line := ColorRect.new()
    line.position = a
    line.size = Vector2(b.x - a.x, 1)
    line.color = LINE
    page_root.add_child(line)

func _badge(pos: Vector2, size: Vector2, text: String, fill: Color, text_color: Color) -> void:
    var bg := ColorRect.new()
    bg.position = pos
    bg.size = size
    bg.color = fill
    page_root.add_child(bg)
    _label(text, pos + Vector2(8, 6), 11, text_color, true)

func _kv(pos: Vector2, k: String, v: String) -> void:
    _label(k, pos, 10, MUTED, true)
    _label(v, pos + Vector2(105, -1), 11, INK, true)

func _wrap_label(value: String, pos: Vector2, width: float, size: int, color: Color) -> void:
    var l := Label.new()
    l.position = pos
    l.size = Vector2(width, 50)
    l.text = value
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    l.add_theme_font_size_override("font_size", size)
    l.add_theme_color_override("font_color", color)
    if cjk_font:
        l.add_theme_font_override("font", cjk_font)
    page_root.add_child(l)

func _label(value: String, pos: Vector2, size: int, color: Color, bold := false) -> void:
    var l := Label.new()
    l.position = pos
    l.text = value
    l.add_theme_font_size_override("font_size", size)
    l.add_theme_color_override("font_color", color)
    if cjk_font:
        l.add_theme_font_override("font", cjk_font)
    if bold:
        l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.22))
        l.add_theme_constant_override("shadow_offset_x", 1)
        l.add_theme_constant_override("shadow_offset_y", 1)
    page_root.add_child(l)

func _route_distance(route: PackedVector2Array) -> float:
    var d := 0.0
    for i in range(route.size() - 1):
        d += route[i].distance_to(route[i + 1])
    return d

class GridPaper extends Control:
    func _draw() -> void:
        for x in range(0, 1600, 32):
            draw_line(Vector2(x, 0), Vector2(x, 1000), Color("#b8b09e"), 1.0)
        for y in range(0, 1000, 32):
            draw_line(Vector2(0, y), Vector2(1600, y), Color("#b8b09e"), 1.0)

class RouteOverlay extends Node2D:
    var main_route := PackedVector2Array()
    var backup_route := PackedVector2Array()
    var shortcut_pairs: Array = []
    var event_points: Array = []
    var start_point := Vector2.ZERO
    var goal_point := Vector2.ZERO
    var font: Font

    func _draw() -> void:
        _poly(main_route, ORANGE, 5.0, false)
        _poly(backup_route, BLUE, 4.0, true)

        for pair in shortcut_pairs:
            if pair.size() >= 2:
                _segment(pair[0], pair[1], GREEN, 5.0, true)

        if start_point != Vector2.ZERO:
            _marker(start_point, RED, "起")
        if goal_point != Vector2.ZERO:
            _marker(goal_point, GREEN, "终")

        for i in range(event_points.size()):
            var e: Dictionary = event_points[i]
            var p: Vector2 = e["pos"]
            var ec := RED if bool(e.get("high_risk", false)) else NAVY_2
            draw_circle(p, 10, ec)
            draw_circle(p, 13, Color(ec.r, ec.g, ec.b, 0.20))
            if font:
                draw_string(font, p + Vector2(-4, 4), str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, WHITE)

    func _marker(p: Vector2, c: Color, txt: String) -> void:
        draw_circle(p, 15, Color(c.r, c.g, c.b, 0.20))
        draw_circle(p, 11, c)
        if font:
            draw_string(font, p + Vector2(-7, 5), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, WHITE)

    func _poly(points: PackedVector2Array, color: Color, width: float, dashed: bool) -> void:
        for i in range(points.size() - 1):
            _segment(points[i], points[i + 1], color, width, dashed)

    func _segment(a: Vector2, b: Vector2, color: Color, width: float, dashed: bool) -> void:
        if not dashed:
            draw_line(a, b, color, width, true)
            return
        var delta := b - a
        var length := delta.length()
        if length < 1:
            return
        var dir := delta / length
        var cur := 0.0
        while cur < length:
            var endv := minf(cur + 12.0, length)
            draw_line(a + dir * cur, a + dir * endv, color, width, true)
            cur += 22.0

class RouteMini extends Control:
    var route := PackedVector2Array()
    var color_line := Color.WHITE
    func _draw() -> void:
        if route.size() < 2:
            draw_string(ThemeDB.fallback_font, Vector2(0, 40), "暂无路线标注", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, MUTED)
            return
        var minv := Vector2(9999, 9999)
        var maxv := Vector2(-9999, -9999)
        for p in route:
            minv = minv.min(p)
            maxv = maxv.max(p)
        var span := maxv - minv
        span.x = maxf(span.x, 1)
        span.y = maxf(span.y, 1)
        for i in range(route.size() - 1):
            var a := Vector2((route[i].x - minv.x) / span.x * size.x,
                (route[i].y - minv.y) / span.y * size.y)
            var b := Vector2((route[i + 1].x - minv.x) / span.x * size.x,
                (route[i + 1].y - minv.y) / span.y * size.y)
            draw_line(a, b, color_line, 4, true)
        draw_circle(Vector2(4, size.y - 4), 4, color_line)
        draw_circle(Vector2(size.x - 4, 4), 4, color_line)

class VerticalLayer extends Control:
    var counts := {}
    var font: Font

    func _draw() -> void:
        var labels := [
            ["01  地表 / 底图", "#8a6a46"],
            ["02  碰撞 / 墙体", "#5f6f7d"],
            ["03  机关 / 事件", "#e54b4b"],
            ["04  角色 / 巡逻", "#2aa8e8"],
            ["05  表现 / 标注", "#7c68d9"]
        ]
        var y := 0.0
        for i in range(labels.size()):
            var row_h := 20.0
            var fill := Color(labels[i][1])
            draw_rect(Rect2(0, y, size.x, row_h - 2), Color(fill.r, fill.g, fill.b, 0.16))
            draw_rect(Rect2(0, y, 6, row_h - 2), fill)
            if font:
                draw_string(font, Vector2(14, y + 14), labels[i][0], HORIZONTAL_ALIGNMENT_LEFT, -1, 9, INK)
            y += row_h

        var hint := "实际节点：%d / %d / %d / %d" % [
            int(counts.get("底图 / SceneArt", 0)),
            int(counts.get("碰撞 / Walls", 0)),
            int(counts.get("事件 / Events", 0)),
            int(counts.get("角色 / Actors", 0))
        ]
        if font:
            draw_string(font, Vector2(0, y + 8), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, MUTED)

