extends Control

@onready var app: AppFlow = $AppFlow
@onready var list: VBoxContainer = $Margin/VBox/List
@onready var title: Label = $Margin/VBox/Title

func _ready() -> void:
    title.text = app.level_catalog.chapter_names[str(GlobalFlowMemory.selected_chapter)]
    _build()

func _build() -> void:
    var save := app.save_data()
    if save.hard_mode_unlocked:
        var hard := CheckButton.new()
        hard.text = "困难模式"
        hard.button_pressed = save.hard_mode_enabled
        hard.toggled.connect(_on_hard_mode_toggled)
        list.add_child(hard)
    var start := (GlobalFlowMemory.selected_chapter - 1) * 4
    var finish := start + 4
    for i in range(start, finish):
        var level_id := app.level_catalog.level_ids[i]
        var row := HBoxContainer.new()
        list.add_child(row)
        var b := Button.new()
        var paws := int(save.best_paws.get("NORMAL:%s" % level_id, 0))
        b.text = "%s  ·  %s" % [level_id, app.level_catalog.level_names[level_id]]
        if paws > 0:
            b.text += "  ·  猫爪 %d" % paws
        b.disabled = not app.can_start(level_id)
        b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        b.pressed.connect(_start.bind(level_id))
        row.add_child(b)
        var variant_path := "res://data/variants/%s_variant_b.tres" % level_id.to_lower()
        if save.completed_levels.has(level_id) and ResourceLoader.exists(variant_path):
            var vb := CheckButton.new()
            vb.text = "B"
            vb.button_pressed = bool(GlobalFlowMemory.variant_b_selected.get(level_id, false))
            vb.disabled = b.disabled
            vb.toggled.connect(_on_variant_toggled.bind(level_id))
            row.add_child(vb)

func _on_hard_mode_toggled(pressed: bool) -> void:
    app.save_data().hard_mode_enabled = pressed
    app.save_manager.save_game()

func _on_variant_toggled(pressed: bool, level_id: String) -> void:
    GlobalFlowMemory.variant_b_selected[level_id] = pressed

func _start(level_id: String) -> void:
    app.go_to_level(level_id)
