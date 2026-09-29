extends Control

@onready var app: AppFlow = $AppFlow
@onready var list: VBoxContainer = $Margin/VBox/List
@onready var detail: Label = $Margin/VBox/Detail

var _navigating := false

func _ready() -> void:
    GlobalAudioManager.stop_music()
    _build()

# 此前没有返回出口：章节选择 -> 关卡选择单向，必须重开关卡才能回主菜单。
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("cancel") or event.is_action_pressed("pause"):
        get_viewport().set_input_as_handled()
        if not _navigating:
            _navigating = true
            get_tree().change_scene_to_file(AppFlow.MAIN_MENU)

func _build() -> void:
    for i in range(1, 4):
        var b := Button.new()
        b.text = app.level_catalog.chapter_names.get(str(i), "第 %d 章" % i)
        b.disabled = not app.chapter_unlocked(i)
        b.pressed.connect(_open.bind(i))
        list.add_child(b)

func _open(chapter: int) -> void:
    if _navigating:
        return
    _navigating = true
    GlobalFlowMemory.selected_chapter = chapter
    get_tree().change_scene_to_file(AppFlow.LEVEL_SELECT)
