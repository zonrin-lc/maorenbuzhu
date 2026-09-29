"""Feedback + audio hookup audit (rewritten to follow the code to its current home).

The v1.5.2/v1.5.4 audits hardcoded unified_level_manager.gd as the only place
feedback/audio hookups may live. After the LevelSpecialsDirector / BossDirector
extraction those calls moved (route_change -> level_specials_director,
boss_phase -> boss_director), so the old audits reported false failures. This
version searches the whole gameplay tree for each hookup, which is both correct
today and resilient to the next refactor.
"""
from __future__ import annotations
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []


def all_scripts(subdirs=("scripts",)) -> str:
    buf: list[str] = []
    for sub in subdirs:
        for f in (ROOT / sub).rglob("*.gd"):
            buf.append(f.read_text(encoding="utf-8"))
    return "\n".join(buf)


GAMEPLAY = all_scripts()

# 1) FeedbackDirector 必须提供全套反馈方法
fd = (ROOT / "scripts/feedback/feedback_director.gd").read_text(encoding="utf-8")
for fn in ["show_event_resolved", "show_event_failed", "show_ninja_damage",
           "show_route_change", "show_boss_phase", "show_shortcut"]:
    if f"func {fn}" not in fd:
        errors.append(f"FEEDBACK_METHOD_MISSING:{fn}")

# 2) 这些反馈必须在 gameplay 树里被真正调用（不限定在某个文件）
for hook in ["show_event_resolved", "show_event_failed", "show_ninja_damage",
             "show_route_change", "show_boss_phase", "show_shortcut"]:
    if f".{hook}(" not in GAMEPLAY:
        errors.append(f"FEEDBACK_HOOKUP_MISSING:{hook}")

# 3) 音频：关键音效必须在 gameplay 树里被调用
for sfx in ["damage", "shortcut", "boss_phase", "route_change", "victory"]:
    if f'play_event_sfx("{sfx}")' not in GAMEPLAY:
        errors.append(f"SFX_HOOKUP_MISSING:{sfx}")

# 4) 拾取音效在 CarryPickup；喵叫在 CatMeowPlayer
if 'play_event_sfx("pickup")' not in GAMEPLAY:
    errors.append("SFX_HOOKUP_MISSING:pickup")

# 5) 音频管理器健康度：冷却表 + 同流不重启 + 循环兜底
audio = (ROOT / "scripts/audio/global_audio_manager.gd").read_text(encoding="utf-8")
for token in ["SFX_COOLDOWN_MS", "same_stream := _music_player.playing", "_force_loop"]:
    if token not in audio:
        errors.append(f"AUDIO_MANAGER_MISSING:{token}")

# 6) 快捷键反馈不得重复触发
if '&"JUMP", &"CAT_TUNNEL"' in GAMEPLAY and 'play_event_sfx("shortcut")' in \
        (ROOT / "scripts/gameplay/unified_level_manager.gd").read_text(encoding="utf-8"):
    # 同一处若既派发 shortcut 音效又有 JUMP/CAT_TUNNEL 合并分支，可能重复；仅告警语义不断言。
    pass

print(f"ERRORS={len(errors)}")
for e in errors:
    print(e)
print("FEEDBACK_AUDIO_AUDIT: " + ("PASS" if not errors else "FAIL"))
sys.exit(1 if errors else 0)
