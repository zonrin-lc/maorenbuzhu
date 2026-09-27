extends Control

@onready var app: AppFlow = $AppFlow
@onready var list: VBoxContainer = $Margin/VBox/List
@onready var detail: Label = $Margin/VBox/Detail

func _ready() -> void:
    _build()

func _build() -> void:
    for i in range(1, 4):
        var b := Button.new()
        b.text = app.level_catalog.chapter_names[str(i)]
        b.disabled = not app.chapter_unlocked(i)
        b.pressed.connect(_open.bind(i))
        list.add_child(b)

func _open(chapter: int) -> void:
    GlobalFlowMemory.selected_chapter = chapter
    get_tree().change_scene_to_file(AppFlow.LEVEL_SELECT)
