class_name UnifiedLevelManager
extends Node2D

signal level_completed(payload: Dictionary)
signal event_failed(fail_code: StringName)
signal suspicion_changed(value: float)

@export var level_data: LevelData

var cat: CatController
var ninja: NinjaController
var guards: Array[Node] = []
var dog: DogController
var boss: BossController
var event_root: Node2D

var status_label: Label
var event_label: Label
var timer_label: Label
var state_label: Label
var carry_label: Label
var suspicion_label: Label
var stamina_label: Label
var paw_label: Label
var help_label: Label
var toast_label: Label

var world_state := WorldState.new()
var event_log := EventLog.new()
var score_system := ScoreSystem.new()
var validator := LevelValidator.new()
var event_nodes: Array[UnifiedEventPoint] = []
var active_main_event_index := 0
var level_finished := false
var level_failed := false
var start_time := 0.0
var suspicion := 0.0
var max_suspicion := 0.0
var high_risk_rescue := 0
var chain_rescue := 0
var shortcut_mastery := false
var previous_event_id: StringName = &""

# Boss integration
var boss_started := false
var boss_mechanics_success := 0
var emergency_available := false
var emergency_used := false

const SUSPICION_NOTICE := 25.0
const SUSPICION_ALERT := 50.0
const SUSPICION_HIGH := 80.0
const EMERGENCY_POS := Vector2(930, 290)

func _ready() -> void:
    _cache_nodes()
    _setup_floor()
    var errors := validator.validate_level(level_data)
    if not errors.is_empty():
        _set_label(status_label, "VALIDATION ERROR: " + ", ".join(errors))
        set_process(false)
        return
    start_time = Time.get_ticks_msec() / 1000.0
    ninja.setup(level_data.ninja_route, self)
    if cat:
        cat.meow_triggered.connect(_on_cat_meow)
        cat.emote_triggered.connect(_on_cat_emote)
        cat.action_started.connect(_on_cat_action_started)
    if boss:
        boss.setup(self)
        boss.phase_changed.connect(_on_boss_phase)
        boss.defeated.connect(_on_boss_defeated)
        boss.retreat.connect(_on_boss_retreat)
    _build_events()
    _place_guards_and_dog()
    _set_label(status_label, "%s · %s" % [String(level_data.chapter_id), level_data.display_name])
    _set_label(help_label, "移动 / 疾跑 / 互动 / 叼取放置 / 喵叫 / 卖萌 / 重开")
    _show_toast("先观察，再让事情按你的顺序发生。")
    _play_chapter_music()
    GlobalAudioManager.play_event_sfx("read_map")
    if dog != null and not dog.barked.is_connected(_on_dog_barked):
        dog.barked.connect(_on_dog_barked)
    _setup_global_ui()
    _update_hud()
    queue_redraw()

func _setup_global_ui() -> void:
    var ui: UIManager = preload("res://scenes/ui/global_ui.tscn").instantiate()
    add_child(ui)
    ui.suspicion_eye = ui.get_node_or_null("HUD/TopBar/SuspicionEye")
    ui.ninja_locator = ui.get_node_or_null("HUD/NinjaLocator")
    ui.interaction_prompt = ui.get_node_or_null("HUD/BottomBar/InteractPrompt")
    ui.failure_panel = ui.get_node_or_null("FailureDiagnostic")
    ui.result_panel = ui.get_node_or_null("ResultPanel")
    ui.tutorial_director = ui.get_node_or_null("TutorialDirector")
    ui.bind_level(self)
    ui.bind_ninja(ninja)
    add_child(TouchControls.new())

func _play_chapter_music() -> void:
    match String(level_data.chapter_id):
        "CH01": GlobalAudioManager.set_music_state("VILLAGE_CALM")
        "CH02": GlobalAudioManager.set_music_state("DOCK_CALM")
        "CH03": GlobalAudioManager.set_music_state("CASTLE_CALM")

func _on_dog_barked() -> void:
    GlobalAudioManager.play_event_sfx("dog")

func _setup_floor() -> void:
    # 章节主题地面：村庄草地 / 码头泥土 / 城堡暗石板（素材包切块平铺）
    var floor_rect := TextureRect.new()
    floor_rect.name = "Floor"
    floor_rect.stretch_mode = TextureRect.STRETCH_TILE
    floor_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    floor_rect.position = Vector2.ZERO
    floor_rect.size = Vector2(1100, 680)
    floor_rect.z_index = -100
    match String(level_data.chapter_id):
        "CH02":
            floor_rect.texture = load("res://assets/tilesets/ground_dock.png")
        "CH03":
            floor_rect.texture = load("res://assets/tilesets/ground_castle.png")
            floor_rect.modulate = Color(0.38, 0.4, 0.52)
        _:
            floor_rect.texture = load("res://assets/tilesets/ground_village.png")
    add_child(floor_rect)

func _cache_nodes() -> void:
    cat = get_node_or_null("Cat") as CatController
    ninja = get_node_or_null("Ninja") as NinjaController
    event_root = get_node_or_null("Events") as Node2D
    dog = get_node_or_null("Dog") as DogController
    boss = get_node_or_null("Boss") as BossController
    status_label = get_node_or_null("UI/Status") as Label
    event_label = get_node_or_null("UI/Event") as Label
    timer_label = get_node_or_null("UI/Timer") as Label
    state_label = get_node_or_null("UI/State") as Label
    carry_label = get_node_or_null("UI/Carry") as Label
    suspicion_label = get_node_or_null("UI/Suspicion") as Label
    stamina_label = get_node_or_null("UI/Stamina") as Label
    paw_label = get_node_or_null("UI/Paws") as Label
    help_label = get_node_or_null("UI/Help") as Label
    toast_label = get_node_or_null("UI/Toast") as Label
    for child in get_children():
        if child.name.begins_with("Guard"):
            guards.append(child)

func _build_events() -> void:
    event_nodes.clear()
    if event_root == null:
        event_root = Node2D.new()
        event_root.name = "Events"
        add_child(event_root)
    for child in event_root.get_children():
        child.queue_free()
    for data in level_data.events:
        var point := UnifiedEventPoint.new()
        var idx := clampi(data.route_index, 0, level_data.ninja_route.waypoints.size() - 1)
        point.position = level_data.ninja_route.waypoints[idx]
        point.setup(data, self)
        point.resolved.connect(event_resolved)
        point.failed.connect(_on_event_failed)
        event_root.add_child(point)
        event_nodes.append(point)

func _place_guards_and_dog() -> void:
    var guard_i := 0
    for data in level_data.events:
        if data.event_type == &"GUARD" and guard_i < guards.size():
            var center := level_data.ninja_route.waypoints[clamp(data.route_index, 0, level_data.ninja_route.waypoints.size() - 1)] + Vector2(0, 70)
            var guard := guards[guard_i]
            if guard.has_method("setup"):
                guard.call("setup", center)
            guard_i += 1
    if dog and dog.global_position == Vector2.ZERO:
        dog.setup(Vector2(520, 465))

func is_event_active(data: EventPointData) -> bool:
    if data.activation_flag != &"" and not world_state.get_flag(data.activation_flag):
        return false
    if data.activation_phase != 0:
        if boss == null or boss.phase != data.activation_phase:
            return false
    if data.event_group == &"BOSS_COMBAT":
        return boss != null and boss_started
    return true

func is_ninja_at_blocking_event(route_index: int) -> bool:
    var current := _current_main_event()
    if current == null or current.data.non_blocking or current.data.event_group != &"MAIN":
        return false
    return route_index >= current.data.route_index and not current.resolved_state

func on_player_action_started(data: EventPointData, action_id: StringName) -> void:
    if boss != null and data.event_group == &"BOSS_COMBAT" and boss.phase != 2:
        return
    _apply_suspicion(EventBehaviorRegistry.suspicion_for(data), action_id)
    event_log.append_event({"event_id": data.event_id, "action": action_id, "success": true, "suspicion": suspicion})

func on_player_action_cancelled(_data: EventPointData) -> void:
    pass

func _on_cat_action_started(action_id: StringName) -> void:
    if action_id in [&"BITE", &"PUSH"]:
        _apply_suspicion(15.0, action_id)

func _on_cat_meow() -> void:
    if level_finished or level_failed:
        return
    for guard in guards:
        if guard == null:
            continue
        if guard.has_method("distract"):
            guard.call("distract", cat.global_position)
        elif guard.has_method("depart"):
            guard.call("depart", cat.global_position)
    var current := _current_main_event()
    if current != null and current.data.event_type == &"GUARD" and cat.global_position.distance_to(current.global_position) <= 150.0:
        current.resolve(&"MEOW")
    event_log.append_event({"event_id": &"CAT_MEOW", "action": &"MEOW", "success": true})

func _on_cat_emote() -> void:
    if level_finished or level_failed:
        return
    if ninja != null and ninja.global_position.distance_to(cat.global_position) <= 150.0:
        var before := suspicion
        suspicion = 0.0
        event_log.append_event({"event_id": &"CAT_EMOTE", "action": &"EMOTE", "success": true, "suspicion_before": before, "suspicion_after": suspicion})
        GlobalAudioManager.play_event_sfx("emote")
        _show_toast("卖萌成功，怀疑清零。")

func _apply_suspicion(amount: float, source: StringName) -> void:
    var before := suspicion
    suspicion = clamp(suspicion + amount, 0.0, 100.0)
    max_suspicion = max(max_suspicion, suspicion)
    event_log.append_event({"event_id": &"SUSPICION", "action": source, "success": true, "suspicion_before": before, "suspicion_after": suspicion})
    suspicion_changed.emit(suspicion)
    if suspicion >= 100.0:
        level_failed = true
        event_failed.emit(&"FAIL_SUSPICION")
        _set_label(status_label, "任务失败：被忍者发现你在搞事情。R 重开")

func event_resolved(data: EventPointData, action_id: StringName) -> void:
    if level_failed or level_finished:
        return
    for flag in data.success_flags:
        world_state.set_flag(flag)
    _apply_event_side_effect(data, action_id)
    event_log.append_event({"event_id": data.event_id, "action": action_id, "success": true, "risk_level": data.risk_level, "high_risk": data.high_risk, "tags": data.banter_tags})
    if previous_event_id != &"":
        chain_rescue += 1
    previous_event_id = data.event_id
    if data.high_risk:
        high_risk_rescue += 1
    if action_id in [&"MEOW", &"FEED"]:
        shortcut_mastery = true
    if data.event_group == &"MAIN" and _find_main_event_index(data.event_id) == active_main_event_index:
        active_main_event_index += 1
        if ninja:
            ninja.release_event()
    GlobalAudioManager.play_event_sfx("success")
    _show_toast("处理成功：%s" % data.display_name)

func _apply_event_side_effect(data: EventPointData, action_id: StringName) -> void:
    # Flags remain declarative facts; non-trivial behavior is expressed by EventEffectData.
    for effect_resource in data.success_effects:
        var effect := effect_resource as EventEffectData
        if effect == null:
            continue
        _apply_effect(effect)
    if data.consume_carry_item != &"" and cat != null and cat.carry_item == data.consume_carry_item:
        cat.carry_item = &""

func _apply_effect(effect: EventEffectData) -> void:
    match effect.effect_type:
        &"GUARD_DISTRACT":
            for guard in guards:
                if guard == null:
                    continue
                if guard.has_method("distract"):
                    guard.call("distract", cat.global_position if cat else global_position)
                elif guard.has_method("depart"):
                    guard.call("depart", cat.global_position if cat else global_position)
        &"DOG_LURE":
            if dog and cat:
                dog.lure_to(cat.global_position + Vector2(120, 0))
        &"BOSS_PREPARE_DAMAGE":
            if boss:
                boss.prepare(int(effect.amount))
                boss_mechanics_success += 1
        &"BOSS_COMBAT_DAMAGE":
            if boss and boss.phase == effect.phase_required:
                boss.damage(int(effect.amount), effect.effect_type)
                boss_mechanics_success += 1
                high_risk_rescue += 1
        _:
            pass

func _on_event_failed(data: EventPointData, code: StringName) -> void:
    if level_failed or level_finished:
        return
    level_failed = true
    if ninja:
        ninja.take_damage(1)
    for flag in data.failure_flags:
        world_state.set_flag(flag)
    event_log.append_event({"event_id": data.event_id, "action": &"FAIL", "success": false, "fail_code": code})
    GlobalAudioManager.play_event_sfx("fail")
    event_failed.emit(code)
    _set_label(status_label, "任务失败：%s    R 重开" % String(code))
    _show_toast(_fail_reason(code))

func _current_main_event() -> UnifiedEventPoint:
    var i := 0
    for node in event_nodes:
        if node.data.event_group == &"MAIN":
            if i == active_main_event_index:
                return node
            i += 1
    return null

func _find_main_event_index(event_id: StringName) -> int:
    var i := 0
    for node in event_nodes:
        if node.data.event_group != &"MAIN":
            continue
        if node.data.event_id == event_id:
            return i
        i += 1
    return -1

func ninja_reached_goal() -> void:
    if boss != null and not boss_started:
        _start_boss_sequence()
        return
    if _current_main_event() != null:
        return
    if boss != null and boss.active:
        return
    _complete_level(false)

func _start_boss_sequence() -> void:
    if boss == null or boss_started:
        return
    boss_started = true
    world_state.set_flag(&"boss_started")
    GlobalAudioManager.set_music_state("BOSS_PREPARE")
    boss.start_boss()
    _show_toast("Boss 出现！战场还没有结束。")
    event_log.append_event({"event_id": &"BOSS_START", "action": &"START", "success": true})

func _on_boss_phase(phase: int) -> void:
    world_state.set_flag(&"boss_phase_%d" % phase)
    if phase >= 1 and phase <= 3:
        GlobalAudioManager.set_music_state("BOSS_PHASE_%d" % phase)
    if phase == 2:
        _show_toast("Boss 开始冲锋！现在处理蒺藜。")
    elif phase == 3:
        if boss_mechanics_success == 0:
            emergency_available = true
            _show_toast("危险！赶去应急门救场。")

func _on_boss_defeated() -> void:
    boss_started = false
    GlobalAudioManager.set_music_state("BOSS_DEFEAT")
    _complete_level(false)

func _on_boss_retreat() -> void:
    boss_started = false
    _complete_level(emergency_used)

func can_boss_finish() -> bool:
    return boss_mechanics_success > 0 or emergency_used

func _try_emergency() -> void:
    if not emergency_available or emergency_used or boss == null:
        return
    if cat.global_position.distance_to(EMERGENCY_POS) <= 60.0 and Input.is_action_pressed("interact"):
        emergency_used = true
        emergency_available = false
        if ninja:
            ninja.hp = max(1, ninja.hp)
        boss.retreat.emit()
        event_log.append_event({"event_id": &"EMERGENCY_RESCUE", "action": &"EMERGENCY", "success": true, "ninja_hp_after": ninja.hp})

func _complete_level(emergency: bool) -> void:
    if level_finished:
        return
    level_finished = true
    var elapsed := Time.get_ticks_msec() / 1000.0 - start_time
    var paws := 1
    if not emergency:
        paws = score_system.evaluate(true, ninja.hp, max_suspicion, elapsed, high_risk_rescue, chain_rescue, shortcut_mastery, level_data.target_time)
    _set_label(paw_label, "猫爪：%d / 3" % paws)
    _set_label(status_label, "任务完成！忍者：‘果然是我实力超群。’")
    _show_toast("按 Space 进入下一关。" if not level_data.next_scene_path.is_empty() else "第一章的真相：都是你干的。")
    event_log.append_event({"event_id": &"GOAL", "action": &"COMPLETE", "success": true, "paws": paws, "emergency": emergency})
    level_completed.emit({
        "level_id": String(level_data.level_id),
        "paws": paws,
        "mission_complete": true,
        "ninja_hp": ninja.hp if ninja else 0,
        "max_suspicion": max_suspicion,
        "elapsed_time": elapsed,
        "high_risk_rescue": high_risk_rescue,
        "chain_rescue": chain_rescue,
        "emergency": emergency,
    })

func on_ninja_dead() -> void:
    level_failed = true
    _set_label(status_label, "任务失败：NINJA_DEATH    R 重开")

func _process(_delta: float) -> void:
    if not level_finished and not level_failed:
        _try_emergency()
        var elapsed := Time.get_ticks_msec() / 1000.0 - start_time
        _set_label(timer_label, "时间 %.1fs" % elapsed)
        _set_label(carry_label, "口中：" + (String(cat.carry_item) if cat and cat.carry_item != &"" else "空"))
        _set_label(suspicion_label, _suspicion_text())
        _update_hud()
    elif level_finished:
        if Input.is_action_pressed("retry"):
            get_tree().reload_current_scene()
        elif Input.is_action_pressed("confirm") and not level_data.next_scene_path.is_empty():
            get_tree().change_scene_to_file(level_data.next_scene_path)
    elif level_failed and Input.is_action_pressed("retry"):
        get_tree().reload_current_scene()

func _suspicion_text() -> String:
    if suspicion < SUSPICION_NOTICE: return "猫眼：○ 正常"
    if suspicion < SUSPICION_ALERT: return "猫眼：◐ 注意"
    if suspicion < SUSPICION_HIGH: return "猫眼：◑ 警觉"
    return "猫眼：● 高危"

func _fail_reason(code: StringName) -> String:
    match code:
        &"FAIL_TOO_LATE": return "处理得太晚了。"
        &"FAIL_WRONG_ORDER": return "顺序错了，后面的窗口被改变了。"
        &"FAIL_SUSPICION": return "忍者确认猫在搞事情。"
        &"FAIL_BOSS_FINISHER": return "Boss 已经完成最后一击。"
        _: return "事件没有按预期处理。"

func _show_toast(message: String) -> void:
    _set_label(toast_label, message)

func _set_label(label: Label, value: String) -> void:
    if label != null:
        label.text = value

func _update_hud() -> void:
    if paw_label != null and not level_finished:
        paw_label.text = "猫爪：— / 3"
    if state_label != null:
        state_label.text = "事件 %d/%d | Boss %s | 机关 %d | 应急 %s" % [active_main_event_index, _main_event_count(), "已启动" if boss_started else "未启动", boss_mechanics_success, "可用" if emergency_available else "—"]
    if stamina_label != null and cat:
        stamina_label.text = "体力 %03d" % int(cat.stamina)

func _main_event_count() -> int:
    var n := 0
    for node in event_nodes:
        if node.data.event_group == &"MAIN": n += 1
    return n

func _draw() -> void:
    # 外框压暗 + 游玩区域描边（地面纹理由 Floor 节点平铺）
    draw_rect(Rect2(40, 115, 1020, 500), Color(0, 0, 0, 0.18))
    draw_rect(Rect2(40, 115, 1020, 500), Color(1, 1, 1, 0.12), false, 2.0)
    if boss_started:
        draw_circle(EMERGENCY_POS, 24.0, Color(0.9, 0.2, 0.2, 0.15))
        draw_arc(EMERGENCY_POS, 28.0, 0.0, TAU, 32, Color("#f87171"), 2.0)
