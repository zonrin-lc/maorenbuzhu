extends Control

@onready var app: AppFlow = $AppFlow
@onready var list: VBoxContainer = $Margin/VBox/List
@onready var title: Label = $Margin/VBox/Title

# 场景切换防抖：双击会在延迟 flush 前触发两次 change_scene_to_file。
var _navigating := false

func _ready() -> void:
    title.text = app.level_catalog.chapter_names.get(str(GlobalFlowMemory.selected_chapter), "章节")
    _build()

# 此前没有返回出口：章节选择 -> 关卡选择是单向的，只能靠重开关卡退出。
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("cancel") or event.is_action_pressed("pause"):
        get_viewport().set_input_as_handled()
        _navigate(AppFlow.CHAPTER_SELECT)

func _build() -> void:
    var save := app.save_data()
    var difficulty := "HARD" if save.hard_mode_enabled else "NORMAL"
    if save.hard_mode_unlocked:
        var hard := CheckButton.new()
        hard.text = "困难模式"
        hard.button_pressed = save.hard_mode_enabled
        hard.toggled.connect(_on_hard_mode_toggled)
        list.add_child(hard)
    # GlobalFlowMemory.selected_chapter 是跨场景 static 且无运行时校验，
    # 越界会直接数组越界崩溃 —— 这里夹取到合法范围。
    var ids: Array = app.level_catalog.level_ids
    var per_chapter := 4
    var chapters := ceili(float(ids.size()) / float(per_chapter))
    var chapter := clampi(GlobalFlowMemory.selected_chapter, 1, maxi(chapters, 1))
    var start := (chapter - 1) * per_chapter
    var finish := mini(start + per_chapter, ids.size())
    for i in range(start, finish):
        var level_id: String = ids[i]
        var row := HBoxContainer.new()
        list.add_child(row)
        var b := Button.new()
        # 之前硬编码读 "NORMAL:"，导致困难模式成绩被显示成普通模式成绩（且会互相覆盖）。
        var paws := int(save.best_paws.get("%s:%s" % [difficulty, level_id], 0))
        b.text = "%s  ·  %s" % [level_id, app.level_catalog.level_names.get(level_id, level_id)]
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

func _navigate(path: String) -> void:
    if _navigating:
        return
    _navigating = true
    get_tree().change_scene_to_file(path)

func _on_hard_mode_toggled(pressed: bool) -> void:
    app.save_data().hard_mode_enabled = pressed
    app.save_manager.save_game()

func _on_variant_toggled(pressed: bool, level_id: String) -> void:
    GlobalFlowMemory.variant_b_selected[level_id] = pressed

func _start(level_id: String) -> void:
    if not app.can_start(level_id):
        return
    _navigate(app.level_catalog.scene_path(level_id))
