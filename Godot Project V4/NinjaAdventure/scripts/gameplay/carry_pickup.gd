class_name CarryPickup
extends Area2D

signal picked_up(item_id: StringName)

@export var item_id: StringName = &"FISH"
@export var pickup_radius := 42.0
@export var pickup_hint := "Q 叼取"

var level_manager: UnifiedLevelManager
var collected := false
var sprite: Sprite2D

const TEXTURES := {
    &"FISH": "res://assets/props/fish.png",
    &"ANTIDOTE": "res://assets/props/life_pot.png",
}

func setup(item: StringName, manager: UnifiedLevelManager) -> void:
    item_id = item
    level_manager = manager
    _attach_sprite()
    queue_redraw()

func _attach_sprite() -> void:
    var path: String = TEXTURES.get(item_id, "")
    if path.is_empty():
        return
    var tex := load(path) as Texture2D
    if tex == null:
        return
    sprite = Sprite2D.new()
    sprite.name = "Prop"
    sprite.texture = tex
    var s := 28.0 / maxf(tex.get_width(), tex.get_height())
    sprite.scale = Vector2(s, s)
    add_child(sprite)

func _process(_delta: float) -> void:
    if collected or level_manager == null or level_manager.level_finished or level_manager.level_failed:
        return
    if level_manager.cat == null or level_manager.cat.carry_item != &"":
        return
    if global_position.distance_to(level_manager.cat.global_position) > pickup_radius:
        queue_redraw()
        return
    if Input.is_action_just_pressed("carry"):
        collected = true
        level_manager.cat.carry_item = item_id
        level_manager.call("_set_carry_visual", item_id)
        level_manager.event_log.append_event({
            "event_id": StringName("PICKUP_%s" % String(item_id)),
            "action": &"CARRY",
            "item": item_id,
            "success": true,
            "level_id": level_manager.level_data.level_id if level_manager.level_data else &"",
        })
        level_manager.call("_show_toast", "叼到%s：带到下一处需要它的地方。" % ("鱼肉" if item_id == &"FISH" else "解毒药"))
        picked_up.emit(item_id)
        if sprite != null:
            var tw := create_tween()
            tw.tween_property(sprite, "scale", Vector2.ZERO, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
            tw.tween_property(self, "modulate:a", 0.0, 0.12)
            tw.tween_callback(queue_free)
    queue_redraw()

func _draw() -> void:
    if collected:
        return
    var near := level_manager != null and level_manager.cat != null and global_position.distance_to(level_manager.cat.global_position) <= pickup_radius and level_manager.cat.carry_item == &""
    var ring := Color("#fbbf24") if near else Color("#94a3b8")
    ring.a = 0.75 if near else 0.4
    draw_arc(Vector2.ZERO, 18.0, 0.0, TAU, 24, ring, 2.0)
    if near:
        var font := ThemeDB.fallback_font
        draw_string(font, Vector2(-42, -26), pickup_hint, HORIZONTAL_ALIGNMENT_CENTER, 84, 12, Color("#f8fafc"))
