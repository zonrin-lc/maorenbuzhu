from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
required = [
    "scripts/flow/settings_data.gd",
    "scripts/flow/settings_manager.gd",
    "scripts/flow/settings_menu.gd",
    "scenes/settings/settings_menu.tscn",
    "data/settings/settings_data.tres.template",
    "docs/v1_2_19_Settings_Spec.md",
]
errors = []
for rel in required:
    if not (ROOT / rel).exists():
        errors.append(f"MISSING:{rel}")

actions = [
    "master_volume", "music_volume", "sfx_volume", "voice_volume", "ui_volume", "ambient_volume",
    "mute_all", "subtitles_enabled", "reduce_flashing", "reduce_screen_shake", "large_ui",
    "high_contrast_ui", "fullscreen", "vsync", "resolution_scale", "show_fps"
]
text = (ROOT / "scripts/flow/settings_data.gd").read_text(encoding="utf-8")
for key in actions:
    if not re.search(rf"var {re.escape(key)}\b", text):
        errors.append(f"MISSING_PROPERTY:{key}")

menu = (ROOT / "scenes/settings/settings_menu.tscn").read_text(encoding="utf-8")
for label in ["输入", "音频", "辅助功能", "显示", "数据管理", "恢复设置默认", "返回"]:
    if label not in menu:
        errors.append(f"MISSING_UI:{label}")

manager = (ROOT / "scripts/flow/settings_manager.gd").read_text(encoding="utf-8")
for needle in ["user://settings.cfg", "restore_defaults", "apply_all", "save_settings"]:
    if needle not in manager:
        errors.append(f"MISSING_MANAGER:{needle}")

print(f"REQUIRED_FILES={len(required)}")
print(f"SETTINGS_KEYS={len(actions)}")
print(f"ERRORS={len(errors)}")
for e in errors:
    print(e)
raise SystemExit(1 if errors else 0)
