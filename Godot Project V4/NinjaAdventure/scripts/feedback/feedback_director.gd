class_name FeedbackDirector
extends CanvasLayer

# v1.5.2 反馈层：只负责即时可读反馈，不改变玩法判定。
# 依赖现有 UI / Audio 资源；不新增外部素材。

var root: Control
var banner: Label
var sub_banner: Label
var event_badge: Label
var flash: ColorRect
var pulse: ColorRect
var paw_stamp: Label
var toast_tween: Tween
var stamp_tween: Tween

const EVENT_COPY := {
    "TRIPWIRE": "绊绳已处理",
    "GUARD": "守卫已引开",
    "DOG": "狗狗开始行动",
    "WATERGAP": "通路已打开",
    "BRIDGE": "桥已放下",
    "POISON": "毒雾已处理",
    "CALTROP": "蒺藜已清空",
    "DYNAMITE": "炸药已处理",
    "STEAL_CRATE": "箱子到手",
    "BOSS_CRANE": "吊车机关生效",
    "BOSS_GOURD": "酒葫芦机关生效",
    "BOSS_CALTROP": "Boss 冲锋被截断",
    "PASSIVE": "路线状态已更新",
}

func _ready() -> void:
    layer = 80
    root = Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(root)

    flash = ColorRect.new()
    flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    flash.color = Color(1, 1, 1, 0.0)
    flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.add_child(flash)

    pulse = ColorRect.new()
    pulse.position = Vector2(24, 108)
    pulse.size = Vector2(16, 160)
    pulse.color = Color(1.0, 0.75, 0.20, 0.0)
    pulse.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.add_child(pulse)

    banner = Label.new()
    banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    banner.position = Vector2(250, 112)
    banner.size = Vector2(780, 54)
    banner.add_theme_font_size_override("font_size", 26)
    banner.modulate = Color(1, 1, 1, 0)
    root.add_child(banner)

    sub_banner = Label.new()
    sub_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    sub_banner.position = Vector2(300, 160)
    sub_banner.size = Vector2(680, 40)
    sub_banner.add_theme_font_size_override("font_size", 16)
    sub_banner.modulate = Color(1, 1, 1, 0)
    root.add_child(sub_banner)

    event_badge = Label.new()
    event_badge.position = Vector2(42, 575)
    event_badge.size = Vector2(310, 42)
    event_badge.add_theme_font_size_override("font_size", 18)
    event_badge.modulate = Color(1, 1, 1, 0)
    root.add_child(event_badge)

    paw_stamp = Label.new()
    paw_stamp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    paw_stamp.position = Vector2(470, 240)
    paw_stamp.size = Vector2(340, 100)
    paw_stamp.add_theme_font_size_override("font_size", 48)
    paw_stamp.modulate = Color(1, 1, 1, 0)
    root.add_child(paw_stamp)

func show_event_resolved(event_type: StringName, display_name: String, action_id: StringName) -> void:
    var copy := EVENT_COPY.get(String(event_type), "处理成功")
    var action_copy := _action_copy(action_id)
    _show_banner(copy, "%s · %s" % [display_name, action_copy], false)
    _flash(Color(0.55, 1.0, 0.65, 0.14))
    _show_event_badge("✓ " + copy)

func show_event_failed(fail_code: StringName, display_name: String = "") -> void:
    var reason := _fail_copy(fail_code)
    _show_banner("差一点", "%s%s" % [display_name + " · " if not display_name.is_empty() else "", reason], true)
    _flash(Color(1.0, 0.28, 0.28, 0.16))
    _show_event_badge("! " + reason)

func show_ninja_damage(hp: int) -> void:
    _flash(Color(1.0, 0.18, 0.18, 0.18))
    _show_banner("忍者掉心了", "剩余 %d / 3" % hp, true)
    pulse.color = Color(1.0, 0.20, 0.20, 0.0)
    var tw := create_tween()
    tw.tween_property(pulse, "color:a", 0.42, 0.08)
    tw.tween_property(pulse, "color:a", 0.0, 0.28)

func show_cat_action(action_id: StringName) -> void:
    var label := _action_copy(action_id)
    if label.is_empty():
        return
    _show_event_badge("猫 · " + label)

func show_shortcut() -> void:
    _show_banner("捷径成功", "猫先到了。", false)
    _flash(Color(0.45, 0.85, 1.0, 0.10))

func show_suspicion(value: float) -> void:
    if value < 25.0:
        return
    var text := "有点可疑"
    if value >= 80.0:
        text = "非常可疑！"
    elif value >= 50.0:
        text = "他开始怀疑了"
    _show_event_badge("👁 " + text + "  %.0f" % value)

func show_route_change(route_name: String) -> void:
    _show_banner("路线改变", route_name, false)
    _flash(Color(0.45, 0.75, 1.0, 0.10))

func show_boss_phase(phase: int) -> void:
    _show_banner("Boss Phase %d" % phase, "节奏切换", true if phase >= 3 else false)
    _flash(Color(0.90, 0.40, 0.85, 0.12) if phase >= 2 else Color(1, 0.80, 0.30, 0.10))

func show_paw_reveal(paws: int) -> void:
    paw_stamp.text = "🐾".repeat(clampi(paws, 0, 3))
    if stamp_tween != null and stamp_tween.is_running():
        stamp_tween.kill()
    paw_stamp.scale = Vector2(0.7, 0.7)
    paw_stamp.modulate = Color(1, 1, 1, 0)
    stamp_tween = create_tween()
    stamp_tween.tween_property(paw_stamp, "modulate:a", 1.0, 0.12)
    stamp_tween.tween_property(paw_stamp, "scale", Vector2.ONE, 0.26).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    stamp_tween.tween_interval(0.7)
    stamp_tween.tween_property(paw_stamp, "modulate:a", 0.0, 0.22)

func _show_banner(title: String, subtitle: String, danger: bool) -> void:
    if toast_tween != null and toast_tween.is_running():
        toast_tween.kill()
    banner.text = title
    sub_banner.text = subtitle
    banner.modulate = Color(1, 0.82, 0.35, 1.0) if not danger else Color(1, 0.45, 0.45, 1.0)
    sub_banner.modulate = Color(1, 1, 1, 0.95)
    banner.position.y = 104
    sub_banner.position.y = 152
    toast_tween = create_tween()
    toast_tween.tween_property(banner, "position:y", 112.0, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    toast_tween.parallel().tween_property(sub_banner, "position:y", 160.0, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    toast_tween.tween_interval(0.85)
    toast_tween.tween_property(banner, "modulate:a", 0.0, 0.20)
    toast_tween.parallel().tween_property(sub_banner, "modulate:a", 0.0, 0.20)

func _show_event_badge(text: String) -> void:
    event_badge.text = text
    event_badge.modulate = Color(1, 1, 1, 0)
    event_badge.position.x = 32
    var tw := create_tween()
    tw.tween_property(event_badge, "modulate:a", 1.0, 0.08)
    tw.tween_property(event_badge, "position:x", 42.0, 0.16).set_trans(Tween.TRANS_SINE)
    tw.tween_interval(1.1)
    tw.tween_property(event_badge, "modulate:a", 0.0, 0.25)

func _flash(color: Color) -> void:
    flash.color = color
    var tw := create_tween()
    tw.tween_property(flash, "color:a", 0.0, 0.26).set_trans(Tween.TRANS_SINE)

func _action_copy(action_id: StringName) -> String:
    match action_id:
        &"MEOW": return "喵叫"
        &"EMOTE": return "卖萌"
        &"STEAL_CRATE": return "叼走箱子"
        &"FEED": return "喂狗"
        &"PLACE_ANTIDOTE": return "放下解毒药"
        &"SEND_DOG": return "派狗出动"
        &"DOG_ASSIST": return "狗狗协同"
        &"CALTROP_DURING_PHASE2": return "战中布置蒺藜"
        &"PASSIVE": return "被动触发"
        &"INTERACT": return "互动"
        _: return String(action_id)

func _fail_copy(fail_code: StringName) -> String:
    match fail_code:
        &"FAIL_TIMEOUT": return "窗口错过了"
        &"FAIL_TOO_LATE": return "来不及处理"
        &"FAIL_WRONG_ORDER": return "顺序改变了后面的路线"
        &"FAIL_NINJA_DEATH": return "忍者已经撑不住了"
        &"FAIL_SUSPICION": return "他发现这猫不太对劲"
        _: return "忍者受伤了"
