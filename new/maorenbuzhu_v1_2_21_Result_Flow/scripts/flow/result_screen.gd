extends Control

@onready var app: AppFlow = $AppFlow
@onready var level_label: Label = $Margin/VBox/Level
@onready var paws_label: Label = $Margin/VBox/Paws
@onready var stats_label: Label = $Margin/VBox/Stats
@onready var status_label: Label = $Margin/VBox/Status
@onready var retry_button: Button = $Margin/VBox/Buttons/Retry
@onready var next_button: Button = $Margin/VBox/Buttons/Next
@onready var level_select_button: Button = $Margin/VBox/Buttons/LevelSelect
@onready var menu_button: Button = $Margin/VBox/Buttons/Menu

func _ready() -> void:
    var r := app.result_flow.consume_result()
    if r.is_empty():
        status_label.text = "没有可显示的本次结算。"
        retry_button.disabled = true
        next_button.disabled = true
        return
    var level_id := str(r.get("level_id", "L01"))
    var paws := int(r.get("paws", 0))
    var time_ms := int(r.get("time_ms", 0))
    var suspicion := int(r.get("max_suspicion", 0))
    var difficulty := str(r.get("difficulty", "NORMAL"))
    level_label.text = "%s · %s" % [level_id, app.level_catalog.level_names.get(level_id, level_id)]
    paws_label.text = "猫爪  %d / 3" % paws
    stats_label.text = "时间 %.1fs   ·   最高怀疑 %d   ·   %s" % [time_ms / 1000.0, suspicion, difficulty]
    var next := app.next_level(level_id)
    next_button.text = "下一关 · %s" % next if not next.is_empty() else "章节完成"
    next_button.disabled = next.is_empty() or not app.can_start(next)
    retry_button.pressed.connect(func(): _retry(level_id))
    next_button.pressed.connect(func(): _next(level_id))
    level_select_button.pressed.connect(func(): get_tree().change_scene_to_file(AppFlow.LEVEL_SELECT))
    menu_button.pressed.connect(func(): get_tree().change_scene_to_file(AppFlow.MAIN_MENU))
    if next.is_empty():
        status_label.text = "全部主线完成。"
    elif app.can_start(next):
        status_label.text = "下一关已解锁。"
    else:
        status_label.text = "下一关尚未解锁。"

func _retry(level_id: String) -> void:
    app.result_flow.pending_result = {"level_id": level_id}
    app.go_to_level(level_id)

func _next(level_id: String) -> void:
    var next := app.next_level(level_id)
    if next.is_empty():
        GlobalFlowMemory.selected_chapter = app.level_catalog.chapter_for_level(level_id)
        get_tree().change_scene_to_file(AppFlow.CHAPTER_SELECT)
        return
    if app.can_start(next):
        app.go_to_level(next)
    else:
        GlobalFlowMemory.selected_chapter = app.level_catalog.chapter_for_level(next)
        get_tree().change_scene_to_file(AppFlow.LEVEL_SELECT)
