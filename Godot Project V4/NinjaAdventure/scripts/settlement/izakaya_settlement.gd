class_name IzakayaSettlement
extends Node2D

# v1.5.5 居酒屋结算：忍者吹牛 + 猫吐槽 + 猫爪揭示 + 统一视觉演出
const FALLBACK_BANTER := {
    "EMERGENCY": "最后那一下？我故意留给敌人的。",
    "NEAR_DEATH": "那点伤？连我的披风都没碰到。",
    "BOSS": "那武士见我就跪了，大概是被我的气势震的。",
    "CHAIN": "一路顺风？那是当然，全在我的计算之中。",
    "ROUTE_CHANGE": "突然换条路走，这叫忍者的直觉。",
    "STANDARD_SUCCESS": "这种程度也想拦我？",
}

var _step := 0
var _banter_text := ""
var _cat_response := "……"
var _locked_input_timer := 1.2

@onready var _status: Label = $UI/Header/HBox/Status
@onready var _level_title: Label = $UI/Header/HBox/LevelTitle
@onready var _boast: Label = $UI/CenterCard/Boast
@onready var _cat_label: Label = $UI/CenterCard/CatLabel
@onready var _paws: Label = $UI/ResultCard/Paws
@onready var _hint: Label = $UI/Bottom/VBox/Hint
@onready var _ninja: Sprite2D = $Characters/Ninja
@onready var _cat: Sprite2D = $Characters/Cat
@onready var _boast_panel: Panel = $UI/CenterCard
@onready var _result_card: Panel = $UI/ResultCard
@onready var _button_row: HBoxContainer = $UI/Bottom/VBox/ButtonRow
@onready var _next_button: Button = $UI/Bottom/VBox/ButtonRow/Next
@onready var _retry_button: Button = $UI/Bottom/VBox/ButtonRow/Retry
@onready var _menu_button: Button = $UI/Bottom/VBox/ButtonRow/Menu

func _ready() -> void:
    GlobalAudioManager.set_music_state("SETTLEMENT")
    if not SettlementContext.has_pending():
        get_tree().call_deferred("change_scene_to_file", "res://scenes/flow/main_menu.tscn")
        return
    _build_banter()
    _next_button.pressed.connect(_on_next_pressed)
    _retry_button.pressed.connect(_on_retry_pressed)
    _menu_button.pressed.connect(_on_menu_pressed)
    var input_manager := get_node_or_null("/root/GameInputManager")
    if input_manager != null and not input_manager.device_changed.is_connected(_on_device_changed):
        input_manager.device_changed.connect(_on_device_changed)
    _refresh_input_affordances()
    _status.text = "任务完成"
    _level_title.text = "%s  ·  %s" % [String(SettlementContext.result.get("level_id", "L01")), _level_name(String(SettlementContext.result.get("level_id", "L01")))]
    _boast.text = ""
    _paws.text = ""
    _cat_label.text = ""
    _hint.text = ""
    _next_button.disabled = true
    _retry_button.disabled = true
    _menu_button.disabled = true
    _next_button.modulate = Color(1, 1, 1, 0.55)
    _retry_button.modulate = Color(1, 1, 1, 0.55)
    _menu_button.modulate = Color(1, 1, 1, 0.55)

    _boast_panel.modulate = Color(1, 1, 1, 0)
    _result_card.modulate = Color(1, 1, 1, 0)
    _ninja.modulate = Color(1, 1, 1, 0)
    _cat.modulate = Color(1, 1, 1, 0)

    var timeline := create_tween()
    timeline.set_parallel(true)
    timeline.tween_property(_ninja, "modulate", Color.WHITE, 0.45)
    timeline.tween_property(_ninja, "position", Vector2(480, 392), 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    timeline.chain().set_parallel(false)
    timeline.tween_interval(0.55)
    timeline.tween_callback(func(): _boast.text = "“%s”" % _banter_text)
    timeline.parallel().tween_property(_boast_panel, "modulate", Color.WHITE, 0.35)
    timeline.chain().tween_interval(0.9)
    timeline.tween_callback(func(): _cat.modulate = Color.WHITE)
    timeline.parallel().tween_property(_cat, "position", Vector2(815, 455), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    timeline.tween_interval(0.35)
    timeline.tween_callback(func(): _cat_label.text = _cat_response)
    timeline.tween_interval(0.55)
    timeline.tween_callback(_reveal_paws)
    timeline.parallel().tween_property(_result_card, "modulate", Color.WHITE, 0.45)
    timeline.tween_interval(0.35)
    timeline.tween_callback(_enable_buttons)

func _enable_buttons() -> void:
    _next_button.disabled = false
    _retry_button.disabled = false
    _menu_button.disabled = false
    _next_button.modulate = Color.WHITE
    _retry_button.modulate = Color.WHITE
    _menu_button.modulate = Color.WHITE

func _level_name(level_id: String) -> String:
    var names := {
        "L01":"第一份差事", "L02":"他总是踩同一个坑", "L03":"谁在看猫", "L04":"村口大事故",
        "L05":"月夜码头", "L06":"狗也能当队友", "L07":"谁先走", "L08":"最后一班船",
        "L09":"雷雨夜", "L10":"炸药不能乱碰", "L11":"越靠近城门越忙", "L12":"守门武士"
    }
    return names.get(level_id, level_id)

func _build_banter() -> void:
    var gen := BoastGenerator.new()
    var tags: Dictionary = gen.build_tags(SettlementContext.event_log)
    var importance: String = gen.classify_importance(tags)
    var level_id := String(SettlementContext.result.get("level_id", ""))
    var best: BanterData = null
    var dir := DirAccess.open("res://data/banter")
    if dir != null:
        for f in dir.get_files():
            if not f.ends_with(".tres"):
                continue
            var b := load("res://data/banter/" + f) as BanterData
            if b == null:
                continue
            if not b.level_scope.is_empty() and not b.level_scope.has(level_id):
                continue
            var ok := true
            for t in b.required_tags:
                if not tags.get(t, false):
                    ok = false
                    break
            for t in b.forbidden_tags:
                if tags.get(t, false):
                    ok = false
                    break
            if not ok:
                continue
            if best == null or _priority_rank(b.priority) < _priority_rank(best.priority):
                best = b
    if best != null:
        _banter_text = best.text_template
        _cat_response = best.cat_response if not best.cat_response.is_empty() else "……"
    else:
        _banter_text = FALLBACK_BANTER.get(importance, FALLBACK_BANTER["STANDARD_SUCCESS"])
        _cat_response = "……"

func _priority_rank(priority: String) -> int:
    var order := ["EMERGENCY", "NEAR_DEATH", "BOSS", "CHAIN", "ROUTE_CHANGE", "STANDARD_SUCCESS"]
    var i := order.find(priority)
    return i if i >= 0 else 99

func _reveal_paws() -> void:
    var paws := int(SettlementContext.result.get("paws", 1))
    var stars := ""
    for i in 3:
        stars += "★" if i < paws else "☆"
    var elapsed := float(SettlementContext.result.get("elapsed_time", 0.0))
    var target_time := float(SettlementContext.result.get("target_time", 0.0))
    var time_status := "三星线内" if target_time <= 0.0 or elapsed <= target_time else "超过三星线"
    var detail := "用时 %.1fs   ·   三星 %.0fs   ·   最高怀疑 %d" % [elapsed, target_time, int(SettlementContext.result.get("max_suspicion", 0))]
    _paws.text = "%s\n%s\n%s" % [stars, detail, time_status]
    var unlocked: Array = SettlementContext.result.get("unlocked_talents", [])
    if not unlocked.is_empty():
        _paws.text += "\n新猫技艺：%s" % "、".join(unlocked)
    if SettlementContext.result.get("emergency", false):
        _paws.text += "\n应急救场 · 本局固定 1 爪"
    _step = 1
    _refresh_input_affordances()
    GlobalAudioManager.play_event_sfx("success")

func _process(delta: float) -> void:
    _locked_input_timer = max(0.0, _locked_input_timer - delta)

func _on_device_changed(_device: String) -> void:
    _refresh_input_affordances()

func _refresh_input_affordances() -> void:
    var input_manager := get_node_or_null("/root/GameInputManager")
    var device: String = input_manager.last_device if input_manager != null else GameInputManager.DEVICE_KEYBOARD_MOUSE
    _button_row.visible = device == GameInputManager.DEVICE_TOUCH
    if _step < 1:
        return
    if device == GameInputManager.DEVICE_TOUCH:
        _hint.text = "点按下方按钮继续"
    elif device == GameInputManager.DEVICE_GAMEPAD:
        _hint.text = "%s  下一关      %s  重玩本关      %s  主菜单" % [
            InputDisplay.get_device_binding_label(&"confirm", device),
            InputDisplay.get_device_binding_label(&"retry", device),
            InputDisplay.get_device_binding_label(&"cancel", device),
        ]
    else:
        _hint.text = "Enter  下一关      R  重玩本关      Esc  主菜单"

func _on_next_pressed() -> void:
    if not SettlementContext.has_pending():
        return
    _go_next()

func _on_retry_pressed() -> void:
    if not SettlementContext.has_pending():
        return
    _retry_level()

func _on_menu_pressed() -> void:
    if not SettlementContext.has_pending():
        return
    _go_menu()

func _go_next() -> void:
    var next := SettlementContext.next_scene_path
    SettlementContext.clear()
    if not next.is_empty():
        get_tree().change_scene_to_file(next)
    else:
        get_tree().change_scene_to_file("res://scenes/flow/main_menu.tscn")

func _retry_level() -> void:
    var current := SettlementContext.current_scene_path
    SettlementContext.clear()
    get_tree().change_scene_to_file(current)

func _go_menu() -> void:
    SettlementContext.clear()
    get_tree().change_scene_to_file("res://scenes/flow/main_menu.tscn")

func _unhandled_input(_event: InputEvent) -> void:
    if _locked_input_timer > 0.0 or not SettlementContext.has_pending():
        return
    if Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("jump"):
        _go_next()
    elif Input.is_action_just_pressed("retry"):
        _retry_level()
    elif Input.is_action_just_pressed("cancel"):
        _go_menu()
