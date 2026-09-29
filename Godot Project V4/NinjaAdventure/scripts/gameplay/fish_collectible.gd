class_name FishCollectible
extends Node2D

# GDD §11.1 收集品「小鱼干」：每关 3 条、藏在只有猫能钻的洞（CatTunnel 出口）、
# 纯装饰成就，不影响通关、不参与 CarryPickup 的搬运玩法。
#
# 与 CarryPickup 的 FISH 是两件东西：
#   - CarryPickup FISH = 玩法资源（喂狗），可被搬运/消耗
#   - 本节点          = 永久收藏，拾取即写入 SaveManager.collect_fish 的 bitmask
#
# 此前 SaveManager.collect_fish 全项目无调用点，SaveData.fish_collected 恒为空，
# 主菜单「鱼」永远显示 0 —— 收藏系统只有存档字段、没有实体。这条把它接通。

const UI_FONT := preload("res://theme/ui_font.tres")
const TEX_PATH := "res://assets/props/fish.png"
const PICKUP_RADIUS := 46.0

var level_manager: UnifiedLevelManager
var level_id: StringName = &""
var fish_index := 0
var collected := false
var _sprite: Sprite2D

func setup(p_level_manager: UnifiedLevelManager, p_level_id: StringName, p_index: int) -> void:
    level_manager = p_level_manager
    level_id = p_level_id
    fish_index = p_index
    collected = _already_collected()
    _attach_sprite()
    queue_redraw()

func _already_collected() -> bool:
    var save := SaveManager.get_data()
    var mask := int(save.fish_collected.get(String(level_id), 0))
    return (mask & (1 << fish_index)) != 0

func _attach_sprite() -> void:
    var tex := load(TEX_PATH) as Texture2D
    if tex == null:
        return
    _sprite = Sprite2D.new()
    _sprite.texture = tex
    var s := 24.0 / maxf(tex.get_width(), tex.get_height())
    _sprite.scale = Vector2(s, s)
    add_child(_sprite)
    if collected:
        _sprite.modulate = Color(0.45, 0.45, 0.5, 0.5)

func _process(_delta: float) -> void:
    if collected or level_manager == null:
        return
    if level_manager.level_finished or level_manager.level_failed:
        return
    var cat := level_manager.cat
    if cat == null or cat.carry_item != &"":
        queue_redraw()
        return
    var near := global_position.distance_to(cat.global_position) <= PICKUP_RADIUS
    if near and Input.is_action_just_pressed("interact"):
        _collect()
    queue_redraw()

func _collect() -> void:
    if collected:
        return
    collected = true
    SaveManager.collect_fish(String(level_id), fish_index)
    level_manager.show_collected_fish(fish_index)
    GlobalAudioManager.play_event_sfx("pickup")
    if _sprite != null:
        var tw := create_tween()
        tw.tween_property(_sprite, "scale", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
        tw.parallel().tween_property(_sprite, "modulate:a", 0.0, 0.2)
        tw.tween_callback(queue_free)
    queue_redraw()

func _draw() -> void:
    var near := level_manager != null and level_manager.cat != null \
        and level_manager.cat.carry_item == &"" \
        and global_position.distance_to(level_manager.cat.global_position) <= PICKUP_RADIUS
    var ring := Color("#fbbf24") if near else Color("#94a3b8")
    if collected:
        ring = Color(0.45, 0.45, 0.5, 0.5)
    ring.a = 0.75 if near else 0.35
    draw_arc(Vector2.ZERO, 16.0, 0.0, TAU, 24, ring, 2.0)
    if not collected and near:
        draw_string(UI_FONT, Vector2(-42, -24), "E 收集小鱼干", HORIZONTAL_ALIGNMENT_CENTER, 84, 12, Color("#f8fafc"))
