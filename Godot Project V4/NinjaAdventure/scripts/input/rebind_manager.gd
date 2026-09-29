class_name RebindManager
extends Node

signal rebind_started(action: String)
signal rebind_applied(action: String, old_event: InputEvent, new_event: InputEvent)
signal rebind_cancelled(action: String, reason: String)
# 跨 Action 冲突：保存前审计发现同一物理输入已被其它 action 占用时发出，
# UI 据此提示“与哪个 action 冲突”。reason 同步以 rebind_cancelled 发出，
# 格式为 "cross_action_conflict:<conflicting_action>"。
signal rebind_conflict(action: String, conflicting_action: String, new_event: InputEvent)

const REBINDABLE_ACTIONS := [
    "move_up", "move_down", "move_left", "move_right",
    "sprint", "interact", "carry", "meow", "emote", "jump", "pause", "retry"
]

# 冲突审计覆盖可重绑 action 以及占用同键位的 UI action（confirm/cancel 与 gameplay 默认有共享键）。
const CONFLICT_AUDIT_ACTIONS := [
    "move_up", "move_down", "move_left", "move_right",
    "sprint", "interact", "carry", "meow", "emote", "jump", "pause", "retry",
    "confirm", "cancel",
]

# 持久化：与 SettingsManager 共用同一个配置文件，写在 [input] 段。
const SETTINGS_PATH := "user://settings.cfg"
const SECTION := "input"

# 设备类别：键鼠与手柄分别保存/替换，互不覆盖。
const DEVICE_KBM := &"kbm"
const DEVICE_PAD := &"pad"

# 出厂绑定快照。必须在「任何持久化绑定被套用之前」捕获，否则「恢复默认」会把
# 用户上次的自定义当成出厂值。SettingsManager._ready() 负责调用顺序。
static var _factory_events: Dictionary = {}
static var _factory_snapshot_taken := false

static func device_class_of(event: InputEvent) -> StringName:
    if event is InputEventKey or event is InputEventMouseButton:
        return DEVICE_KBM
    return DEVICE_PAD

# ---------------------------------------------------------------- 持久化

static func snapshot_factory_defaults() -> void:
    if _factory_snapshot_taken:
        return
    for action in CONFLICT_AUDIT_ACTIONS:
        var events: Array = []
        for event in InputMap.action_get_events(action):
            events.append(event.duplicate())
        _factory_events[action] = events
    _factory_snapshot_taken = true

# 启动时套用用户上次的自定义绑定。必须在 snapshot_factory_defaults() 之后调用。
static func apply_persisted_bindings() -> void:
    var cfg := ConfigFile.new()
    if cfg.load(SETTINGS_PATH) != OK:
        return
    if not cfg.has_section(SECTION):
        return
    for action in REBINDABLE_ACTIONS:
        if not cfg.has_section_key(SECTION, action):
            continue
        var raw = cfg.get_value(SECTION, action)
        if not (raw is Dictionary):
            continue
        _apply_stored(action, raw as Dictionary)

static func save_bindings() -> void:
    var cfg := ConfigFile.new()
    cfg.load(SETTINGS_PATH)
    for action in REBINDABLE_ACTIONS:
        var payload := _current_payload(action)
        var total := 0
        for scope in payload:
            total += (payload[scope] as Array).size()
        if total == 0:
            cfg.erase_section_key(SECTION, action)
        else:
            cfg.set_value(SECTION, action, payload)
    cfg.save(SETTINGS_PATH)

static func clear_saved_bindings() -> void:
    var cfg := ConfigFile.new()
    if cfg.load(SETTINGS_PATH) != OK:
        return
    for action in REBINDABLE_ACTIONS:
        cfg.erase_section_key(SECTION, action)
    cfg.save(SETTINGS_PATH)

# 恢复出厂：回滚到 project.godot 的默认绑定，并清掉持久化覆盖。
static func restore_factory_defaults() -> void:
    snapshot_factory_defaults()
    for action in REBINDABLE_ACTIONS:
        if not _factory_events.has(action):
            continue
        InputMap.action_erase_events(action)
        for event in _factory_events[action]:
            InputMap.action_add_event(action, event.duplicate())
    clear_saved_bindings()

# 只替换「与 new_event 同设备」的那一批事件，另一设备（手柄/键鼠）原样保留。
# 这是 P1-01 的核心：旧实现 action_erase_events 会把 interact 的手柄 A 一起删掉，
# 而 InputDisplay 又回退显示硬编码的 "A"，于是 UI 显示 A、实际按不了。
static func _replace_scoped(action: String, new_event: InputEvent) -> InputEvent:
    var scope := device_class_of(new_event)
    var old_event: InputEvent = null
    var keep: Array[InputEvent] = []
    for event in InputMap.action_get_events(action):
        if device_class_of(event) == scope:
            if old_event == null:
                old_event = event
            continue
        keep.append(event)
    InputMap.action_erase_events(action)
    for event in keep:
        InputMap.action_add_event(action, event)
    InputMap.action_add_event(action, new_event)
    return old_event

# ---------------------------------------------------------------- 序列化

# 持久化时按设备分组存「全部」绑定（数组），保证无损：
# move_* 出厂有 方向键 + WASD + D-pad + 模拟摇杆 四条，若只存每设备一条，
# 重启后次要绑定（尤其模拟摇杆）会静默消失。改键后的结果必须能原样还原。
static func _current_payload(action: String) -> Dictionary:
    var out := {DEVICE_KBM: [], DEVICE_PAD: []}
    for event in InputMap.action_get_events(action):
        var d := _serialize_event(event)
        if not d.is_empty():
            out[device_class_of(event)].append(d)
    return out

static func _serialize_event(event: InputEvent) -> Dictionary:
    if event is InputEventKey:
        var code: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
        return {"type": "key", "code": code}
    if event is InputEventMouseButton:
        return {"type": "mouse", "index": event.button_index}
    if event is InputEventJoypadButton:
        return {"type": "pad_button", "index": event.button_index}
    if event is InputEventJoypadMotion:
        return {"type": "pad_motion", "axis": event.axis, "value": signf(event.axis_value)}
    return {}

static func _deserialize_event(data: Dictionary) -> InputEvent:
    match str(data.get("type", "")):
        "key":
            var ev := InputEventKey.new()
            ev.physical_keycode = int(data.get("code", 0))
            return ev
        "mouse":
            var mb := InputEventMouseButton.new()
            mb.button_index = int(data.get("index", MOUSE_BUTTON_LEFT))
            return mb
        "pad_button":
            var jb := InputEventJoypadButton.new()
            jb.button_index = int(data.get("index", 0))
            return jb
        "pad_motion":
            var jm := InputEventJoypadMotion.new()
            jm.axis = int(data.get("axis", 0))
            jm.axis_value = float(data.get("value", 1.0))
            return jm
    return null

static func _apply_stored(action: String, payload: Dictionary) -> void:
    # 无损还原：先清空该 action 的全部绑定，再按持久化数据逐条加回。
    # 这里不能用 _replace_scoped（那是交互改键用的「替换某设备」语义），
    # 否则会丢掉同设备的次要绑定（如模拟摇杆）。
    InputMap.action_erase_events(action)
    for scope in [DEVICE_KBM, DEVICE_PAD]:
        if not payload.has(scope):
            continue
        var list = payload[scope]
        if not (list is Array):
            continue
        for d in list:
            var event := _deserialize_event(d)
            if event != null:
                InputMap.action_add_event(action, event)

# ---------------------------------------------------------------- 实例 API（改键面板使用）

func begin_rebind(action: String) -> bool:
    if action not in REBINDABLE_ACTIONS:
        return false
    rebind_started.emit(action)
    return true

func get_events(action: String) -> Array[InputEvent]:
    return InputMap.action_get_events(action)

func apply_binding(action: String, new_event: InputEvent) -> bool:
    if action not in REBINDABLE_ACTIONS:
        return false
    if new_event == null:
        rebind_cancelled.emit(action, "null_event")
        return false
    if _would_break_required_actions(action, new_event):
        rebind_cancelled.emit(action, "required_action_conflict")
        return false
    var conflicting := _find_cross_action_conflict(action, new_event)
    if not conflicting.is_empty():
        rebind_conflict.emit(action, conflicting, new_event)
        rebind_cancelled.emit(action, "cross_action_conflict:%s" % conflicting)
        return false
    var old_event := _replace_scoped(action, new_event)
    save_bindings()
    rebind_applied.emit(action, old_event, new_event)
    return true

func restore_defaults(default_event_map: Dictionary) -> void:
    for action in REBINDABLE_ACTIONS:
        if not default_event_map.has(action):
            continue
        InputMap.action_erase_events(action)
        for event in default_event_map[action]:
            InputMap.action_add_event(action, event.duplicate())

# “恢复出厂绑定”：回滚 project.godot 默认值并清除持久化覆盖。
func restore_session_defaults() -> void:
    restore_factory_defaults()

func _would_break_required_actions(action: String, event: InputEvent) -> bool:
    # 设备级替换后，pause 即便没有键鼠绑定也仍保有手柄绑定，因此不再因空事件失败；
    # 这里只拦截显式传入 null 的情况（调用方 bug）。
    if event == null:
        return true
    return false

func _find_cross_action_conflict(action: String, event: InputEvent) -> String:
    if event == null:
        return ""
    for other in CONFLICT_AUDIT_ACTIONS:
        if other == action:
            continue
        # 同一次改键不应与自己的另一个设备绑定冲突。
        for existing in InputMap.action_get_events(other):
            if _is_same_physical_input(existing, event):
                return other
    return ""

func _is_same_physical_input(a: InputEvent, b: InputEvent) -> bool:
    if a is InputEventKey and b is InputEventKey:
        var ka: int = a.physical_keycode if a.physical_keycode != 0 else a.keycode
        var kb: int = b.physical_keycode if b.physical_keycode != 0 else b.keycode
        return ka == kb
    if a is InputEventJoypadButton and b is InputEventJoypadButton:
        return a.button_index == b.button_index
    if a is InputEventJoypadMotion and b is InputEventJoypadMotion:
        return a.axis == b.axis and signf(a.axis_value) == signf(b.axis_value)
    if a is InputEventMouseButton and b is InputEventMouseButton:
        return a.button_index == b.button_index
    return false
