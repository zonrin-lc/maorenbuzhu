extends Node2D

func _ready() -> void:
    GlobalAudioManager.stop_music()

# 同上：改为事件级判断 + set_input_as_handled，避免在 _unhandled_input 里轮询全局输入状态。
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("confirm") or event.is_action_pressed("jump"):
        get_viewport().set_input_as_handled()
        get_tree().change_scene_to_file("res://scenes/levels/ch03_castle/L09_storm_night.tscn")
    elif event.is_action_pressed("cancel") or event.is_action_pressed("pause"):
        get_viewport().set_input_as_handled()
        get_tree().change_scene_to_file("res://scenes/flow/main_menu.tscn")
