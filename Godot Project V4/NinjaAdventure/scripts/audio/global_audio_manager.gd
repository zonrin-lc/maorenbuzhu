extends Node

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

const SFX := {
    "success": "res://data/audio/sfx_success.tres",
    "fail": "res://data/audio/sfx_fail.tres",
    "read_map": "res://data/audio/sfx_read_map.tres",
    "emote": "res://data/audio/sfx_emote.tres",
    "dog": "res://data/audio/sfx_dog.tres",
}

var current_state := ""
var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _meow_warned := false

func _ready() -> void:
    _music_player = AudioStreamPlayer.new()
    _music_player.name = "MusicPlayer"
    add_child(_music_player)
    for i in 4:
        var p := AudioStreamPlayer.new()
        p.name = "SfxPlayer%d" % i
        add_child(p)
        _sfx_players.append(p)

func set_music_state(state: String) -> void:
    if not STATES.has(state):
        push_warning("Unknown audio state: %s" % state)
        return
    if state == current_state:
        return
    current_state = state
    var audio: AudioData = load(STATES[state])
    if audio == null or audio.stream == null:
        push_warning("AudioData missing stream: %s" % state)
        return
    _music_player.stream = audio.stream
    _music_player.bus = audio.bus if AudioServer.get_bus_index(audio.bus) >= 0 else &"Master"
    _music_player.volume_db = audio.volume_db
    _music_player.pitch_scale = audio.pitch
    _music_player.play()
    music_state_changed.emit(state)

func play_event_sfx(event_key: String) -> void:
    if not SFX.has(event_key):
        return
    var audio: AudioData = load(SFX[event_key])
    if audio == null or audio.stream == null:
        return
    for p in _sfx_players:
        if not p.playing:
            p.stream = audio.stream
            p.bus = audio.bus if AudioServer.get_bus_index(audio.bus) >= 0 else &"Master"
            p.volume_db = audio.volume_db
            p.pitch_scale = audio.pitch
            p.play()
            return
    _sfx_players[0].stream = audio.stream
    _sfx_players[0].play()

func play_ninja_voice(tag: String) -> void:
    # Voice 语气音池（Voice1~10.wav）待按 tag 映射接入；当前仅记录
    pass

func play_cat_meow() -> void:
    # 猫叫音源是唯一素材缺口（GDD §9.3，外部原创 Missing）；到位前静默跳过
    if not _meow_warned:
        push_warning("SFX_MEOW 素材缺失（外部原创音源待补）")
        _meow_warned = true
