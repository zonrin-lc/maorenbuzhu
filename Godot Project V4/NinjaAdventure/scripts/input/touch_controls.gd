class_name TouchControls
extends CanvasLayer

# 移动端：左虚拟摇杆 + 右侧六个情境动作键。
# 所有输入仍通过 InputMap Action，Gameplay 不区分输入设备。

const BUTTONS := [
    {"action": "interact", "label": "互动"},
    {"action": "carry", "label": "叼取"},
    {"action": "meow", "label": "喵叫"},
    {"action": "emote", "label": "卖萌"},
    {"action": "jump", "label": "跳跃"},
    {"action": "sprint", "label": "疾跑"},
]

var _stick_base: Control
var _stick_nub: Control
var _button_grid: GridContainer
var _stick_center := Vector2.ZERO
var _stick_radius := 82.0
var _stick_touch := -1
var _touch_capable := false

func _ready() -> void:
    layer = 50
    process_mode = Node.PROCESS_MODE_ALWAYS
    _touch_capable = OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios") \
        or DisplayServer.is_touchscreen_available() \
        or (OS.has_feature("editor") and ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse", false))
    _build_stick()
    _build_buttons()
    var input_manager := get_node_or_null("/root/GameInputManager")
    if input_manager != null and not input_manager.device_changed.is_connected(_on_device_changed):
        input_manager.device_changed.connect(_on_device_changed)
    _update_visibility()
    _layout()

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_SIZE_CHANGED:
        _layout()

func _build_stick() -> void:
    _stick_base = Control.new()
    _stick_base.name = "VirtualStick"
    add_child(_stick_base)
    var base_ring := _make_circle(_stick_radius, Color(1, 1, 1, 0.10), Color(1, 1, 1, 0.35))
    _stick_base.add_child(base_ring)
    _stick_nub = _make_circle(_stick_radius * 0.45, Color(1, 1, 1, 0.35), Color(1, 1, 1, 0.6))
    _stick_base.add_child(_stick_nub)
    _set_stick_geometry()

func _set_stick_geometry() -> void:
    if _stick_base == null:
        return
    var diameter := _stick_radius * 2.0
    _stick_base.size = Vector2(diameter, diameter)
    _stick_base.custom_minimum_size = _stick_base.size
    _stick_center = Vector2(diameter * 0.5, diameter * 0.5)
    _stick_nub.position = _stick_center - _stick_nub.size * 0.5

func _make_circle(radius: float, fill: Color, border: Color) -> Control:
    var c := Control.new()
    c.size = Vector2(radius * 2.0, radius * 2.0)
    var drawer := _CircleDrawer.new()
    drawer.radius = radius
    drawer.fill = fill
    drawer.border = border
    drawer.set_anchors_preset(Control.PRESET_FULL_RECT)
    c.add_child(drawer)
    return c

func _build_buttons() -> void:
    _button_grid = GridContainer.new()
    _button_grid.name = "ActionButtons"
    _button_grid.columns = 2
    _button_grid.add_theme_constant_override("h_separation", 10)
    _button_grid.add_theme_constant_override("v_separation", 10)
    add_child(_button_grid)
    for spec in BUTTONS:
        var b := Button.new()
        b.name = str(spec.action).capitalize()
        b.text = spec.label
        b.focus_mode = Control.FOCUS_NONE
        b.mouse_filter = Control.MOUSE_FILTER_STOP
        var action: StringName = spec.action
        b.button_down.connect(func():
            _set_device_touch()
            Input.action_press(action)
        )
        b.button_up.connect(func():
            Input.action_release(action)
        )
        _button_grid.add_child(b)

func _layout() -> void:
    var size := get_viewport().get_visible_rect().size
    var short_side := minf(size.x, size.y)
    _stick_radius = clampf(short_side * 0.105, 64.0, 94.0)
    _set_stick_geometry()
    if _stick_base:
        _stick_base.position = Vector2(24.0, size.y - _stick_base.size.y - 24.0)
    if _stick_nub:
        _stick_nub.position = _stick_center - _stick_nub.size * 0.5
    if _button_grid:
        var cell := clampf(short_side * 0.095, 58.0, 82.0)
        _button_grid.position = Vector2(size.x - cell * 2.0 - 28.0, size.y - cell * 3.0 - 28.0)
        _button_grid.size = Vector2(cell * 2.0, cell * 3.0)
        for child in _button_grid.get_children():
            if child is Button:
                child.custom_minimum_size = Vector2(cell, cell)
                child.size = Vector2(cell, cell)

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch or event is InputEventScreenDrag:
        _set_device_touch()
    if not visible:
        return
    if event is InputEventScreenTouch:
        _on_touch(event)
    elif event is InputEventScreenDrag:
        _on_drag(event)

func _on_touch(event: InputEventScreenTouch) -> void:
    if _stick_base == null:
        return
    if event.pressed:
        if _stick_touch == -1 and _stick_base.get_global_rect().grow(28).has_point(event.position):
            _stick_touch = event.index
            _drag_stick(_stick_base.get_global_transform_with_canvas().affine_inverse() * event.position)
    elif event.index == _stick_touch:
        _stick_touch = -1
        _stick_nub.position = _stick_center - _stick_nub.size * 0.5
        _release_move()

func _on_drag(event: InputEventScreenDrag) -> void:
    if event.index != _stick_touch or _stick_base == null:
        return
    var local := _stick_base.get_global_transform_with_canvas().affine_inverse() * event.position
    _drag_stick(local)

func _drag_stick(local: Vector2) -> void:
    var offset := local - _stick_center
    if offset.length() > _stick_radius:
        offset = offset.normalized() * _stick_radius
    _stick_nub.position = _stick_center + offset - _stick_nub.size * 0.5
    var dir := offset / _stick_radius
    _apply_move(dir)

func _apply_move(dir: Vector2) -> void:
    var dead := 0.25
    _set_action("move_left", dir.x < -dead, -dir.x)
    _set_action("move_right", dir.x > dead, dir.x)
    _set_action("move_up", dir.y < -dead, -dir.y)
    _set_action("move_down", dir.y > dead, dir.y)

func _set_action(action: StringName, pressed: bool, strength: float = 1.0) -> void:
    if pressed:
        Input.action_press(action, clampf(strength, 0.0, 1.0))
    else:
        Input.action_release(action)

func _release_move() -> void:
    for action in [&"move_left", &"move_right", &"move_up", &"move_down"]:
        Input.action_release(action)

func _set_device_touch() -> void:
    var input_manager := get_node_or_null("/root/GameInputManager")
    if input_manager != null:
        input_manager.set_last_device(GameInputManager.DEVICE_TOUCH)

# 显隐统一收口到 _update_visibility：只有“硬件支持触控 且 当前输入设备是触控”
# 才显示虚拟按键；触控设备上改用手柄/键鼠时立即隐藏。
func _on_device_changed(_device: String) -> void:
    _update_visibility()

func _update_visibility() -> void:
    var input_manager := get_node_or_null("/root/GameInputManager")
    visible = _touch_capable and (input_manager == null or input_manager.last_device == GameInputManager.DEVICE_TOUCH)

class _CircleDrawer extends Control:
    var radius := 40.0
    var fill := Color(1, 1, 1, 0.1)
    var border := Color(1, 1, 1, 0.35)

    func _draw() -> void:
        draw_circle(Vector2(radius, radius), radius, fill)
        draw_arc(Vector2(radius, radius), radius, 0, TAU, 48, border, 2.0)
