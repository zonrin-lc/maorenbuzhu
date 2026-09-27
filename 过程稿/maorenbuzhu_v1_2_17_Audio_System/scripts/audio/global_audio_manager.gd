extends Node
class_name GlobalAudioManager

signal music_state_changed(state: String)

const STATES := {
    "VILLAGE_CALM": "res://data/audio/music_village_calm.tres",
    "VILLAGE_TENSION": "res://data/audio/music_village_tension.tres",
    "DOCK_CALM": "res://data/audio/music_dock_calm.tres",
    "DOCK_TENSION": "res://data/audio/music_dock_tension.tres",
    "CASTLE_CALM": "res://data/audio/music_castle_calm.tres",
    "CASTLE_TENSION": "res://data/audio/music_castle_tension.tres",
    "BOSS_PREPARE": "res://data/audio/music_boss_prepare.tres",
    "BOSS_PHASE_1": "res://data/audio/music_boss_phase_1.tres",
    "BOSS_PHASE_2": "res://data/audio/music_boss_phase_2.tres",
    "BOSS_PHASE_3": "res://data/audio/music_boss_phase_3.tres",
    "BOSS_DEFEAT": "res://data/audio/music_boss_defeat.tres",
}

var current_state := ""

func set_music_state(state: String) -> void:
    if not STATES.has(state):
        push_warning("Unknown audio state: %s" % state)
        return
    if state == current_state:
        return
    current_state = state
    music_state_changed.emit(state)
    # Runtime implementation should resolve the AudioData Resource here.
    # Keep actual AudioStreamPlayer ownership inside this singleton.

func play_event_sfx(event_key: String) -> void:
    # Resolve from AudioEventData Resource; do not let event scripts load streams directly.
    pass

func play_ninja_voice(tag: String) -> void:
    # Voice selection is tag-driven and should use a non-repeating pool.
    pass

func play_cat_meow() -> void:
    # External original meow assets are assigned through CatMeowAudioData.
    pass
