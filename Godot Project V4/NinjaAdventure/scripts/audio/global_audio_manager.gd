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
    "SETTLEMENT": "res://data/audio/music_settlement.tres",
}

const SFX := {
    "success": "res://data/audio/sfx_success.tres",
    "fail": "res://data/audio/sfx_fail.tres",
    "read_map": "res://data/audio/sfx_read_map.tres",
    "emote": "res://data/audio/sfx_emote.tres",
    "dog": "res://data/audio/sfx_dog.tres",
    "interact": "res://data/audio/sfx_interact.tres",
    "pickup": "res://data/audio/sfx_pickup.tres",
    "place": "res://data/audio/sfx_place.tres",
    "route_change": "res://data/audio/sfx_route.tres",
    "damage": "res://data/audio/sfx_damage.tres",
    "boss_phase": "res://data/audio/sfx_boss_phase.tres",
    "shortcut": "res://data/audio/sfx_shortcut.tres",
    "victory": "res://data/audio/sfx_victory.tres",
}

var current_state := ""
var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
const CAT_MEOW_VARIANTS := [
    "res://audio/sfx/cat_meow_short.wav",
    "res://audio/sfx/cat_meow_bright.wav",
    "res://audio/sfx/cat_meow_low.wav",
]
var _meow_selector: CatMeowPlayer
var _meow_rng := RandomNumberGenerator.new()
var _last_sfx_ms: Dictionary = {}
const SFX_COOLDOWN_MS := {
    "success": 90, "fail": 180, "read_map": 250, "emote": 120, "dog": 140,
    "interact": 80, "pickup": 100, "place": 100, "route_change": 220,
    "damage": 140, "boss_phase": 350, "shortcut": 180, "victory": 450,
}

func _ready() -> void:
    _meow_selector = CatMeowPlayer.new()
    _meow_rng.randomize()
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
    # 同一状态只有「正在播放」时才忽略。此前无条件早退，导致音乐播完后无法重播
    # （唯一补救手段被自己堵死），30~60s 后全场静音。
    if state == current_state and _music_player.playing:
        return
    var audio: AudioData = load(STATES[state])
    if audio == null or audio.stream == null:
        # 校验通过后再提交 current_state，否则一次加载失败会让该状态整个会话永久短路。
        push_warning("AudioData missing stream: %s" % state)
        return
    current_state = state
    _force_loop(audio.stream)
    var same_stream := _music_player.playing and _music_player.stream != null and _music_player.stream.resource_path == audio.stream.resource_path
    _music_player.bus = audio.bus if AudioServer.get_bus_index(audio.bus) >= 0 else &"Master"
    _music_player.volume_db = audio.volume_db
    _music_player.pitch_scale = audio.pitch
    if not same_stream:
        _music_player.stream = audio.stream
        _music_player.play()
    music_state_changed.emit(state)

# 音乐必须循环。导入侧 loop 参数此前全是 false，这里在运行时强制兜底，
# 避免任何人重新导入音频后静音回归。
func _force_loop(stream: AudioStream) -> void:
    if stream is AudioStreamOggVorbis:
        (stream as AudioStreamOggVorbis).loop = true
    elif stream is AudioStreamWAV:
        var wav := stream as AudioStreamWAV
        wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
        wav.loop_begin = 0
        wav.loop_end = int(wav.get_length() * wav.mix_rate)

# 菜单/章节过场没有专属音乐状态，此前结算音乐会一直漏到主菜单和章节结算页。
# 进入这些场景时显式停掉。
func stop_music() -> void:
    current_state = ""
    if _music_player.playing:
        _music_player.stop()

func play_event_sfx(event_key: String) -> void:
    if not SFX.has(event_key):
        return
    var now := Time.get_ticks_msec()
    var cooldown := int(SFX_COOLDOWN_MS.get(event_key, 0))
    var last := int(_last_sfx_ms.get(event_key, -1000000))
    if cooldown > 0 and now - last < cooldown:
        return
    _last_sfx_ms[event_key] = now
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
    # 四通道都忙时，不抢占当前声音；避免爆音/音效糊成一团。

func event_sfx_for(event_type: StringName, action_id: StringName) -> String:
    match action_id:
        &"JUMP", &"CAT_TUNNEL":
            return "shortcut"
        &"MEOW":
            return "emote" if event_type == &"GUARD" else "success"
        &"FEED", &"SEND_DOG", &"DOG_ASSIST":
            return "dog"
        &"STEAL_CRATE":
            return "pickup"
        &"PUSH", &"PLACE_ANTIDOTE", &"PLACE_CRATE":
            return "place"
        _:
            pass
    match event_type:
        &"GUARD": return "success"
        &"DOG": return "dog"
        &"POISON", &"BRIDGE", &"WATERGAP", &"DYNAMITE", &"CALTROP": return "place"
        &"BOSS_CRANE", &"BOSS_GOURD", &"BOSS_CALTROP": return "place"
        _: return "success"

const NINJA_VOICE_TAGS := {
    "hurt": ["res://audio/sfx/voice_01.wav", "res://audio/sfx/voice_02.wav"],
    "confused": ["res://audio/sfx/voice_03.wav", "res://audio/sfx/voice_04.wav", "res://audio/sfx/voice_05.wav"],
    "proud": ["res://audio/sfx/voice_06.wav", "res://audio/sfx/voice_07.wav", "res://audio/sfx/voice_08.wav"],
    "scared": ["res://audio/sfx/voice_09.wav", "res://audio/sfx/voice_10.wav"],
}
const NINJA_VOICE_COOLDOWN_MS := 600
var _last_voice_ms := -1000000

func play_ninja_voice(tag: String) -> void:
    var variants: Array = NINJA_VOICE_TAGS.get(tag, [])
    if variants.is_empty():
        return
    var now := Time.get_ticks_msec()
    if now - _last_voice_ms < NINJA_VOICE_COOLDOWN_MS:
        return
    _last_voice_ms = now
    var stream: AudioStream = load(variants[_meow_rng.randi_range(0, variants.size() - 1)])
    if stream == null:
        return
    for p in _sfx_players:
        if not p.playing:
            p.stream = stream
            # Voice 走 Voice 总线（GDD §9.1），音量与普通 SFX 对齐
            p.bus = "Voice" if AudioServer.get_bus_index("Voice") >= 0 else (&"SFX" if AudioServer.get_bus_index("SFX") >= 0 else &"Master")
            # 必须显式重置：共享 4 通道池，若不设会继承上一个喵叫的 -2.5 dB。
            p.volume_db = 0.0
            p.pitch_scale = 1.0 + _meow_rng.randf_range(-0.05, 0.05)
            p.play()
            return

func play_cat_meow() -> void:
    if _meow_selector == null:
        return
    var now := Time.get_ticks_msec() / 1000.0
    if not _meow_selector.can_play(now):
        return
    var variant := _meow_selector.choose_variant(CAT_MEOW_VARIANTS.size(), _meow_rng)
    var stream := load(CAT_MEOW_VARIANTS[variant]) as AudioStream
    if stream == null:
        push_warning("猫叫音源加载失败：%s" % CAT_MEOW_VARIANTS[variant])
        return
    for p in _sfx_players:
        if not p.playing:
            p.stream = stream
            p.bus = "SFX" if AudioServer.get_bus_index("SFX") >= 0 else "Master"
            p.volume_db = -2.5
            p.pitch_scale = _meow_rng.randf_range(0.97, 1.03)
            p.play()
            _meow_selector.mark_played(now, variant)
            return
