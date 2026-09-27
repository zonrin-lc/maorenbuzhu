class_name UnifiedEventPoint
extends Area2D

signal resolved(data: EventPointData, action_id: StringName)
signal failed(data: EventPointData, fail_code: StringName)

const PROP_TEXTURES := {
    &"TRIPWIRE": "res://assets/props/fish_net.png",
    &"WATERGAP": "res://assets/props/crate.png",
    &"STEAL_CRATE": "res://assets/props/crate.png",
    &"BRIDGE": "res://assets/props/crate.png",
    &"CLIFF": "res://assets/props/crate.png",
    &"DOG": "res://assets/props/fish.png",
    &"POISON": "res://assets/props/life_pot.png",
    &"CALTROP": "res://assets/props/caltrop.png",
    &"DYNAMITE": "res://assets/props/dynamite_crate.png",
    &"BOSS_CRANE": "res://assets/props/crane.png",
    &"BOSS_GOURD": "res://assets/props/gourd.png",
    &"BOSS_CALTROP": "res://assets/props/caltrop.png",
}

var data: EventPointData
var level_manager: UnifiedLevelManager
var resolved_state := false
var timer := 0.0
var interaction_progress := 0.0
var interacting := false
var prop_sprite: Sprite2D

func setup(event_data: EventPointData, manager: UnifiedLevelManager) -> void:
    data = event_data
    level_manager = manager
    _attach_prop()
    queue_redraw()

func _attach_prop() -> void:
    if not PROP_TEXTURES.has(data.event_type):
        return
    var tex: Texture2D = load(PROP_TEXTURES[data.event_type])
    if tex == null:
        return
    prop_sprite = Sprite2D.new()
    prop_sprite.name = "Prop"
    prop_sprite.texture = tex
    var s: float = 32.0 / maxf(tex.get_width(), tex.get_height())
    prop_sprite.scale = Vector2(s, s)
    add_child(prop_sprite)

func _process(delta: float) -> void:
    if data == null or level_manager == null or resolved_state:
        return
    if level_manager.level_finished or level_manager.level_failed:
        return
    if not level_manager.is_event_active(data):
        queue_redraw()
        return

    var cat := level_manager.cat
    var ninja := level_manager.ninja
    if cat == null or ninja == null:
        return

    if not data.non_blocking and data.event_group == &"MAIN":
        var ninja_in_range := global_position.distance_to(ninja.global_position) <= data.trigger_radius
        timer = timer + delta if ninja_in_range else 0.0
        if ninja_in_range and data.timeout > 0.0 and timer >= data.timeout:
            fail(data.fail_code)
            return

    var required := EventBehaviorRegistry.action_for(data)
    if required == &"MEOW":
        return # F is owned by CatController; manager resolves Guard events from the signal.

    if required == &"EMOTE_CHECK":
        return # Ctrl is owned by CatController; manager resolves the teaching checkpoint.

    if required == &"PASSIVE":
        if global_position.distance_to(ninja.global_position) <= data.trigger_radius:
            resolve(&"PASSIVE")
        return

    if global_position.distance_to(cat.global_position) > 58.0:
        if interacting:
            _cancel_action()
        queue_redraw()
        return

    var needs_carry := data.consume_carry_item != &"" and cat.carry_item != data.consume_carry_item and required in [&"FEED", &"PLACE_ANTIDOTE", &"PLACE_CRATE"]
    # L04 Route B 通过猫专用捷径后，E04 木桥不需要实际叼箱。
    if data.event_id == &"L04_E04_WATERGAP" and level_manager.world_state.get_flag(&"L04_SHORTCUT_USED"):
        needs_carry = false
    if needs_carry:
        queue_redraw()
        return

    if _action_pressed(required):
        if not interacting:
            interacting = true
            interaction_progress = 0.0
            level_manager.on_player_action_started(data, required)
        interaction_progress += delta
        if interaction_progress >= max(0.01, data.interaction_time):
            resolve(required)
    elif interacting:
        _cancel_action()
    queue_redraw()

func _action_pressed(action_id: StringName) -> bool:
    match action_id:
        &"FEED": return Input.is_action_pressed("interact") and level_manager.cat.carry_item == &"FISH"
        &"PLACE_ANTIDOTE": return Input.is_action_pressed("interact") and level_manager.cat.carry_item == &"ANTIDOTE"
        &"STEAL_CRATE": return Input.is_action_pressed("carry")
        &"SEND_DOG":
            var dog_ally := level_manager.world_state.get_flag(&"L06_DOG_ALLY") or level_manager.world_state.get_flag(&"L08_DOG_ALLY")
            return Input.is_action_pressed("interact") and dog_ally
        &"CALTROP_DURING_PHASE2": return Input.is_action_pressed("interact")
        _: return Input.is_action_pressed("interact")

func resolve(action_id: StringName) -> void:
    if resolved_state:
        return
    resolved_state = true
    interacting = false
    resolved.emit(data, action_id)
    _animate_resolved()
    queue_redraw()

func _animate_resolved() -> void:
    # 事件解决的世界反馈（§4 各威胁"成功演出"的白盒版）：让道具状态真实变化，不只是 flag
    if prop_sprite == null:
        return
    var tw := create_tween()
    match data.event_type:
        &"TRIPWIRE", &"CALTROP", &"BOSS_CALTROP", &"DOG":
            # 绳子断/蒺藜清走/鱼被吃掉：道具消失
            tw.set_parallel(true)
            tw.tween_property(prop_sprite, "scale", prop_sprite.scale * 0.2, 0.35)
            tw.tween_property(prop_sprite, "modulate:a", 0.0, 0.35)
        &"WATERGAP", &"BRIDGE", &"CLIFF":
            # 数据指定落位时，箱子真实移动到目标锚点；否则保留轻微弹跳。
            if data.resolved_offset != Vector2.ZERO:
                tw.tween_property(prop_sprite, "position", prop_sprite.position + data.resolved_offset, data.resolved_motion_time).set_trans(Tween.TRANS_SINE)
            else:
                tw.tween_property(prop_sprite, "position:y", prop_sprite.position.y + 6.0, 0.18)
                tw.tween_property(prop_sprite, "position:y", prop_sprite.position.y, 0.22).set_trans(Tween.TRANS_BOUNCE)
        &"POISON":
            # 药瓶放倒（被忍者捡走使用）
            tw.tween_property(prop_sprite, "rotation", PI * 0.5, 0.3)
            tw.parallel().tween_property(prop_sprite, "modulate:a", 0.35, 0.3)
        &"STEAL_CRATE":
            # 箱子被猫叼走：道具从世界中收起，由 LevelManager 挂到猫身上。
            tw.set_parallel(true)
            tw.tween_property(prop_sprite, "scale", Vector2.ZERO, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
            tw.tween_property(prop_sprite, "modulate:a", 0.0, 0.22)
        &"DYNAMITE":
            # 炸药桶推入水中受潮：滑走 + 变暗
            tw.set_parallel(true)
            tw.tween_property(prop_sprite, "position:x", prop_sprite.position.x + 40.0, 0.4)
            tw.tween_property(prop_sprite, "modulate", Color(0.5, 0.6, 0.7, 0.8), 0.4)
        &"BOSS_CRANE":
            # 吊车货箱砸落：快速下坠
            tw.tween_property(prop_sprite, "position:y", prop_sprite.position.y + 26.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
        &"BOSS_GOURD":
            # 酒葫芦下药：晃动两下
            tw.tween_property(prop_sprite, "rotation", 0.35, 0.12)
            tw.tween_property(prop_sprite, "rotation", -0.35, 0.12)
            tw.tween_property(prop_sprite, "rotation", 0.0, 0.12)

func fail(code: StringName) -> void:
    if resolved_state:
        return
    resolved_state = true
    interacting = false
    failed.emit(data, code)
    queue_redraw()

func _cancel_action() -> void:
    level_manager.on_player_action_cancelled(data)
    interacting = false
    interaction_progress = 0.0

func _draw() -> void:
    if data == null:
        return
    var active := level_manager != null and level_manager.is_event_active(data)
    if prop_sprite != null:
        if resolved_state:
            prop_sprite.modulate = Color(0.5, 1.0, 0.6)
        elif not active:
            prop_sprite.modulate = Color(0.55, 0.55, 0.6)
        else:
            prop_sprite.modulate = Color.WHITE
    else:
        # 无道具事件（守卫等，本体已有角色精灵）：柔和光环代替实心圆点
        var ring := Color("#22c55e") if resolved_state else (Color("#fbbf24") if active else Color("#64748b"))
        ring.a = 0.35 if active and not resolved_state else 0.2
        draw_arc(Vector2.ZERO, 14.0, 0.0, TAU, 32, ring, 2.5)
        if active and not resolved_state:
            draw_arc(Vector2.ZERO, 18.0, 0.0, TAU, 32, Color(ring.r, ring.g, ring.b, 0.12), 6.0)
    if active and not resolved_state:
        draw_circle(Vector2.ZERO, data.trigger_radius, Color(1, 1, 1, 0.07))
        draw_arc(Vector2.ZERO, data.trigger_radius, 0.0, TAU, 48, Color(1, 1, 1, 0.18), 1.5)
    var font := ThemeDB.fallback_font
    draw_string(font, Vector2(-64, -24), String(data.display_name), HORIZONTAL_ALIGNMENT_CENTER, 128, 14, Color("#f8fafc"))
    if interacting:
        draw_arc(Vector2.ZERO, 22.0, -PI * 0.5, -PI * 0.5 + TAU * clamp(interaction_progress / max(0.01, data.interaction_time), 0.0, 1.0), 24, Color("#fbbf24"), 4.0)
