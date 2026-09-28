class_name UIManager
extends CanvasLayer

signal tutorial_requested(tutorial_id: String)
signal result_requested(result_payload: Dictionary)
signal failure_requested(fail_code: String)

@export var tutorial_director: Node
@export var suspicion_eye: Node
@export var ninja_locator: Node
@export var interaction_prompt: Node
@export var result_panel: Node
@export var failure_panel: Node

func _ready() -> void:
    var input_manager := get_node_or_null("/root/GameInputManager")
    if input_manager != null and not input_manager.device_changed.is_connected(_on_input_device_changed):
        input_manager.device_changed.connect(_on_input_device_changed)
    _refresh_input_hints()

func bind_level(level_manager: Node) -> void:
    if level_manager == null:
        return
    if level_manager.has_signal("event_failed"):
        level_manager.event_failed.connect(_on_event_failed)
    if level_manager.has_signal("level_completed"):
        level_manager.level_completed.connect(_on_level_completed)
    if level_manager.has_signal("suspicion_changed"):
        level_manager.suspicion_changed.connect(_on_suspicion_changed)

func bind_cat(cat: Node) -> void:
    if cat == null:
        return
    if cat.has_signal("suspicion_changed"):
        cat.suspicion_changed.connect(_on_suspicion_changed)
    if cat.has_signal("interaction_changed"):
        cat.interaction_changed.connect(_on_interaction_changed)
    if cat.has_signal("carry_changed"):
        cat.carry_changed.connect(_on_carry_changed)

func bind_ninja(ninja: Node) -> void:
    if ninja == null:
        return
    if ninja_locator != null and ninja_locator.has_method("bind_ninja"):
        ninja_locator.bind_ninja(ninja)
    if ninja.has_signal("mood_changed"):
        ninja.mood_changed.connect(_on_ninja_mood_changed)

func _on_suspicion_changed(value: float) -> void:
    if suspicion_eye != null and suspicion_eye.has_method("set_suspicion"):
        suspicion_eye.set_suspicion(value)

func _on_interaction_changed(action_name: String, enabled: bool) -> void:
    if interaction_prompt != null and interaction_prompt.has_method("set_action"):
        interaction_prompt.set_action(action_name, enabled)

func _on_carry_changed(item_id: String) -> void:
    if interaction_prompt != null and interaction_prompt.has_method("set_carry"):
        interaction_prompt.set_carry(item_id)

func _on_ninja_mood_changed(mood: String) -> void:
    var mood_bubble := get_node_or_null("HUD/TopBar/NinjaMoodBubble")
    if mood_bubble != null and mood_bubble.has_method("set_mood"):
        mood_bubble.set_mood(mood)

func _on_event_failed(fail_code: String) -> void:
    failure_requested.emit(fail_code)
    if failure_panel != null and failure_panel.has_method("show_failure"):
        failure_panel.show_failure(fail_code)

func _on_level_completed(payload: Dictionary) -> void:
    result_requested.emit(payload)
    if result_panel != null and result_panel.has_method("show_result"):
        result_panel.show_result(payload)


func _on_input_device_changed(_device: String) -> void:
    _refresh_input_hints()

func _refresh_input_hints() -> void:
    var device_label := get_node_or_null("HUD/TopBar/DeviceIndicator") as Label
    var hint_label := get_node_or_null("HUD/BottomBar/ControlHints") as Label
    var input_manager := get_node_or_null("/root/GameInputManager")
    var device: String = input_manager.last_device if input_manager != null else GameInputManager.DEVICE_KEYBOARD_MOUSE
    if device_label != null:
        device_label.text = InputDisplay.get_device_name(device)
    if hint_label != null:
        hint_label.visible = device != GameInputManager.DEVICE_TOUCH
        hint_label.text = "移动 %s   互动 %s   叼取 %s   喵叫 %s   卖萌 %s   跳跃 %s   暂停 %s" % [
            InputDisplay.get_binding_label(&"move_up"),
            InputDisplay.get_binding_label(&"interact"),
            InputDisplay.get_binding_label(&"carry"),
            InputDisplay.get_binding_label(&"meow"),
            InputDisplay.get_binding_label(&"emote"),
            InputDisplay.get_binding_label(&"jump"),
            InputDisplay.get_binding_label(&"pause"),
        ]
