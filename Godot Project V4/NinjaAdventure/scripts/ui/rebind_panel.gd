extends Control

# 改键面板（设置 → 输入）：动态列出 RebindManager.REBINDABLE_ACTIONS，
# 点击行进入“按任意键/手柄钮”捕获态，结果交给 RebindManager.apply_binding；
# 跨 Action 冲突被拒时在 Status 行提示冲突双方。恢复默认走会话级 InputMap 快照。

signal closed

const ACTION_LABELS := {
    "move_up": "上移", "move_down": "下移", "move_left": "左移", "move_right": "右移",
    "sprint": "疾跑", "interact": "互动", "carry": "叼取", "meow": "喵叫",
    "emote": "卖萌", "jump": "跳跃", "pause": "暂停", "retry": "重开",
    "confirm": "确定", "cancel": "取消",
}

var _manager: RebindManager
var _capturing_action := ""
var _row_buttons := {}

@onready var _status: Label = $Panel/VBox/Status
@onready var _action_list: VBoxContainer = $Panel/VBox/Scroll/ActionList
@onready var _dim: ColorRect = $Dim

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _manager = RebindManager.new()
    add_child(_manager)
    _manager.rebind_applied.connect(_on_rebind_applied)
    _manager.rebind_conflict.connect(_on_rebind_conflict)
    _manager.rebind_cancelled.connect(_on_rebind_cancelled)
    _build_rows()
    $Panel/VBox/ButtonRow/RestoreDefaults.pressed.connect(_on_restore_defaults_pressed)
    $Panel/VBox/ButtonRow/Cancel.pressed.connect(_close)
    _dim.gui_input.connect(_on_dim_gui_input)
    _set_status("点击要修改的动作，然后按下新的按键 / 手柄钮。")

func _build_rows() -> void:
    for action in RebindManager.REBINDABLE_ACTIONS:
        var row := HBoxContainer.new()
        row.add_theme_constant_override("separation", 12)
        var name_label := Label.new()
        name_label.text = _action_label(action)
        name_label.custom_minimum_size = Vector2(120, 52)
        name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        row.add_child(name_label)
        var bind_button := Button.new()
        bind_button.custom_minimum_size = Vector2(300, 52)
        bind_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        bind_button.text = _binding_text(action)
        bind_button.pressed.connect(_on_row_pressed.bind(action))
        row.add_child(bind_button)
        _action_list.add_child(row)
        _row_buttons[action] = bind_button

func _binding_text(action: String) -> String:
    # 两端都读真实 InputMap，不再硬编码。move_* 的手柄端只有在该 action 确实仍保有
    # 模拟摇杆轴时才显示「左摇杆」——否则显示实际绑定，杜绝「显示 A 却按不了」。
    var pad_label := InputDisplay.get_device_binding_label(action, GameInputManager.DEVICE_GAMEPAD)
    if action.begins_with("move_") and _has_analog_axis(action):
        pad_label = "左摇杆"
    return "%s  /  %s" % [
        InputDisplay.get_device_binding_label(action, GameInputManager.DEVICE_KEYBOARD_MOUSE),
        pad_label,
    ]

func _has_analog_axis(action: String) -> bool:
    for event in InputMap.action_get_events(action):
        if event is InputEventJoypadMotion:
            return true
    return false

func _on_row_pressed(action: String) -> void:
    _end_capture()
    _capturing_action = action
    _row_buttons[action].text = "按任意键…（Esc 取消）"
    _set_status("正在为「%s」捕获输入…" % _action_label(action))

func _input(event: InputEvent) -> void:
    if _capturing_action.is_empty():
        return
    if event is InputEventKey and event.pressed and not event.echo:
        var key: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
        if key == KEY_ESCAPE:
            get_viewport().set_input_as_handled()
            var cancelled := _capturing_action
            _end_capture()
            _set_status("已取消「%s」的改键。" % _action_label(cancelled))
            return
        _capture(event)
    elif event is InputEventJoypadButton and event.pressed:
        _capture(event)
    elif event is InputEventMouseButton and event.pressed:
        _capture(event)

func _capture(event: InputEvent) -> void:
    get_viewport().set_input_as_handled()
    var action := _capturing_action
    _end_capture()
    _manager.apply_binding(action, event)

func _end_capture() -> void:
    var action := _capturing_action
    _capturing_action = ""
    if not action.is_empty() and _row_buttons.has(action):
        _row_buttons[action].text = _binding_text(action)

func _on_rebind_applied(action: String, _old_event: InputEvent, _new_event: InputEvent) -> void:
    if _row_buttons.has(action):
        _row_buttons[action].text = _binding_text(action)
    _set_status("「%s」改键成功。" % _action_label(action))

func _on_rebind_conflict(action: String, conflicting_action: String, _new_event: InputEvent) -> void:
    _set_status("「%s」与「%s」冲突：该输入已被占用，改键未保存。" % [
        _action_label(action), _action_label(conflicting_action)])

func _on_rebind_cancelled(_action: String, reason: String) -> void:
    if reason.begins_with("cross_action_conflict:"):
        return  # rebind_conflict 已给出更明确的提示
    _set_status("改键被拒绝（%s）。" % reason)

func _on_restore_defaults_pressed() -> void:
    _end_capture()
    _manager.restore_session_defaults()
    for action in _row_buttons:
        _row_buttons[action].text = _binding_text(action)
    _set_status("已恢复默认绑定。")

func _on_dim_gui_input(event: InputEvent) -> void:
    if not _capturing_action.is_empty():
        return  # 捕获态下的点击是候选输入，由 _input 处理
    if event is InputEventMouseButton and event.pressed:
        _close()
    elif event is InputEventScreenTouch and event.pressed:
        _close()

func _close() -> void:
    closed.emit()
    queue_free()

func _set_status(text: String) -> void:
    _status.text = text

func _action_label(action: String) -> String:
    return str(ACTION_LABELS.get(action, action))
