class_name InteractionPrompt
extends Control

@onready var label: Label = %ActionLabel
var action_name: StringName = &""
var enabled := false
var carry_item := ""

func _ready() -> void:
    var input_manager := get_node_or_null("/root/GameInputManager")
    if input_manager != null and not input_manager.device_changed.is_connected(_on_device_changed):
        input_manager.device_changed.connect(_on_device_changed)
    _refresh()

func set_action(value: String, is_enabled: bool) -> void:
    action_name = StringName(value)
    enabled = is_enabled
    _refresh()

func set_carry(item_id: String) -> void:
    carry_item = item_id
    _refresh()

func _on_device_changed(_device: String) -> void:
    _refresh()

func _refresh() -> void:
    visible = enabled or not carry_item.is_empty()
    if not visible:
        return
    var parts: Array[String] = []
    if enabled and not action_name.is_empty():
        parts.append(InputDisplay.get_action_prompt(action_name))
    if not carry_item.is_empty():
        parts.append("%s · %s" % [InputDisplay.get_action_prompt(&"carry"), carry_item])
    label.text = " / ".join(parts)
