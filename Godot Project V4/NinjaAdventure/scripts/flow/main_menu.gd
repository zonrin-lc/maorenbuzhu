extends Control

@onready var app: AppFlow = $AppFlow
@onready var continue_button: Button = $Margin/VBox/Continue
@onready var status: Label = $Margin/VBox/Status

func _ready() -> void:
    var save := app.save_data()
    continue_button.text = "继续游戏 · %s" % app.continue_level()
    status.text = "进度：%d / 12 关" % save.completed_levels.size()
    continue_button.pressed.connect(_on_continue)
    $Margin/VBox/Chapters.pressed.connect(_on_chapters)
    $Margin/VBox/Settings.pressed.connect(_on_settings)

func _on_continue() -> void:
    app.go_to_level(app.continue_level())

func _on_chapters() -> void:
    get_tree().change_scene_to_file(AppFlow.CHAPTER_SELECT)

func _on_settings() -> void:
    get_tree().change_scene_to_file("res://scenes/flow/settings_menu.tscn")
