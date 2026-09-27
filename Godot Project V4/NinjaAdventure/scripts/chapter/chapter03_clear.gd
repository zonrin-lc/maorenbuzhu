extends Node2D

func _unhandled_input(_event: InputEvent) -> void:
    if Input.is_action_just_pressed("retry"):
        get_tree().change_scene_to_file("res://scenes/levels/ch03_castle/L12_gatekeeper_boss.tscn")
    elif Input.is_action_just_pressed("confirm"):
        get_tree().change_scene_to_file("res://scenes/levels/ch01_village/L01_first_job.tscn")
    elif Input.is_action_just_pressed("cancel"):
        get_tree().change_scene_to_file("res://scenes/flow/main_menu.tscn")
