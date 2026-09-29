extends Control

@onready var app: AppFlow = $AppFlow
@onready var continue_button: Button = $Margin/VBox/Continue
@onready var status: Label = $Margin/VBox/ProgressPanel/Status

func _ready() -> void:
    # 结算音乐会漏到主菜单（结算页切回菜单时没人重置音乐状态）。
    GlobalAudioManager.stop_music()
    var save := app.save_data()
    continue_button.text = "继续游戏 · %s" % app.continue_level()
    var paws_total := app.progress_manager.paws_total(save)
    var fish_total := app.progress_manager.fish_total(save)
    status.text = "进度：%d / 12 关  ·  猫爪 %d / 36  ·  鱼干 %d" % [save.completed_levels.size(), paws_total, fish_total]
    continue_button.pressed.connect(_on_continue)
    $Margin/VBox/Chapters.pressed.connect(_on_chapters)
    $Margin/VBox/Settings.pressed.connect(_on_settings)

func _on_continue() -> void:
    app.go_to_level(app.continue_level())

func _on_chapters() -> void:
    get_tree().change_scene_to_file(AppFlow.CHAPTER_SELECT)

func _on_settings() -> void:
    get_tree().change_scene_to_file("res://scenes/flow/settings_menu.tscn")
