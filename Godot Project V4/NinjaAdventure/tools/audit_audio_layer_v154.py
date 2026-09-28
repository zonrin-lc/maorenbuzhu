from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
manager=(ROOT/'scripts/gameplay/unified_level_manager.gd').read_text(encoding='utf-8')
audio=(ROOT/'scripts/audio/global_audio_manager.gd').read_text(encoding='utf-8')
checks={
    'shortcut_start_not_duplicated':'&"JUMP", &"CAT_TUNNEL"' not in manager,
    'route_change_audio_hooked': manager.count('play_event_sfx("route_change")') >= 3,
    'boss_phase_audio_hooked':'play_event_sfx("boss_phase")' in manager,
    'damage_audio_hooked':'play_event_sfx("damage")' in manager,
    'pickup_audio_hooked':'play_event_sfx("pickup")' in (ROOT/'scripts/gameplay/carry_pickup.gd').read_text(encoding='utf-8'),
    'music_phase_does_not_restart_same_stream':'same_stream := _music_player.playing' in audio,
    'sfx_cooldowns_present':'SFX_COOLDOWN_MS' in audio,
}
failed=[k for k,v in checks.items() if not v]
print('AUDIO_LAYER_V1_5_4 ' + ('PASS' if not failed else 'FAIL'))
for k,v in checks.items(): print(f'{k}: {"PASS" if v else "FAIL"}')
if failed: raise SystemExit(1)
