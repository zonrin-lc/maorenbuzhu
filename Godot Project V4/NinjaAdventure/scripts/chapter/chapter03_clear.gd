extends Node2D

func _ready() -> void:
    GlobalAudioManager.stop_music()

# 用 event.is_action_pressed 而非在 _unhandled_input 里轮询全局 Input 状态：
# 后者每次未处理事件（含连续 MouseMotion）都会重复判断，且从不 set_input_as_handled。
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("retry"):
        get_viewport().set_input_as_handled()
        get_tree().change_scene_to_file("res://scenes/levels/ch03_castle/L12_gatekeeper_boss.tscn")
    elif event.is_action_pressed("confirm"):
        get_viewport().set_input_as_handled()
        get_tree().change_scene_to_file("res://scenes/levels/ch01_village/L01_first_job.tscn")
    elif event.is_action_pressed("cancel") or event.is_action_pressed("pause"):
        get_viewport().set_input_as_handled()
        get_tree().change_scene_to_file("res://scenes/flow/main_menu.tscn")
