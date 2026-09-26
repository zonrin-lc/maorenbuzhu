class_name InteractionPrompt
extends Control

@onready var label: Label = %ActionLabel
var action_name: String = ""

func set_action(value: String, enabled: bool) -> void:
    action_name = value
    visible = enabled and not value.is_empty()
    if visible:
        label.text = value

func set_carry(item_id: String) -> void:
    if item_id.is_empty():
        return
    label.text = "Q 叼取 / 放置 · %s" % item_id
