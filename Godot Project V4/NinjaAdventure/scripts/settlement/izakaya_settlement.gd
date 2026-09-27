class_name IzakayaSettlement
extends Node2D

# 居酒屋结算演出（GDD §7）：忍者吹牛 + 猫舔爪 + 猫爪揭示 + 固定吐槽
# 数据来自 SettlementContext（一次性 pending_result）

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
var _locked_input_timer := 1.0

@onready var _status: Label = $UI/Status
@onready var _boast: Label = $UI/Boast
@onready var _cat_label: Label = $UI/CatLabel
@onready var _paws: Label = $UI/Paws
@onready var _hint: Label = $UI/Hint

func _ready() -> void:
    GlobalAudioManager.set_music_state("BOSS_DEFEAT")
    if not SettlementContext.has_pending():
        get_tree().call_deferred("change_scene_to_file", "res://scenes/flow/main_menu.tscn")
        return
    _build_banter()
    _status.text = "%s · 任务完成" % String(SettlementContext.result.get("level_id", ""))
    _boast.text = ""
    _paws.text = ""
    _cat_label.text = ""
    _hint.text = ""
    var timeline := create_tween()
    timeline.tween_interval(0.8)
    timeline.tween_callback(func(): _boast.text = "忍者：“%s”" % _banter_text)
    timeline.tween_interval(1.0)
    timeline.tween_callback(func(): _cat_label.text = "猫：%s" % _cat_response)
    timeline.tween_interval(0.8)
    timeline.tween_callback(_reveal_paws)

func _build_banter() -> void:
    var gen := BoastGenerator.new()
    var tags: Dictionary = gen.build_tags(SettlementContext.event_log)
    var importance: String = gen.classify_importance(tags)
    # 数据驱动选句：banter tres 池（required_tags ⊆ 本局 tags，level_scope 匹配）
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
    var detail := "用时 %.1fs ｜ 最高怀疑 %d" % [float(SettlementContext.result.get("elapsed_time", 0.0)), int(SettlementContext.result.get("max_suspicion", 0))]
    _paws.text = "猫爪 %s\n%s\n他信了。他们又都信了。" % [stars, detail]
    var unlocked: Array = SettlementContext.result.get("unlocked_talents", [])
    if not unlocked.is_empty():
        _paws.text += "\n新猫技艺：%s" % "、".join(unlocked)
    if SettlementContext.result.get("emergency", false):
        _paws.text += "\n（应急救场：固定 1 爪）"
    _hint.text = "Enter：下一关    R：重玩本关    Esc：主菜单"
    GlobalAudioManager.play_event_sfx("success")

func _process(delta: float) -> void:
    _locked_input_timer = max(0.0, _locked_input_timer - delta)

func _unhandled_input(_event: InputEvent) -> void:
    if _locked_input_timer > 0.0 or not SettlementContext.has_pending():
        return
    if Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("jump"):
        var next := SettlementContext.next_scene_path
        SettlementContext.clear()
        if not next.is_empty():
            get_tree().change_scene_to_file(next)
        else:
            get_tree().change_scene_to_file("res://scenes/flow/main_menu.tscn")
    elif Input.is_action_just_pressed("retry"):
        var current := SettlementContext.current_scene_path
        SettlementContext.clear()
        get_tree().change_scene_to_file(current)
    elif Input.is_action_just_pressed("cancel"):
        SettlementContext.clear()
        get_tree().change_scene_to_file("res://scenes/flow/main_menu.tscn")
