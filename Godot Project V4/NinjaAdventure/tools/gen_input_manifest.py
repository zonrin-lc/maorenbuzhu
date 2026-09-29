"""Regenerate tools/input_action_manifest.csv from the authoritative InputMap.

This is the Python mirror of tools/generate_input_manifest.gd, so the CSV can be
refreshed without launching the Godot editor. Both read the same source of truth
(the project's [input] section); audit_input.py cross-checks the three against
each other so drift in any one of them is caught.
"""
from __future__ import annotations
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT = ROOT / "project.godot"
OUT = ROOT / "tools/input_action_manifest.csv"

# Keep in sync with RebindManager.REBINDABLE_ACTIONS (single source of truth).
REBINDABLE = [
    "move_up", "move_down", "move_left", "move_right",
    "sprint", "interact", "carry", "meow", "emote", "jump", "pause", "retry",
]
EXTRA_UI = ["confirm", "cancel"]

KEYCODES = {
    4194305: "Escape", 4194309: "Enter", 4194325: "Shift", 4194326: "Ctrl",
    4194319: "Left", 4194321: "Right", 4194320: "Up", 4194322: "Down",
    4194323: "Backspace", 4194324: "Tab",
    32: "Space", 65: "A", 66: "B", 67: "C", 68: "D", 69: "E", 70: "F",
    71: "G", 72: "H", 73: "I", 74: "J", 75: "K", 76: "L", 77: "M",
    78: "N", 79: "O", 80: "P", 81: "Q", 82: "R", 83: "S", 84: "T",
    85: "U", 86: "V", 87: "W", 88: "X", 89: "Y", 90: "Z",
}


def _input_section() -> str:
    text = PROJECT.read_text(encoding="utf-8")
    m = re.search(r"^\[input\]\s*$(.*?)(?=^\[|\Z)", text, re.M | re.S)
    return m.group(1) if m else ""


def parse_action_events(section: str, action: str) -> tuple[list[str], list[str]]:
    """Return (keyboard_labels, gamepad_labels) for one action."""
    m = re.search(rf"^{re.escape(action)}=\{{(.*?)^\}}", section, re.M | re.S)
    if not m:
        return ([], [])
    blob = m.group(1)
    keys: list[str] = []
    pads: list[str] = []
    for chunk in blob.split("Object(")[1:]:
        if chunk.startswith("InputEventKey"):
            pk = re.search(r'"physical_keycode":(\d+)', chunk)
            kc = re.search(r'"keycode":(\d+)', chunk)
            code = int(pk.group(1)) if pk and int(pk.group(1)) != 0 else 0
            if code == 0 and kc:
                code = int(kc.group(1))
            if code:
                name = KEYCODES.get(code, f"Key{code}")
                keys.append(f"{name} - Physical" if pk and int(pk.group(1)) != 0 else name)
        elif chunk.startswith("InputEventMouseButton"):
            idx = re.search(r'"button_index":(\d+)', chunk)
            if idx:
                keys.append(f"mouse_{idx.group(1)}")
        elif chunk.startswith("InputEventJoypadButton"):
            idx = re.search(r'"button_index":(\d+)', chunk)
            if idx:
                pads.append(f"button_{idx.group(1)}")
        elif chunk.startswith("InputEventJoypadMotion"):
            axis = re.search(r'"axis":(\d+)', chunk)
            val = re.search(r'"axis_value":(-?[\d.]+)', chunk)
            if axis:
                sign = "+" if (val and float(val.group(1)) >= 0) else "-"
                pads.append(f"axis_{axis.group(1)}{sign}")
    return (keys, pads)


def main() -> None:
    section = _input_section()
    lines = [
        "action,keyboard_default,gamepad_default,note",
        "# 本文件由 tools/generate_input_manifest.gd 自动生成，请勿手改。",
    ]
    for action in REBINDABLE + EXTRA_UI:
        keys, pads = parse_action_events(section, action)
        k = "; ".join(keys) if keys else "—"
        p = "; ".join(pads) if pads else "—"
        lines.append(f'{action},"{k}","{p}",auto-generated')
    OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"regenerated {OUT.name} ({len(REBINDABLE) + len(EXTRA_UI)} actions)")


if __name__ == "__main__":
    main()
