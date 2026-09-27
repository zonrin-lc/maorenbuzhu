class_name PauseController
extends Node

signal pause_changed(paused: bool)

func toggle_pause() -> void:
    var next_paused := not get_tree().paused
    get_tree().paused = next_paused
    pause_changed.emit(next_paused)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        toggle_pause()
        get_viewport().set_input_as_handled()
