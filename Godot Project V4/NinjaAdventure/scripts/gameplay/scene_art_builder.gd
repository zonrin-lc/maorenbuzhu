class_name SceneArtBuilder
extends RefCounted

# v1.6 正式美术层构建器（自 UnifiedLevelManager 抽离）：
# 背景与摆件均来自工程现有 Ninja Adventure 素材；不改变碰撞、事件坐标或 Ninja 固定路线。

const NATURE_SHEET := "res://assets/tilesets/nature.png"
const DECOR_REGIONS := {
    &"tree_round": Rect2(0, 0, 32, 32),
    &"tree_big": Rect2(44, 288, 56, 48),
    &"cherry": Rect2(0, 280, 64, 56),
    &"dead_tree": Rect2(64, 0, 32, 32),
    &"rock_gray": Rect2(288, 256, 64, 48),
    &"sunflower": Rect2(16, 176, 16, 16),
    &"daisy": Rect2(96, 176, 16, 16),
    &"tuft": Rect2(48, 160, 16, 16),
    &"tuft2": Rect2(144, 160, 16, 16),
    &"mushroom": Rect2(192, 176, 16, 16),
    &"bush": Rect2(0, 160, 32, 32),
}

static func build_floor(parent: Node2D) -> void:
    # 底层仅保留统一色底；正式章节美术由 SceneArt 在其上提供。
    var floor_rect := ColorRect.new()
    floor_rect.name = "Floor"
    floor_rect.position = Vector2.ZERO
    floor_rect.size = Vector2(1100, 680)
    floor_rect.color = Color("#0b0f14")
    floor_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    floor_rect.z_index = -120
    parent.add_child(floor_rect)

static func build_decorations(parent: Node2D, level_data: LevelData) -> void:
    var layer := Node2D.new()
    layer.name = "SceneArt"
    layer.z_index = -60
    parent.add_child(layer)

    var chapter := String(level_data.chapter_id) if level_data != null else "CH01"
    var background_path := "res://assets/scene_art/chapter_village_bg.png"
    match chapter:
        "CH02": background_path = "res://assets/scene_art/chapter_dock_bg.png"
        "CH03": background_path = "res://assets/scene_art/chapter_castle_bg.png"

    var bg := Sprite2D.new()
    bg.name = "ChapterBackground"
    bg.texture = load(background_path)
    bg.position = Vector2(552, 370)
    bg.z_index = -100
    layer.add_child(bg)

    # 仅保留少量前景层，确保角色永远清楚。
    var lid := String(level_data.level_id) if level_data != null else ""
    match lid:
        "L01":
            _add_decor(layer, &"tree_round", Vector2(105, 225), 1.15, Color.WHITE)
            _add_decor_tex(layer, load("res://assets/props/fish_net.png"), Vector2(330, 330), 1.55)
            _add_decor_tex(layer, load("res://assets/props/crate.png"), Vector2(750, 392), 2.0)
        "L02":
            _add_decor(layer, &"tree_round", Vector2(185, 250), 1.0, Color.WHITE)
            _add_decor_tex(layer, load("res://assets/props/fish_net.png"), Vector2(500, 300), 1.4)
            _add_decor_tex(layer, load("res://assets/props/crate.png"), Vector2(815, 420), 2.0)
        "L03":
            _add_decor(layer, &"tree_big", Vector2(90, 230), 1.0, Color.WHITE)
            _add_decor_tex(layer, load("res://assets/props/crate.png"), Vector2(520, 380), 2.0)
            _add_decor_tex(layer, load("res://assets/props/fish_net.png"), Vector2(875, 420), 1.35)
        "L04":
            _add_decor(layer, &"cherry", Vector2(155, 220), 1.0, Color.WHITE)
            _add_decor_tex(layer, load("res://assets/props/fish_net.png"), Vector2(450, 340), 1.45)
            _add_decor_tex(layer, load("res://assets/props/crate.png"), Vector2(610, 440), 2.1)
        "L05":
            _add_decor_tex(layer, load("res://assets/props/fish.png"), Vector2(300, 350), 1.7)
            _add_decor_tex(layer, load("res://assets/props/fish_net.png"), Vector2(430, 165), 1.25)
            _add_decor_tex(layer, load("res://assets/props/crate.png"), Vector2(560, 150), 2.0)
            _add_decor_tex(layer, load("res://assets/props/gourd.png"), Vector2(745, 255), 1.9)
            _add_decor_tex(layer, load("res://assets/props/caltrop.png"), Vector2(900, 410), 1.8)
        "L06":
            _add_decor_tex(layer, load("res://assets/props/fish.png"), Vector2(250, 490), 1.7)
            _add_decor_tex(layer, load("res://assets/props/crate.png"), Vector2(475, 285), 2.0)
            _add_decor_tex(layer, load("res://assets/props/caltrop.png"), Vector2(840, 420), 1.7)
        "L07":
            _add_decor_tex(layer, load("res://assets/props/fish.png"), Vector2(300, 350), 1.7)
            _add_decor_tex(layer, load("res://assets/props/crate.png"), Vector2(600, 445), 1.9)
            _add_decor_tex(layer, load("res://assets/props/life_pot.png"), Vector2(860, 250), 1.7)
        "L08":
            _add_decor_tex(layer, load("res://assets/props/fish.png"), Vector2(240, 420), 1.7)
            _add_decor_tex(layer, load("res://assets/props/crate.png"), Vector2(470, 300), 2.0)
            _add_decor_tex(layer, load("res://assets/props/life_pot.png"), Vector2(690, 230), 1.7)
            _add_decor_tex(layer, load("res://assets/props/caltrop.png"), Vector2(820, 330), 1.8)
        "L09":
            _add_decor_tex(layer, load("res://assets/props/fish_net.png"), Vector2(250, 430), 1.35)
            _add_decor_tex(layer, load("res://assets/props/dynamite_crate.png"), Vector2(590, 300), 2.0)
            _add_decor(layer, &"dead_tree", Vector2(100, 225), 1.15, Color(0.75,0.78,0.85,1.0))
        "L10":
            _add_decor_tex(layer, load("res://assets/props/dynamite_crate.png"), Vector2(440, 500), 2.0)
            _add_decor_tex(layer, load("res://assets/props/caltrop.png"), Vector2(740, 460), 1.8)
            _add_decor_tex(layer, load("res://assets/props/life_pot.png"), Vector2(820, 270), 1.7)
        "L11":
            _add_decor_tex(layer, load("res://assets/props/dynamite_crate.png"), Vector2(610, 355), 2.0)
            _add_decor_tex(layer, load("res://assets/props/caltrop.png"), Vector2(825, 250), 1.8)
            _add_decor_tex(layer, load("res://assets/props/life_pot.png"), Vector2(775, 355), 1.7)
        "L12":
            _add_decor_tex(layer, load("res://assets/props/gourd.png"), Vector2(660, 165), 1.9)
            _add_decor_tex(layer, load("res://assets/props/dynamite_crate.png"), Vector2(425, 270), 2.0)
            _add_decor_tex(layer, load("res://assets/props/caltrop.png"), Vector2(720, 355), 1.9)
            _add_decor_tex(layer, load("res://assets/props/crane.png"), Vector2(795, 118), 2.2)

    # 任务目标道具：所有关卡终点统一放置卷轴，强化“护送目标”的视觉认知。
    if level_data != null and level_data.ninja_route != null and level_data.ninja_route.waypoints.size() > 0:
        var goal_pos: Vector2 = level_data.ninja_route.waypoints[level_data.ninja_route.waypoints.size() - 1]
        _add_decor_tex(layer, load("res://assets/props/scroll.png"), goal_pos + Vector2(0, -16), 1.8)

static func _add_decor(layer: Node2D, item: StringName, pos: Vector2, decor_scale: float, tint: Color) -> void:
    var tex := AtlasTexture.new()
    tex.atlas = load(NATURE_SHEET)
    tex.region = DECOR_REGIONS[item]
    _add_decor_tex(layer, tex, pos, decor_scale, tint)

static func _add_decor_tex(layer: Node2D, tex: Texture2D, pos: Vector2, decor_scale: float, tint: Color = Color.WHITE) -> void:
    var s := Sprite2D.new()
    s.texture = tex
    s.position = pos
    s.scale = Vector2(decor_scale, decor_scale)
    s.modulate = tint
    layer.add_child(s)
