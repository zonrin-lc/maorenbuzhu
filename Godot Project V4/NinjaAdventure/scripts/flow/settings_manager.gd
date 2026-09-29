extends Node

const SETTINGS_PATH := "user://settings.cfg"

signal settings_changed(data: SettingsData)

var data: SettingsData = SettingsData.new()

func _ready() -> void:
    load_settings()
    apply_all()

func load_settings() -> void:
    var cfg := ConfigFile.new()
    if cfg.load(SETTINGS_PATH) != OK:
        save_settings()
        return
    for property_name in _property_names():
        if cfg.has_section_key("settings", property_name):
            data.set(property_name, cfg.get_value("settings", property_name))

func save_settings() -> void:
    var cfg := ConfigFile.new()
    for property_name in _property_names():
        cfg.set_value("settings", property_name, data.get(property_name))
    cfg.save(SETTINGS_PATH)
    settings_changed.emit(data)

func restore_defaults() -> void:
    data = SettingsData.new()
    save_settings()
    apply_all()

func apply_all() -> void:
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if data.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
    if DisplayServer.window_get_vsync_mode() != (DisplayServer.VSYNC_ENABLED if data.vsync else DisplayServer.VSYNC_DISABLED):
        DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if data.vsync else DisplayServer.VSYNC_DISABLED)
    _apply_audio()
    settings_changed.emit(data)

# 各音量滑块 -> AudioServer 总线。settings_data 里的字段此前只写进 cfg 从未被应用，
# 玩家调音量完全无效；这里在每次 apply_all() 时真正下发到总线。
const BUS_MAP := {
    &"master_volume": [&"Master"],
    &"music_volume": [&"Music"],
    &"sfx_volume": [&"SFX", &"Sound"],
    &"voice_volume": [&"Voice"],
    &"ui_volume": [&"UI"],
    &"ambient_volume": [&"Ambient"],
}

func _apply_audio() -> void:
    for field_name in BUS_MAP:
        var buses: Array = BUS_MAP[field_name]
        var linear: float = clampf(float(data.get(field_name)), 0.0, 1.0)
        for bus_name in buses:
            var idx := AudioServer.get_bus_index(bus_name)
            if idx < 0:
                continue
            AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(linear, 0.0001)))
    var master_idx := AudioServer.get_bus_index(&"Master")
    if master_idx >= 0:
        AudioServer.set_bus_mute(master_idx, data.mute_all)

func set_option(key: StringName, value: Variant, persist := true) -> bool:
    if not data.get_property_list().any(func(p): return p.name == key):
        return false
    data.set(key, value)
    if persist:
        save_settings()
    apply_all()
    return true

func _property_names() -> Array[String]:
    var names: Array[String] = []
    for p in data.get_property_list():
        if p.name == "resource_local_to_scene" or p.name == "resource_name":
            continue
        if p.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
            names.append(p.name)
    return names
