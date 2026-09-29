extends Control

const REBIND_PANEL_SCENE := preload("res://scenes/ui/rebind_panel.tscn")
const MAIN_MENU := "res://scenes/flow/main_menu.tscn"

@onready var settings_manager: Node = get_node_or_null("/root/SettingsManager")
@onready var save_manager: Node = get_node_or_null("/root/SaveManager")
@onready var content: VBoxContainer = $Panel/Content

var _rebind_layer: CanvasLayer = null
var _confirming_reset := false

# 分类按钮 -> 设置字段。[字段名, 控件类型, 显示名]
# 只暴露「真正有消费者」的字段：音量/静音/全屏/垂直同步都在 apply_all() 里有实际效果。
# Accessibility 的 reduce_* / large_ui 等目前没有任何 gameplay 消费者，因此不列为可勾选项，
# 避免制造「改了却没反应」的假设置（这正是本次修复要根除的问题）。
const CATEGORIES := {
	"Audio": [
		["master_volume", "slider", "主音量"],
		["music_volume", "slider", "音乐"],
		["sfx_volume", "slider", "音效"],
		["voice_volume", "slider", "语音"],
		["ui_volume", "slider", "界面"],
		["ambient_volume", "slider", "环境"],
		["mute_all", "check", "全部静音"],
	],
	"Display": [
		["fullscreen", "check", "全屏"],
		["vsync", "check", "垂直同步"],
	],
}

func _ready() -> void:
	if settings_manager == null:
		push_warning("SettingsMenu: SettingsManager autoload not found; UI remains present for scene preview.")
	$Panel/Close.pressed.connect(_on_close_pressed)
	$Panel/ResetSettings.pressed.connect(_on_reset_settings_pressed)
	$Panel/Categories/Input.pressed.connect(_on_input_category_pressed)
	$Panel/Categories/Audio.pressed.connect(_show_category.bind("Audio"))
	$Panel/Categories/Display.pressed.connect(_show_category.bind("Display"))
	$Panel/Categories/Accessibility.pressed.connect(_show_category.bind("Accessibility"))
	$Panel/Categories/Data.pressed.connect(_show_category.bind("Data"))
	_clear_content()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel") or event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		_on_close_pressed()

func _on_close_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)

func _on_reset_settings_pressed() -> void:
	if settings_manager:
		settings_manager.restore_defaults()
	_clear_content()

func _on_input_category_pressed() -> void:
	if _rebind_layer != null:
		return
	_rebind_layer = CanvasLayer.new()
	_rebind_layer.name = "RebindLayer"
	_rebind_layer.layer = 80
	_rebind_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_rebind_layer)
	var panel := REBIND_PANEL_SCENE.instantiate()
	_rebind_layer.add_child(panel)
	panel.tree_exited.connect(_on_rebind_panel_closed)

func _on_rebind_panel_closed() -> void:
	if _rebind_layer != null:
		_rebind_layer.queue_free()
		_rebind_layer = null

func _clear_content() -> void:
	# queue_free 是帧末才生效：若只 queue_free 就立刻 add_child，新旧控件会共存一帧，
	# 且 get_children() 仍能看到旧节点。先 remove_child 立即摘除再释放。
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()

func _show_category(category: String) -> void:
	_clear_content()
	_confirming_reset = false
	match category:
		"Accessibility":
			_add_note("辅助功能（减少闪烁 / 减少画面震动 / 大字号 / 高对比度）尚无 gameplay 消费者，暂不提供可勾选项——避免出现「改了却没反应」的假设置。")
		"Data":
			_add_note("存档与鱼获数据。")
			var reset := Button.new()
			reset.text = "清除全部进度"
			reset.pressed.connect(_on_reset_progress_pressed.bind(reset))
			content.add_child(reset)
		_:
			for field in CATEGORIES.get(category, []):
				_add_control(category, field[0], field[1], field[2])

func _add_control(_category: String, field_name: String, kind: String, label_text: String) -> void:
	if settings_manager == null:
		return
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var name_label := Label.new()
	name_label.text = label_text
	name_label.custom_minimum_size = Vector2(120, 0)
	row.add_child(name_label)
	if kind == "slider":
		var slider := HSlider.new()
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.01
		slider.value = float(settings_manager.data.get(field_name))
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		# 拖动中不落盘，松开时才写 cfg，避免每帧写盘。
		slider.value_changed.connect(func(v: float) -> void: settings_manager.set_option(field_name, v, false))
		slider.drag_ended.connect(func(_changed: bool) -> void: settings_manager.save_settings())
		row.add_child(slider)
	else:
		var check := CheckButton.new()
		check.button_pressed = bool(settings_manager.data.get(field_name))
		check.toggled.connect(func(v: bool) -> void: settings_manager.set_option(field_name, v))
		row.add_child(check)
	content.add_child(row)

func _add_note(text: String) -> void:
	var note := Label.new()
	note.text = text
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(note)

func _on_reset_progress_pressed(button: Button) -> void:
	if not _confirming_reset:
		_confirming_reset = true
		button.text = "再按一次确认清除"
		return
	button.text = "已清除"
	if save_manager and save_manager.has_method("reset_save"):
		save_manager.reset_save()
