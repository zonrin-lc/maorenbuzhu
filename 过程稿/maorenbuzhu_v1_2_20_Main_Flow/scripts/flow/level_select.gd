extends Control

@onready var app: AppFlow = $AppFlow
@onready var list: VBoxContainer = $Margin/VBox/List
@onready var title: Label = $Margin/VBox/Title

func _ready() -> void:
    title.text = app.level_catalog.chapter_names[str(GlobalFlowMemory.selected_chapter)]
    _build()

func _build() -> void:
    var start := (GlobalFlowMemory.selected_chapter - 1) * 4
    var finish := start + 4
    for i in range(start, finish):
        var level_id := app.level_catalog.level_ids[i]
        var b := Button.new()
        var save := app.save_data()
        var paws := int(save.best_paws.get("NORMAL:%s" % level_id, 0))
        b.text = "%s  ·  %s" % [level_id, app.level_catalog.level_names[level_id]]
        if paws > 0:
            b.text += "  ·  猫爪 %d" % paws
        b.disabled = not app.can_start(level_id)
        b.pressed.connect(_start.bind(level_id))
        list.add_child(b)

func _start(level_id: String) -> void:
    app.go_to_level(level_id)
