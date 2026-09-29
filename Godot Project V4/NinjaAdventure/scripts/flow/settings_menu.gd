extends Control

const REBIND_PANEL_SCENE := preload("res://scenes/ui/rebind_panel.tscn")

@onready var settings_manager: Node = get_node_or_null("/root/SettingsManager")

var _rebind_layer: CanvasLayer = null

func _ready() -> void:
    if settings_manager == null:
        push_warning("SettingsMenu: SettingsManager autoload not found; UI remains present for scene preview.")
    $Panel/ResetSettings.pressed.connect(_on_reset_settings_pressed)
    $Panel/Categories/Input.pressed.connect(_on_input_category_pressed)

func _on_reset_settings_pressed() -> void:
    if settings_manager:
        settings_manager.restore_defaults()

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
