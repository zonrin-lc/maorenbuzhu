class_name TouchControls
extends CanvasLayer

# 移动端触屏层：左侧虚拟摇杆（move_* 动作），右侧情境按键（E/Q/F/Ctrl/Shift）。
# 按键通过 Input.action_press/action_release 驱动 InputMap，Gameplay 只读 Action（GDD §2.2 / v1.2.18）。
# 自动显示：移动端平台、触屏输入、或编辑器开启 emulate_touch 时；桌面键鼠隐藏。

const BUTTONS := [
    {"action": "interact", "label": "互动"},
    {"action": "carry", "label": "叼取"},
    {"action": "meow", "label": "喵叫"},
    {"action": "emote", "label": "卖萌"},
    {"action": "sprint", "label": "疾跑"},
]

var _stick_base: Control
var _stick_nub: Control
var _stick_center := Vector2.ZERO
var _stick_radius := 90.0
var _stick_touch := -1
var _button_touches := {}

func _ready() -> void:
    layer = 50
    _build_stick()
    _build_buttons()
    _update_visibility()

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_SIZE_CHANGED:
        _layout()

func _build_stick() -> void:
    _stick_base = Control.new()
    _stick_base.name = "VirtualStick"
    _stick_base.custom_minimum_size = Vector2(_stick_radius * 2.4, _stick_radius * 2.4)
    _stick_base.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    _stick_base.position = Vector2(36, -260)
    add_child(_stick_base)
    var base_ring := _make_circle(_stick_radius, Color(1, 1, 1, 0.10), Color(1, 1, 1, 0.35))
    _stick_base.add_child(base_ring)
    base_ring.position = Vector2(_stick_radius * 1.2, _stick_radius * 1.2)
    _stick_nub = _make_circle(_stick_radius * 0.45, Color(1, 1, 1, 0.35), Color(1, 1, 1, 0.6))
    _stick_base.add_child(_stick_nub)
    _stick_nub.position = Vector2(_stick_radius * 1.2, _stick_radius * 1.2)
    _stick_center = Vector2(_stick_radius * 1.2, _stick_radius * 1.2)

func _make_circle(radius: float, fill: Color, border: Color) -> Control:
    var c := Control.new()
    c.custom_minimum_size = Vector2(radius * 2, radius * 2)
    c.size = c.custom_minimum_size
    c.pivot_offset = Vector2(radius, radius)
    var drawer := _CircleDrawer.new()
    drawer.radius = radius
    drawer.fill = fill
    drawer.border = border
    c.add_child(drawer)
    drawer.set_anchors_preset(Control.PRESET_FULL_RECT)
    return c

func _build_buttons() -> void:
    var col := VBoxContainer.new()
    col.name = "ActionButtons"
    col.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
    col.position = Vector2(-120, -460)
    col.add_theme_constant_override("separation", 14)
    add_child(col)
    for spec in BUTTONS:
        var b := Button.new()
        b.text = spec.label
        b.custom_minimum_size = Vector2(88, 64)
        b.modulate = Color(1, 1, 1, 0.75)
        var action: StringName = spec.action
        b.button_down.connect(func(): Input.action_press(action))
        b.button_up.connect(func(): Input.action_release(action))
        col.add_child(b)

func _layout() -> void:
    # 横屏布局：摇杆左下、按键右下（随窗口尺寸自适应）
    if _stick_base:
        _stick_base.position = Vector2(36, -260)
    var col := get_node_or_null("ActionButtons") as VBoxContainer
    if col:
        col.position = Vector2(-120, -460)

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch or event is InputEventScreenDrag:
        if not visible:
            visible = true
    if not visible:
        return
    if event is InputEventScreenTouch:
        _on_touch(event)
    elif event is InputEventScreenDrag:
        _on_drag(event)

func _on_touch(event: InputEventScreenTouch) -> void:
    var local := _stick_base.get_global_transform_with_canvas().affine_inverse() * event.position
    if event.pressed:
        if _stick_touch == -1 and _stick_base.get_global_rect().grow(40).has_point(event.position):
            _stick_touch = event.index
            _drag_stick(local)
    else:
        if event.index == _stick_touch:
            _stick_touch = -1
            _stick_nub.position = _stick_center
            _release_move()

func _on_drag(event: InputEventScreenDrag) -> void:
    if event.index != _stick_touch:
        return
    var local := _stick_base.get_global_transform_with_canvas().affine_inverse() * event.position
    _drag_stick(local)

func _drag_stick(local: Vector2) -> void:
    var offset := local - _stick_center
    if offset.length() > _stick_radius:
        offset = offset.normalized() * _stick_radius
    _stick_nub.position = _stick_center + offset
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
    for a in [&"move_left", &"move_right", &"move_up", &"move_down"]:
        Input.action_release(a)

func _update_visibility() -> void:
    visible = OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios") \
        or DisplayServer.is_touchscreen_available() \
        or ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse", false)

class _CircleDrawer extends Control:
    var radius := 40.0
    var fill := Color(1, 1, 1, 0.1)
    var border := Color(1, 1, 1, 0.35)

    func _draw() -> void:
        draw_circle(Vector2(radius, radius), radius, fill)
        draw_arc(Vector2(radius, radius), radius, 0, TAU, 48, border, 2.0)
