extends SceneTree

# tools/generate_input_manifest.gd
# 由 InputMap 自动生成 tools/input_action_manifest.csv，禁止人工维护该文件。
# 运行：godot --headless --path . -s tools/generate_input_manifest.gd
# 注意：-s 脚本模式不注册 autoload 全局标识符，但项目的 class_name 全局类缓存
# 仍然可用，因此这里直接引用 RebindManager.REBINDABLE_ACTIONS 作为唯一事实源，
# 不再自带一份 action 列表（此前是 8 个，与 RebindManager 的 12 个漂移）。
const OUT_PATH := "res://tools/input_action_manifest.csv"
const HEADER := "action,keyboard_default,gamepad_default,note"

func _init() -> void:
    var lines: Array[String] = [HEADER, "# 本文件由 tools/generate_input_manifest.gd 自动生成，请勿手改。"]
    # 唯一事实源 = RebindManager；再补上不可重绑但同样占用 InputMap 的两个 UI action。
    var actions: Array = []
    actions.append_array(RebindManager.REBINDABLE_ACTIONS)
    actions.append_array(["confirm", "cancel"])
    for action in actions:
        var keys: Array[String] = []
        var pads: Array[String] = []
        for ev in InputMap.action_get_events(action):
            if ev is InputEventKey:
                keys.append(ev.as_text())
            elif ev is InputEventMouseButton:
                keys.append("mouse_%d" % ev.button_index)
            elif ev is InputEventJoypadButton:
                pads.append("button_%d" % ev.button_index)
            elif ev is InputEventJoypadMotion:
                pads.append("axis_%d%s" % [ev.axis, "+" if ev.axis_value >= 0.0 else "-"])
        lines.append("%s,\"%s\",\"%s\",auto-generated" % [
            action,
            "; ".join(keys) if not keys.is_empty() else "—",
            "; ".join(pads) if not pads.is_empty() else "—",
        ])
    var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
    if f == null:
        push_error("无法写入 " + OUT_PATH)
        quit(1)
        return
    f.store_string("\n".join(lines) + "\n")
    print("INPUT_MANIFEST: regenerated %s (%d actions)" % [OUT_PATH, actions.size()])
    quit(0)
