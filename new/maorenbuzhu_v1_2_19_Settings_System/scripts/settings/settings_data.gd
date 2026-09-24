class_name SettingsData
extends Resource

@export_range(0.0, 1.0, 0.01) var master_volume: float = 1.0
@export_range(0.0, 1.0, 0.01) var music_volume: float = 0.8
@export_range(0.0, 1.0, 0.01) var sfx_volume: float = 1.0
@export_range(0.0, 1.0, 0.01) var voice_volume: float = 1.0
@export_range(0.0, 1.0, 0.01) var ui_volume: float = 1.0
@export_range(0.0, 1.0, 0.01) var ambient_volume: float = 0.8
@export var mute_all: bool = false
@export var subtitles_enabled: bool = true
@export var reduce_flashing: bool = false
@export var reduce_screen_shake: bool = false
@export var large_ui: bool = false
@export var high_contrast_ui: bool = false
@export var fullscreen: bool = false
@export var vsync: bool = true
@export_range(0.5, 1.5, 0.05) var resolution_scale: float = 1.0
@export var show_fps: bool = false
