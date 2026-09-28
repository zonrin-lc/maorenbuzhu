from pathlib import Path
import re

ROOT=Path(__file__).resolve().parents[1]
required=[
    "data/audio/sfx_interact.tres", "data/audio/sfx_pickup.tres", "data/audio/sfx_place.tres",
    "data/audio/sfx_route.tres", "data/audio/sfx_damage.tres", "data/audio/sfx_boss_phase.tres",
    "data/audio/sfx_shortcut.tres", "data/audio/sfx_victory.tres",
]
for p in required:
    assert (ROOT/p).exists(), f"missing {p}"
text=(ROOT/"scripts/audio/global_audio_manager.gd").read_text(encoding="utf-8")
for key in ["interact","pickup","place","route_change","damage","boss_phase","shortcut","victory"]:
    assert f'"{key}"' in text, f"missing sfx key {key}"
manager=(ROOT/"scripts/gameplay/unified_level_manager.gd").read_text(encoding="utf-8")
for needle in ['play_event_sfx("damage")', "event_sfx_for(data.event_type, action_id)", 'play_event_sfx("shortcut")', 'play_event_sfx("boss_phase")']:
    assert needle in manager, f"missing hookup: {needle}"
pickup=(ROOT/"scripts/gameplay/carry_pickup.gd").read_text(encoding="utf-8")
assert 'play_event_sfx("pickup")' in pickup
print("AUDIO_FEEDBACK_V1_5_4 PASS")
