extends Resource
class_name AudioData

@export var audio_id := ""
@export var stream: AudioStream
@export var bus := "SFX"
@export_range(-40.0, 12.0, 0.1) var volume_db := 0.0
@export_range(0.5, 2.0, 0.01) var pitch := 1.0
@export var loop := false
@export var priority := 50
