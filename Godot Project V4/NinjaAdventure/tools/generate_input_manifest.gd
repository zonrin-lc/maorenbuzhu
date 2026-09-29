extends SceneTree

# tools/generate_input_manifest.gd
# 由 InputMap 自动生成 tools/input_action_manifest.csv，禁止再人工维护该文件。
# 运行：godot --headless --path . -s tools/generate_input_manifest.gd
# 注意：-s 脚本模式不注册 autoload 全局标识符，本脚本只用引擎级 InputMap。

const REBINDABLE := ["interact", "carry", "meow", "emote", "jump", "sprint", "pause", "retry"]
const OUT_PATH := "res://tools/input_action_manifest.csv"

func _init() -> void:
    var lines: Array[String] = ["action,keyboard,gamepad,note", "# 本文件由 tools/generate_input_manifest.gd 自动生成，请勿手改",]
    for action in REBINDABLE:
        var keys: Array[String] = []
        var pads: Array[String] = []
        for ev in InputMap.action_get_events(action):
            if ev is InputEventKey:
                keys.append(ev.as_text())
            elif ev is InputEventJoypadButton:
                pads.append("button_%d" % ev.button_index)
            elif ev is InputEventJoypadMotion:
                pads.append("axis_%d" % ev.axis)
            elif ev is InputEventMouseButton:
                keys.append("mouse_%d" % ev.button_index)
        lines.append("%s,\"%s\",\"%s\",auto-generated" % [action, "; ".join(keys), "; ".join(pads)])
    var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
    if f == null:
        push_error("无法写入 " + OUT_PATH)
        quit(1)
        return
    f.store_string("\n".join(lines) + "\n")
    print("INPUT_MANIFEST: regenerated %s (%d actions)" % [OUT_PATH, REBINDABLE.size()])
    quit(0)
