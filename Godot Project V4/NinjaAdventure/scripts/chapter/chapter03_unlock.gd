extends Node2D

func _unhandled_input(_event: InputEvent) -> void:
    if Input.is_action_just_pressed("confirm") or Input.is_action_just_pressed("jump"):
        get_tree().change_scene_to_file("res://scenes/levels/ch03_castle/L09_storm_night.tscn")
    elif Input.is_action_just_pressed("cancel"):
        get_tree().change_scene_to_file("res://scenes/flow/main_menu.tscn")
