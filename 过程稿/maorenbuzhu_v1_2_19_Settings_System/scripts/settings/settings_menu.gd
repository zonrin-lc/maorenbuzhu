extends Control

@onready var settings_manager: SettingsManager = get_node_or_null("/root/SettingsManager") as SettingsManager

func _ready() -> void:
    if settings_manager == null:
        push_warning("SettingsMenu: SettingsManager autoload not found; UI remains present for scene preview.")
    $Panel/ResetSettings.pressed.connect(_on_reset_settings_pressed)

func _on_reset_settings_pressed() -> void:
    if settings_manager:
        settings_manager.restore_defaults()
