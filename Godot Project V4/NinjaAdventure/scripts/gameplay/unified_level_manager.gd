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

# L05 dock progression: Guard A departure opens a timed Guard B rotation.
var l05_guard_a_depart_time := -1.0
var l05_poisoned := false
var l05_poison_tick_timer := 5.0
var l05_guard_b_activated := false

# L06 dog ally progression
var l06_dog_guard_target := -1
var l06_dog_help_pending := false

# L07 dependency chain: Guard A -> (+8s) -> Guard B -> Dog route -> Bridge/Poison.
var l07_guard_a_depart_time := -1.0
var l07_guard_b_activated := false
var l07_b_was_early := false
var l07_dog_route_pending := false
var l07_bridge_open := false

# L08 integrated chapter-end combo: Guard A -> Dog ally -> Dog assists Guard B -> Poison -> Caltrop -> Bridge.
var l08_dog_assist_pending := false
var l08_bridge_open := false

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
    save_manager = SaveManagerClass.new()
    add_child(save_manager)
    talent_tracker = TalentTrackerClass.new()
    add_child(talent_tracker)
    _setup_floor()
    _setup_layout_geometry()
    _setup_layout_design()
    _setup_shortcuts()
    _setup_l03_suspicion()
    _setup_l05_carry_items()
    _setup_l06_dog_ally()
    _setup_l07_dependency_chain()
    _setup_l08_combo()
    _setup_l09_storm()
    _setup_l10_chain()
    _setup_l11_busy_gate()
    _setup_decorations()
    var errors := validator.validate_level(level_data)
    if not errors.is_empty():
        _set_label(status_label, "VALIDATION ERROR: " + ", ".join(errors))
        set_process(false)
        return
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
    if dog != null and not dog.arrived_at_target.is_connected(_on_l06_dog_arrived):
        dog.arrived_at_target.connect(_on_l06_dog_arrived)
    if dog != null and not dog.arrived_at_target.is_connected(_on_l07_dog_arrived):
        dog.arrived_at_target.connect(_on_l07_dog_arrived)
    if dog != null and not dog.arrived_at_target.is_connected(_on_l08_dog_arrived):
        dog.arrived_at_target.connect(_on_l08_dog_arrived)
    if dog != null and not dog.arrived_at_target.is_connected(_on_l10_dog_arrived):
        dog.arrived_at_target.connect(_on_l10_dog_arrived)
    # L11 uses the dog as a timed diversion, not as an ally state.
    _setup_global_ui()
    _update_hud()
    queue_redraw()
    _start_reading_tour()

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
    _setup_pause(ui)

func _setup_pause(ui: UIManager) -> void:
    var pause := PauseController.new()
    pause.process_mode = Node.PROCESS_MODE_ALWAYS
    add_child(pause)
    var overlay := ui.get_node_or_null("PauseOverlay")
    if overlay != null:
        overlay.process_mode = Node.PROCESS_MODE_ALWAYS
        pause.pause_changed.connect(func(paused: bool): overlay.visible = paused)

func _play_chapter_music() -> void:
    match String(level_data.chapter_id):
        "CH01": GlobalAudioManager.set_music_state("VILLAGE_CALM")
        "CH02": GlobalAudioManager.set_music_state("DOCK_CALM")
        "CH03": GlobalAudioManager.set_music_state("CASTLE_CALM")

func _on_dog_barked() -> void:
    GlobalAudioManager.play_event_sfx("dog")

# 读图镜头巡游（GDD §2.1）：开场推进到每个主线事件点，再拉回全景；按互动/确认跳过
var reading_phase := false
var _tour_tween: Tween
var _cam: Camera2D
var save_manager: SaveManagerClass
var talent_tracker: TalentTrackerClass
var suspicion_observer: SuspicionObserver
var emote_safe_zone: EmoteSafeZone
var carry_visual: Sprite2D
var l09_storm_fx: L09StormFX
var l10_late_antidote: CarryPickup
var l10_dog_pending := false
var l10_caltrop_armed := false
var l10_caltrop_deadline := -1.0
var l10_caltrop_cleared := false
var l10_guard_a_shifted := false
var l10_guard_a_departed := false
var l10_guard_a_stays := false
var l10_poison_forced := false
var l10_route_mode: StringName = &"STANDARD"

# L11 multi-thread pressure: the Ninja keeps moving while side hazards arm on parallel timers.
var l11_dynamite_window := -1.0
var l11_dynamite_missed := false
var l11_guard_b_window := -1.0
var l11_guard_b_urgent := false
var l11_dog_diverted := false
var l11_poison_safe := false
var l11_route_busy_mode: StringName = &"DUAL_THREAD"

func _start_reading_tour() -> void:
    reading_phase = true
    _cam = Camera2D.new()
    _cam.position = Vector2(550, 340)
    add_child(_cam)
    _cam.make_current()
    _show_toast("读图：看清他的路线和沿途的危险。（互动键跳过）")
    _tour_tween = create_tween()
    _tour_tween.tween_property(_cam, "zoom", Vector2(1.7, 1.7), 0.8).set_trans(Tween.TRANS_SINE)
    for node in event_nodes:
        if node.data.event_group != &"MAIN":
            continue
        _tour_tween.tween_property(_cam, "position", node.position, 0.9).set_trans(Tween.TRANS_SINE)
        _tour_tween.tween_interval(0.6)
    _tour_tween.tween_property(_cam, "position", Vector2(550, 340), 0.8).set_trans(Tween.TRANS_SINE)
    _tour_tween.parallel().tween_property(_cam, "zoom", Vector2(1.0, 1.0), 0.8)
    _tour_tween.tween_callback(_end_reading_tour)

func _end_reading_tour() -> void:
    if not reading_phase:
        return
    reading_phase = false
    if _tour_tween != null and _tour_tween.is_running():
        _tour_tween.kill()
    if _cam != null:
        _cam.queue_free()
        _cam = null
    start_time = Time.get_ticks_msec() / 1000.0
    if level_data != null and level_data.level_id == &"L05":
        _show_toast("码头节奏：守卫 A 离岗后 8 秒，守卫 B 换岗到路线。")
    elif level_data != null and level_data.level_id == &"L11":
        _start_l11_pressure_after_reading()
        _show_toast("L11：炸药线程已经倒计时；守卫 A 处理后，右翼线程会一起启动。")
    else:
        _show_toast("他开始走了。轮到你了。")

const LAYOUT_ZONES := {
    &"L01": [[&"Start", Rect2(70, 250, 150, 270)], [&"绊绳巷", Rect2(220, 200, 260, 220)], [&"守卫广场", Rect2(430, 180, 300, 260)], [&"小水沟", Rect2(760, 250, 210, 260)], [&"Goal", Rect2(930, 250, 100, 270)]],
    &"L02": [[&"Start", Rect2(70, 220, 160, 260)], [&"Narrow Alley", Rect2(230, 200, 220, 210)], [&"Plaza", Rect2(430, 180, 250, 250)], [&"Waterline", Rect2(730, 300, 250, 220)], [&"Goal", Rect2(920, 330, 110, 180)]],
    &"L03": [[&"Start", Rect2(70, 220, 160, 240)], [&"Guard Vision", Rect2(300, 170, 260, 240)], [&"Crate Yard", Rect2(430, 320, 230, 190)], [&"Emote Shelter", Rect2(640, 330, 180, 190)], [&"Watergap", Rect2(820, 330, 170, 180)], [&"Goal", Rect2(930, 330, 100, 180)]],
    &"L04": [[&"West Gate", Rect2(70, 250, 140, 250)], [&"Guard Square", Rect2(220, 210, 220, 220)], [&"Tripwire Alley", Rect2(380, 220, 240, 180)], [&"Crate Yard", Rect2(500, 380, 220, 180)], [&"Watergap", Rect2(740, 370, 230, 190)], [&"Goal", Rect2(930, 370, 90, 190)]],
    &"L05": [[&"Dock Start", Rect2(60, 410, 160, 180)], [&"Fish Yard", Rect2(190, 210, 260, 190)], [&"Guard A", Rect2(370, 190, 240, 180)], [&"Dog Yard", Rect2(420, 360, 210, 170)], [&"Broken Bridge", Rect2(620, 370, 180, 170)], [&"Poison Marsh", Rect2(740, 210, 210, 180)], [&"Guard B", Rect2(830, 360, 170, 170)], [&"Goal Boat", Rect2(910, 240, 120, 200)]],
    &"L06": [[&"Start", Rect2(60, 420, 150, 180)], [&"Fish Source", Rect2(190, 210, 230, 180)], [&"Guard Square", Rect2(470, 190, 250, 190)], [&"Dog Pen", Rect2(330, 360, 220, 180)], [&"Bridge Fork", Rect2(690, 360, 230, 180)], [&"Goal", Rect2(910, 220, 120, 220)]],
    &"L07": [[&"Start", Rect2(60, 390, 160, 190)], [&"Fish Yard", Rect2(190, 260, 220, 180)], [&"Guard A", Rect2(370, 140, 180, 170)], [&"Guard B", Rect2(560, 140, 190, 170)], [&"Dog Yard", Rect2(330, 390, 220, 150)], [&"Bridge", Rect2(680, 270, 180, 180)], [&"Poison", Rect2(790, 170, 180, 160)], [&"Goal", Rect2(900, 300, 120, 190)]],
    &"L08": [[&"Start", Rect2(60, 410, 150, 180)], [&"Fish/Crate Yard", Rect2(180, 280, 230, 180)], [&"Guard A Pier", Rect2(370, 180, 190, 180)], [&"Dog Yard", Rect2(300, 380, 220, 170)], [&"Broken Bridge", Rect2(560, 370, 180, 170)], [&"Poison Marsh", Rect2(560, 180, 220, 170)], [&"Guard B Jetty", Rect2(750, 350, 190, 160)], [&"Caltrop Dock", Rect2(690, 240, 210, 150)], [&"Final Boat", Rect2(880, 220, 130, 210)]],
    &"L09": [[&"R0 南侧入口", Rect2(70, 430, 180, 150)], [&"R1 雨巷", Rect2(180, 300, 360, 220)], [&"R2 木箱堆场", Rect2(380, 220, 280, 190)], [&"R3 炸药区", Rect2(540, 180, 230, 190)], [&"R4 北门守卫区", Rect2(700, 220, 250, 220)], [&"R5 内城入口", Rect2(880, 250, 150, 230)]],
    &"L10": [[&"R0 西门", Rect2(70, 430, 160, 150)], [&"R1 炸药仓", Rect2(200, 290, 250, 220)], [&"R2 中庭", Rect2(390, 360, 250, 190)], [&"R3 Guard A", Rect2(530, 210, 250, 220)], [&"R4 Dog 院", Rect2(690, 370, 200, 170)], [&"R5 Poison Corridor", Rect2(780, 210, 190, 180)], [&"R6 东门", Rect2(900, 170, 130, 180)]],
    &"L11": [[&"Guard A", Rect2(260, 170, 230, 170)], [&"Guard B", Rect2(650, 120, 220, 170)], [&"Central", Rect2(430, 280, 260, 180)], [&"Dog Yard", Rect2(280, 430, 220, 150)], [&"Dynamite", Rect2(500, 440, 200, 140)], [&"Poison", Rect2(760, 260, 200, 160)], [&"Goal", Rect2(900, 120, 150, 160)]],
    &"L12": [[&"R0 Approach", Rect2(60, 430, 220, 160)], [&"R1 Gourd Platform", Rect2(180, 260, 220, 160)], [&"R2 Crane Platform", Rect2(380, 200, 220, 160)], [&"R3 Boss Intro", Rect2(540, 250, 230, 170)], [&"R4 Charge Lane", Rect2(640, 400, 260, 150)], [&"R5 Caltrop Storage", Rect2(760, 450, 180, 130)], [&"R6 Combat Zone", Rect2(780, 220, 220, 180)], [&"R7 Emergency Door", Rect2(930, 120, 120, 140)]]
}


func _setup_layout_geometry() -> void:
    if level_data == null:
        return
    var geometry := LayoutGeometry.new()
    geometry.name = "LayoutGeometry"
    geometry.z_index = -82
    geometry.setup(level_data.level_id, level_data.ninja_route.waypoints)
    add_child(geometry)

func _setup_layout_design() -> void:
    if level_data == null or level_data.ninja_route == null:
        return
    var layout := LayoutDesign.new()
    layout.name = "LayoutDesign"
    layout.z_index = -75
    var lid := String(level_data.level_id)
    layout.setup(level_data.level_id, level_data.ninja_route.waypoints, LAYOUT_ZONES.get(lid, []))
    add_child(layout)

func _setup_l03_suspicion() -> void:
    if level_data == null or level_data.level_id != &"L03":
        return
    suspicion_observer = SuspicionObserver.new()
    suspicion_observer.name = "SuspicionObserver"
    suspicion_observer.observer_path = NodePath("../Ninja")
    suspicion_observer.subject_path = NodePath("../Cat")
    suspicion_observer.z_index = -5
    add_child(suspicion_observer)

    emote_safe_zone = EmoteSafeZone.new()
    emote_safe_zone.name = "EmoteSafeZone"
    emote_safe_zone.position = Vector2(720, 470)
    emote_safe_zone.z_index = -4
    add_child(emote_safe_zone)

func _setup_l05_carry_items() -> void:
    if level_data == null or level_data.level_id != &"L05":
        return
    var root := Node2D.new()
    root.name = "L05CarryPickups"
    add_child(root)
    var fish := CarryPickup.new()
    fish.name = "FishPickup"
    root.add_child(fish)
    fish.position = Vector2(300, 510)
    fish.setup(&"FISH", self)

    var antidote := CarryPickup.new()
    antidote.name = "AntidotePickup"
    root.add_child(antidote)
    antidote.position = Vector2(745, 235)
    antidote.setup(&"ANTIDOTE", self)

    _show_toast("Q：叼取鱼肉 / 解毒药。先看守卫 A 的换岗节奏。")

func _setup_l06_dog_ally() -> void:
    if level_data == null or level_data.level_id != &"L06":
        return
    var root := Node2D.new()
    root.name = "L06CarryPickups"
    add_child(root)
    var fish := CarryPickup.new()
    fish.name = "FishPickup"
    root.add_child(fish)
    fish.position = Vector2(250, 490)
    fish.setup(&"FISH", self)
    _show_toast("L06：Q 叼鱼肉；先和狗狗成为队友，再用 E 派狗去引开守卫。")

func _setup_l07_dependency_chain() -> void:
    if level_data == null or level_data.level_id != &"L07":
        return
    var root := Node2D.new()
    root.name = "L07CarryPickups"
    add_child(root)

    var fish := CarryPickup.new()
    fish.name = "FishPickup"
    root.add_child(fish)
    fish.position = Vector2(300, 350)
    fish.setup(&"FISH", self)

    var antidote := CarryPickup.new()
    antidote.name = "AntidotePickup"
    root.add_child(antidote)
    antidote.position = Vector2(860, 250)
    antidote.setup(&"ANTIDOTE", self)

    _show_toast("L07：先处理谁会改变后面的路线。A 离岗 8 秒后，B 才是稳定解。")

func _setup_l08_combo() -> void:
    if level_data == null or level_data.level_id != &"L08":
        return
    var root := Node2D.new()
    root.name = "L08CarryPickups"
    add_child(root)
    var fish := CarryPickup.new()
    fish.name = "FishPickup"
    root.add_child(fish)
    fish.position = Vector2(250, 500)
    fish.setup(&"FISH", self)

    var antidote := CarryPickup.new()
    antidote.name = "AntidotePickup"
    root.add_child(antidote)
    antidote.position = Vector2(610, 225)
    antidote.setup(&"ANTIDOTE", self)
    _show_toast("L08：先清守卫 A，再喂狗成为队友；然后派狗、送药、清蒺藜、放桥。")

func _l05_now() -> float:
    return Time.get_ticks_msec() / 1000.0

func _l05_guard_b_ready() -> bool:
    return l05_guard_a_depart_time >= 0.0 and _l05_now() - l05_guard_a_depart_time >= 8.0

func _update_l05_state(delta: float) -> void:
    if level_data == null or level_data.level_id != &"L05" or reading_phase or level_finished or level_failed:
        return
    if l05_guard_a_depart_time >= 0.0 and not l05_guard_b_activated and _l05_guard_b_ready():
        l05_guard_b_activated = true
        world_state.set_flag(&"L05_GUARD_B_ACTIVE")
        if guards.size() > 1 and level_data.ninja_route.waypoints.size() > 6:
            var guard_b := guards[1]
            if guard_b != null and guard_b.has_method("setup"):
                guard_b.call("setup", level_data.ninja_route.waypoints[6] + Vector2(0, 70))
        _show_toast("守卫 A 的空缺到了：B 正在 8 秒后换岗到路线上。")
        event_log.append_event({"event_id": &"L05_GUARD_B_SHIFT", "action": &"ROTATE", "success": true, "delay": 8.0})
    if l05_poisoned:
        l05_poison_tick_timer -= delta
        if l05_poison_tick_timer <= 0.0:
            l05_poison_tick_timer = 5.0
            if ninja != null and not ninja.waiting_for_event:
                ninja.take_damage(1)
                event_log.append_event({"event_id": &"L05_POISON_TICK", "action": &"POISON", "success": false, "ninja_hp": ninja.hp})
                _show_toast("毒雾发作：忍者 -1 心。")

func _update_l07_state(_delta: float) -> void:
    if level_data == null or level_data.level_id != &"L07" or reading_phase or level_finished or level_failed:
        return
    if l07_guard_a_depart_time >= 0.0 and not l07_guard_b_activated and not l07_b_was_early and _l05_now() - l07_guard_a_depart_time >= 8.0:
        l07_guard_b_activated = true
        world_state.set_flag(&"L07_GUARD_B_ACTIVE")
        if guards.size() > 1:
            var guard_b := guards[1]
            if guard_b != null:
                guard_b.call("setup", Vector2(650, 210))
        event_log.append_event({
            "event_id": &"L07_GUARD_B_SHIFT",
            "action": &"ROTATE",
            "success": true,
            "delay": 8.0,
            "world_changes": [&"guard_b_active"],
        })
        _show_toast("8 秒到了：守卫 B 稳定换岗。现在处理不会改变后续路线。")

func _setup_shortcuts() -> void:
    if level_data == null:
        return
    var nav := Node2D.new()
    nav.name = "Navigation"
    nav.z_index = -30
    add_child(nav)
    var tunnel_root := Node2D.new()
    tunnel_root.name = "CatTunnel"
    nav.add_child(tunnel_root)
    var jump_root := Node2D.new()
    jump_root.name = "JumpPoints"
    nav.add_child(jump_root)

    var lid := String(level_data.level_id)
    if lid in ["L01", "L02", "L03", "L04", "L06", "L07", "L08", "L10", "L11"]:
        var layout_id := StringName(lid)
        var layout: Dictionary = LayoutGeometry.LEVEL_LAYOUTS.get(layout_id, {})
        if lid == "L01":
            for rect_variant in layout.get("tunnels", []):
                var rect: Rect2 = rect_variant
                var tunnel := CatTunnel.new()
                tunnel.name = "CatTunnel_%02d" % tunnel_root.get_child_count()
                tunnel_root.add_child(tunnel)
                var entry := Vector2(rect.position.x + 18.0, rect.get_center().y)
                var exit := Vector2(rect.end.x - 18.0, rect.get_center().y)
                tunnel.setup(entry, exit, Vector2(maxf(72.0, minf(rect.size.x, 150.0)), maxf(28.0, rect.size.y)))
                tunnel.used.connect(_on_shortcut_used)

            # L01 白盒指定的唯一 JumpPoint：仍在 E01 之前。
            var jump := JumpPoint.new()
            jump.name = "JumpPoint_L01_01"
            jump_root.add_child(jump)
            jump.setup(Vector2(270, 430), Vector2(330, 360))
            jump.used.connect(_on_shortcut_used)
        elif lid == "L02":
            # L02 白盒：Start Side → CatTunnel → JumpPoint → Plaza Backside。
            # 只缩短猫的移动，不改 Ninja Route，也不跳过主线事件。
            var tunnel := CatTunnel.new()
            tunnel.name = "CatTunnel_L02_01"
            tunnel_root.add_child(tunnel)
            tunnel.setup(Vector2(230, 500), Vector2(420, 500), Vector2(160, 34))
            tunnel.used.connect(_on_shortcut_used)

            var jump := JumpPoint.new()
            jump.name = "JumpPoint_L02_01"
            jump_root.add_child(jump)
            jump.setup(Vector2(455, 500), Vector2(500, 320))
            jump.used.connect(_on_shortcut_used)
        elif lid == "L03":
            # L03 白盒指定的 T：使用布局定义的垂直猫洞，连接木箱区与卖萌区。
            # 只缩短猫的移动，不跳过 E01/E02/E03/E04。
            var l03_tunnels: Array = layout.get("tunnels", [])
            for i in range(l03_tunnels.size()):
                var rect: Rect2 = l03_tunnels[i]
                var tunnel := CatTunnel.new()
                tunnel.name = "CatTunnel_L03_%02d" % (i + 1)
                tunnel_root.add_child(tunnel)
                var entry := Vector2(rect.get_center().x, rect.end.y - 18.0)
                var exit := Vector2(rect.get_center().x, rect.position.y + 18.0)
                tunnel.setup(entry, exit, Vector2(maxf(34.0, rect.size.x), maxf(72.0, minf(rect.size.y, 170.0))))
                tunnel.used.connect(_on_shortcut_used)
        elif lid == "L04":
            # Route B 的猫专用捷径：Guard + Tripwire 完成后，利用既有白盒猫洞快速抵达水沟准备区。
            # Route A 则选择叼箱；两条路线最终在 E04 汇合。
            var l04_tunnels: Array = layout.get("tunnels", [])
            if not l04_tunnels.is_empty():
                var rect: Rect2 = l04_tunnels[0]
                var tunnel := CatTunnel.new()
                tunnel.name = "CatTunnel_L04_01"
                tunnel_root.add_child(tunnel)
                var entry := Vector2(rect.position.x + 18.0, rect.get_center().y)
                var exit := Vector2(rect.end.x - 18.0, rect.get_center().y)
                tunnel.setup(entry, exit, Vector2(maxf(72.0, minf(rect.size.x, 210.0)), maxf(28.0, rect.size.y)))
                tunnel.used.connect(_on_shortcut_used)

        elif lid == "L06":
            # 预位捷径：只缩短猫到狗区的移动，不跳过任何主线事件。
            var tunnel := CatTunnel.new()
            tunnel.name = "CatTunnel_L06_01"
            tunnel_root.add_child(tunnel)
            tunnel.setup(Vector2(432, 437), Vector2(523, 437), Vector2(92, 30))
            tunnel.used.connect(_on_shortcut_used)
        elif lid == "L07":
            # L07 风险解专用捷径：让猫先到桥侧，但不改变 Ninja 的固定路线。
            var tunnel := CatTunnel.new()
            tunnel.name = "CatTunnel_L07_01"
            tunnel_root.add_child(tunnel)
            tunnel.setup(Vector2(430, 487), Vector2(625, 487), Vector2(165, 32))
            tunnel.used.connect(_on_shortcut_used)
        elif lid == "L08":
            # L08 码头末班船捷径：猫从鱼场下沿直接切到毒雾前场，减少赶场距离，但不改变 Ninja Route。
            var tunnel := CatTunnel.new()
            tunnel.name = "CatTunnel_L08_01"
            tunnel_root.add_child(tunnel)
            tunnel.setup(Vector2(250, 530), Vector2(520, 410), Vector2(180, 34))
            tunnel.used.connect(_on_shortcut_used)
        elif lid == "L10":
            # L10 RoofJump：炸药仓顶部 → 狗院，仅缩短猫赶场时间，不改变 Ninja 路线。
            var jump := JumpPoint.new()
            jump.name = "JumpPoint_L10_01"
            jump_root.add_child(jump)
            jump.setup(Vector2(330, 300), Vector2(700, 410))
            jump.used.connect(_on_shortcut_used)
        elif lid == "L11":
            # L11 CatTunnel：中央狗院 → 城门侧路，只缩短猫赶场，不改变 Ninja 双线程规则。
            var tunnel := CatTunnel.new()
            tunnel.name = "CatTunnel_L11_01"
            tunnel_root.add_child(tunnel)
            tunnel.setup(Vector2(470, 500), Vector2(760, 350), Vector2(190, 34))
            tunnel.used.connect(_on_shortcut_used)
func _on_shortcut_used() -> void:
    if level_finished or level_failed:
        return
    shortcut_mastery = true
    if level_data != null and level_data.level_id == &"L07":
        world_state.set_flag(&"L07_SHORTCUT_USED")
    if level_data != null and level_data.level_id == &"L04" and world_state.get_flag(&"L04_GUARD_SAFE") and world_state.get_flag(&"L04_TRIPWIRE_SAFE"):
        world_state.set_flag(&"L04_SHORTCUT_USED")
        # Route B 已经满足水沟前置条件，释放当前可能正在水沟前等待的 Ninja。
        if ninja != null:
            ninja.release_event()
    event_log.append_event({"event_id": &"SHORTCUT", "action": &"CAT_SHORTCUT", "success": true, "level_id": level_data.level_id if level_data else &""})
    GlobalAudioManager.play_event_sfx("success")
    _show_toast("捷径成功：猫先到了。" if level_data == null or level_data.level_id != &"L04" else "路线 B：抄近路，直接去处理木桥。")

# 装饰层（GDD §8.2 四级装饰：永不抢玩法反馈）——确定性散布（种子=level_id），非随机地图
const NATURE_SHEET := "res://assets/tilesets/nature.png"
const DECOR_REGIONS := {
    &"tree_round": Rect2(0, 0, 32, 32),
    &"tree_big": Rect2(44, 288, 56, 48),
    &"cherry": Rect2(0, 280, 64, 56),
    &"dead_tree": Rect2(64, 0, 32, 32),
    &"rock_gray": Rect2(288, 256, 64, 48),
    &"sunflower": Rect2(16, 176, 16, 16),
    &"daisy": Rect2(96, 176, 16, 16),
    &"tuft": Rect2(48, 160, 16, 16),
    &"tuft2": Rect2(144, 160, 16, 16),
    &"mushroom": Rect2(192, 176, 16, 16),
    &"bush": Rect2(0, 160, 32, 32),
}
const PLAY_RECT := Rect2(40, 115, 1020, 500)

func _setup_l10_chain() -> void:
    if level_data == null or level_data.level_id != &"L10":
        return
    var root := Node2D.new()
    root.name = "L10ChainPickups"
    add_child(root)

    var fish := CarryPickup.new()
    fish.name = "FishPickup"
    root.add_child(fish)
    fish.position = Vector2(635, 430)
    fish.setup(&"FISH", self)

    var antidote := CarryPickup.new()
    antidote.name = "AntidotePickup"
    root.add_child(antidote)
    antidote.position = Vector2(705, 260)
    antidote.setup(&"ANTIDOTE", self)

    l10_late_antidote = CarryPickup.new()
    l10_late_antidote.name = "LateAntidotePickup"
    root.add_child(l10_late_antidote)
    l10_late_antidote.position = Vector2(800, 500)
    l10_late_antidote.setup(&"ANTIDOTE", self)
    l10_late_antidote.visible = false
    l10_late_antidote.set_process(false)
    l10_late_antidote.picked_up.connect(_on_l10_late_antidote_picked)
    _show_toast("L10：先看炸药会改变谁的位置，再处理守卫、狗和提前开的蒺藜。")

func _setup_l11_busy_gate() -> void:
    if level_data == null or level_data.level_id != &"L11":
        return
    var root := Node2D.new()
    root.name = "L11CarryPickups"
    add_child(root)

    var fish := CarryPickup.new()
    fish.name = "FishPickup"
    root.add_child(fish)
    fish.position = Vector2(270, 500)
    fish.setup(&"FISH", self)

    var antidote := CarryPickup.new()
    antidote.name = "AntidotePickup"
    root.add_child(antidote)
    antidote.position = Vector2(710, 505)
    antidote.setup(&"ANTIDOTE", self)

    _show_toast("L11：左右两条线程会同时变忙。炸药先处理；A 离岗后，B 的补位倒计时启动。")

func _update_l11_state(delta: float) -> void:
    if level_data == null or level_data.level_id != &"L11" or reading_phase or level_finished or level_failed:
        return

    var dynamite := _find_event_node(&"L11_E02_DYNAMITE")
    if l11_dynamite_window < 0.0 and not l11_dynamite_missed and dynamite != null and not dynamite.resolved_state and world_state.get_flag(&"L11_READING_DONE"):
        l11_dynamite_window = 6.0

    if l11_dynamite_window >= 0.0 and not l11_dynamite_missed and dynamite != null and not dynamite.resolved_state:
        l11_dynamite_window -= delta
        if l11_dynamite_window <= 0.0:
            l11_dynamite_window = 0.0
            l11_dynamite_missed = true
            world_state.set_flag(&"L11_DYNAMITE_MISSED")
            dynamite.fail(&"FAIL_TOO_LATE")
            _show_toast("炸药来不及了！忍者前方少了一层缓冲，剩下的要抢着处理。")

    if l11_guard_b_window >= 0.0 and not world_state.get_flag(&"L11_GUARD_B_SAFE"):
        l11_guard_b_window -= delta
        if l11_guard_b_window <= 0.0:
            l11_guard_b_window = 0.0
            l11_guard_b_urgent = true
            world_state.set_flag(&"L11_GUARD_B_URGENT")
            _show_toast("右翼守卫已经补位：靠近城门后窗口只剩最后一轮。")

    # E05 is a real blocking event; when Ninja reaches it, failure causes one heart loss but does not end the level.
    if ninja != null and ninja.waypoint_index >= 5:
        var guard_b := _find_event_node(&"L11_E05_GUARD_B")
        if guard_b != null and not guard_b.resolved_state and guard_b.is_inside_tree():
            if guard_b.timer >= guard_b.data.timeout and not l11_guard_b_urgent:
                l11_guard_b_urgent = true
                world_state.set_flag(&"L11_GUARD_B_URGENT")

func _start_l11_pressure_after_reading() -> void:
    if level_data == null or level_data.level_id != &"L11":
        return
    world_state.set_flag(&"L11_READING_DONE")
    l11_dynamite_window = 6.0

func _find_event_node(event_id: StringName) -> UnifiedEventPoint:
    for node in event_nodes:
        if node.data.event_id == event_id:
            return node
    return null

func _on_l10_late_antidote_picked(_item_id: StringName) -> void:
    high_risk_rescue += 1
    event_log.append_event({
        "event_id": &"L10_LATE_ANTIDOTE",
        "action": &"CARRY_LATE",
        "success": true,
        "high_risk": true,
        "world_changes": [&"late_antidote_taken"],
    })
    _show_toast("高风险补救：最后一瓶解毒药到手。")

func _update_l10_state(delta: float) -> void:
    if level_data == null or level_data.level_id != &"L10" or reading_phase or level_finished or level_failed:
        return
    var current := _current_main_event()
    if current != null and current.data.event_id == &"L10_E04_POISON" and cat != null and cat.carry_item == &"":
        if l10_late_antidote != null and is_instance_valid(l10_late_antidote) and not l10_late_antidote.visible:
            l10_late_antidote.visible = true
            l10_late_antidote.set_process(true)
            _show_toast("晚到方案：毒雾前才出现最后一瓶解毒药。来得及，但这是高风险。")
            event_log.append_event({
                "event_id": &"L10_LATE_ANTIDOTE_WINDOW",
                "action": &"SPAWN_LATE",
                "success": true,
                "world_changes": [&"late_antidote_available"],
            })
    if l10_caltrop_armed and not l10_caltrop_cleared and ninja != null and ninja.waypoint_index >= 4:
        if l10_caltrop_deadline < 0.0:
            l10_caltrop_deadline = 2.5
            _show_toast("蒺藜窗口提前：2.5 秒内处理，否则忍者会硬闯。")
        else:
            l10_caltrop_deadline -= delta
            if l10_caltrop_deadline <= 0.0:
                var caltrop := _find_event_node(&"L10_E04_CALTROP")
                if caltrop != null and not caltrop.resolved_state:
                    caltrop.fail(&"FAIL_WRONG_ORDER")
                l10_caltrop_armed = false
                l10_caltrop_deadline = -1.0

func _on_l10_dog_arrived(_target: Vector2) -> void:
    if level_data == null or level_data.level_id != &"L10" or not l10_dog_pending:
        return
    l10_dog_pending = false
    if l10_guard_a_stays:
        l10_poison_forced = true
        l10_route_mode = &"POISON_FORCED"
        world_state.set_flag(&"L10_POISON_FORCED")
        _apply_l10_route_branch(true)
        event_log.append_event({
            "event_id": &"L10_ROUTE_FORCED_POISON",
            "action": &"ROUTE_SWITCH",
            "success": true,
            "world_changes": [&"poison_forced", &"route_changed"],
        })
        _show_toast("守卫 A 还在岗：狗被鱼吸走后，忍者被迫走毒雾路线。")
    else:
        l10_route_mode = &"STANDARD"
        l10_caltrop_armed = true
        l10_caltrop_cleared = false
        l10_caltrop_deadline = -1.0
        world_state.set_flag(&"L10_CALTROP_WINDOW_EARLY")
        _show_toast("狗已改线：蒺藜窗口提前，先清蒺藜再处理毒雾。")
    if ninja != null:
        ninja.release_event()

func _apply_l10_route_branch(poison_forced: bool) -> void:
    if ninja == null:
        return
    if poison_forced:
        var points := [Vector2(110,540), Vector2(270,410), Vector2(590,360), Vector2(680,435), Vector2(820,300), Vector2(860,340), Vector2(980,260)]
        ninja.replace_scripted_route(points, 3)
        var poison := _find_event_node(&"L10_E04_POISON")
        if poison != null:
            poison.data.route_index = 5
            poison.position = points[5]
    else:
        var points := [Vector2(110,540), Vector2(270,410), Vector2(590,360), Vector2(680,435), Vector2(740,460), Vector2(860,340), Vector2(980,260)]
        ninja.replace_scripted_route(points, 3)
        var caltrop := _find_event_node(&"L10_E04_CALTROP")
        var poison := _find_event_node(&"L10_E04_POISON")
        if caltrop != null:
            caltrop.data.route_index = 4
            caltrop.position = points[4]
        if poison != null:
            poison.data.route_index = 5
            poison.position = points[5]
    event_log.append_event({
        "event_id": &"L10_ROUTE_CHANGE",
        "action": &"ROUTE_SWITCH",
        "success": true,
        "route_change": l10_route_mode,
    })

func _setup_l09_storm() -> void:
    if level_data == null or level_data.level_id != &"L09":
        return
    l09_storm_fx = L09StormFX.new()
    l09_storm_fx.name = "L09StormFX"
    add_child(l09_storm_fx)

    var root := Node2D.new()
    root.name = "L09CarryPickups"
    add_child(root)
    var fish := CarryPickup.new()
    fish.name = "FishPickup"
    root.add_child(fish)
    fish.position = Vector2(685, 445)
    fish.setup(&"FISH", self)
    _show_toast("雷雨夜：忍者全程加速。Q 叼鱼，E 处理狗；每个窗口都更短。")

func _setup_decorations() -> void:
    var layer := Node2D.new()
    layer.name = "Decorations"
    layer.z_index = -50
    add_child(layer)
    var rng := RandomNumberGenerator.new()
    rng.seed = hash(String(level_data.level_id))
    var chapter := String(level_data.chapter_id)
    var is_castle := chapter == "CH03"
    var tint := Color(0.5, 0.5, 0.62) if is_castle else Color.WHITE
    var border_items: Array[StringName]
    var floor_items: Array[StringName]
    match chapter:
        "CH02":
            border_items = [&"rock_gray", &"tree_round"]
            floor_items = [&"tuft", &"tuft2", &"mushroom"]
        "CH03":
            border_items = [&"dead_tree", &"rock_gray"]
            floor_items = [&"mushroom", &"tuft2"]
        _:
            border_items = [&"tree_round", &"tree_big", &"cherry"]
            floor_items = [&"tuft", &"tuft2", &"sunflower", &"daisy", &"mushroom"]
    # 上边界：大树排（村庄混樱花/绿树；城堡枯树+灰岩）
    var x := 60.0
    while x < 1060.0:
        var item: StringName = border_items[rng.randi() % border_items.size()]
        _add_decor(layer, item, Vector2(x, 88.0 + rng.randf_range(-8.0, 8.0)), 2.0, tint)
        x += rng.randf_range(90.0, 150.0)
    # 下边界与两侧
    x = 80.0
    while x < 1040.0:
        _add_decor(layer, border_items[rng.randi() % border_items.size()], Vector2(x, 648.0 + rng.randf_range(-6.0, 6.0)), 1.4, tint)
        x += rng.randf_range(110.0, 190.0)
    for side in [16.0, 1084.0]:
        var y := 150.0
        while y < 620.0:
            _add_decor(layer, border_items[rng.randi() % border_items.size()], Vector2(side + rng.randf_range(-4.0, 4.0), y), 1.2, tint)
            y += rng.randf_range(120.0, 200.0)
    # 场内细节：稀疏、半透、不遮挡事件点
    for i in 14:
        var pos := Vector2(rng.randf_range(PLAY_RECT.position.x + 30, PLAY_RECT.end.x - 30), rng.randf_range(PLAY_RECT.position.y + 30, PLAY_RECT.end.y - 30))
        _add_decor(layer, floor_items[rng.randi() % floor_items.size()], pos, 1.4, Color(tint.r, tint.g, tint.b, 0.85))
    # 码头章节追加：木箱与陶罐堆场 + 水面
    if chapter == "CH02":
        for i in 5:
            _add_decor_tex(layer, load("res://assets/props/crate.png"), Vector2(rng.randf_range(60, 1040), rng.randf_range(620, 660)), 2.0)
        for i in 3:
            _add_decor_tex(layer, load("res://content/destroyable/pot.png"), Vector2(rng.randf_range(1064, 1090), rng.randf_range(160, 600)), 1.6)
        _add_water_strip(layer, rng)
    # 村庄章节追加：上边界房屋（树后）
    if chapter == "CH01":
        var house_regions := [Rect2(0, 0, 60, 48), Rect2(62, 0, 64, 48), Rect2(127, 0, 62, 48), Rect2(190, 0, 62, 48)]
        var hx := 150.0
        while hx < 1000.0:
            var region: Rect2 = house_regions[rng.randi() % house_regions.size()]
            var tex := AtlasTexture.new()
            tex.atlas = load("res://assets/tilesets/house.png")
            tex.region = region
            var s := Sprite2D.new()
            s.texture = tex
            s.position = Vector2(hx, 66.0)
            s.scale = Vector2(1.6, 1.6)
            s.z_index = -10
            layer.add_child(s)
            hx += rng.randf_range(220.0, 330.0)
    _build_hedge(layer, chapter, tint)

func _build_hedge(layer: Node2D, chapter: String, tint: Color) -> void:
    # 沿碰撞墙的视觉边界：村庄树篱 / 码头木箱 / 城堡暗色灌木
    var hedge_item: StringName = &"bush"
    var hedge_scale := 1.6
    var spacing := 26.0
    if chapter == "CH03":
        hedge_scale = 1.3
    var x := PLAY_RECT.position.x + 8.0
    while x <= PLAY_RECT.end.x - 8.0:
        _add_decor(layer, hedge_item, Vector2(x, PLAY_RECT.position.y + 4.0), hedge_scale, tint)
        _add_decor(layer, hedge_item, Vector2(x, PLAY_RECT.end.y - 4.0), hedge_scale, tint)
        x += spacing
    var y := PLAY_RECT.position.y + 12.0
    while y <= PLAY_RECT.end.y - 12.0:
        _add_decor(layer, hedge_item, Vector2(PLAY_RECT.position.x + 4.0, y), hedge_scale, tint)
        _add_decor(layer, hedge_item, Vector2(PLAY_RECT.end.x - 4.0, y), hedge_scale, tint)
        y += spacing

func _add_water_strip(layer: Node2D, rng: RandomNumberGenerator) -> void:
    # 码头下边界水面 + 涟漪动画（4 帧）
    var water := ColorRect.new()
    water.color = Color(0.16, 0.35, 0.5)
    water.position = Vector2(0, 616)
    water.size = Vector2(1100, 64)
    water.mouse_filter = Control.MOUSE_FILTER_IGNORE
    layer.add_child(water)
    var ripple_tex: Texture2D = load("res://assets/tilesets/water_ripples.png")
    for i in 7:
        var frames := SpriteFrames.new()
        frames.add_animation(&"ripple")
        frames.set_animation_speed(&"ripple", 3.0)
        for f in 4:
            var at := AtlasTexture.new()
            at.atlas = ripple_tex
            at.region = Rect2(f * 16, 0, 16, 16)
            frames.add_frame(&"ripple", at)
        var ripple := AnimatedSprite2D.new()
        ripple.sprite_frames = frames
        ripple.scale = Vector2(2.0, 2.0)
        ripple.position = Vector2(rng.randf_range(40, 1060), rng.randf_range(624, 668))
        ripple.play(&"ripple")
        layer.add_child(ripple)

func _add_decor(layer: Node2D, item: StringName, pos: Vector2, decor_scale: float, tint: Color) -> void:
    var tex := AtlasTexture.new()
    tex.atlas = load(NATURE_SHEET)
    tex.region = DECOR_REGIONS[item]
    _add_decor_tex(layer, tex, pos, decor_scale, tint)

func _add_decor_tex(layer: Node2D, tex: Texture2D, pos: Vector2, decor_scale: float, tint: Color = Color.WHITE) -> void:
    var s := Sprite2D.new()
    s.texture = tex
    s.position = pos
    s.scale = Vector2(decor_scale, decor_scale)
    s.modulate = tint
    layer.add_child(s)

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
        if level_data.level_id == &"L10":
            match data.event_id:
                &"L10_E01_DYNAMITE_A": point.position = Vector2(270, 410)
                &"L10_E02_GUARD_A": point.position = Vector2(590, 360)
                &"L10_E03_DOG": point.position = Vector2(680, 435)
                &"L10_E04_CALTROP": point.position = Vector2(740, 460)
                &"L10_E04_POISON": point.position = Vector2(860, 340)
        if level_data.level_id == &"L11":
            match data.event_id:
                &"L11_E01_GUARD_A": point.position = Vector2(350, 250)
                &"L11_E02_DYNAMITE": point.position = Vector2(500, 430)
                &"L11_E03_DOG": point.position = Vector2(610, 300)
                &"L11_E04_POISON": point.position = Vector2(720, 430)
                &"L11_E05_GUARD_B": point.position = Vector2(820, 250)
                &"L11_E06_CALTROP": point.position = Vector2(900, 380)
                &"L11_E07_GATE": point.position = Vector2(980, 220)
        point.setup(data, self)
        point.resolved.connect(event_resolved.bind(point))
        point.failed.connect(_on_event_failed)
        event_root.add_child(point)
        event_nodes.append(point)
func _place_guards_and_dog() -> void:
    var guard_i := 0
    for data in level_data.events:
        if data.event_type == &"GUARD" and guard_i < guards.size():
            var center := level_data.ninja_route.waypoints[clamp(data.route_index, 0, level_data.ninja_route.waypoints.size() - 1)] + Vector2(0, 70)
            var guard := guards[guard_i]
            if level_data.level_id == &"L05" and data.event_id == &"L05_E05_GUARD_B":
                center = Vector2(860, 540) # staging; enters the route after Guard A has been absent for 8s
            if level_data.level_id == &"L06":
                if data.event_id == &"L06_E02_GUARD_A":
                    center = Vector2(560, 230)
                elif data.event_id == &"L06_E04_GUARD_B":
                    center = Vector2(820, 360)
            if level_data.level_id == &"L07":
                if data.event_id == &"L07_E01_GUARD_A":
                    center = Vector2(420, 220)
                elif data.event_id == &"L07_E02_GUARD_B":
                    center = Vector2(650, 210)
            if level_data.level_id == &"L08":
                if data.event_id == &"L08_E01_GUARD_A":
                    center = Vector2(390, 370)
                elif data.event_id == &"L08_E03_GUARD_B":
                    center = Vector2(820, 420)
            if level_data.level_id == &"L10" and data.event_id == &"L10_E02_GUARD_A":
                center = Vector2(600, 300)
            if level_data.level_id == &"L11":
                if data.event_id == &"L11_E01_GUARD_A":
                    center = Vector2(350, 320)
                elif data.event_id == &"L11_E05_GUARD_B":
                    center = Vector2(820, 320)
            if guard.has_method("setup"):
                guard.call("setup", center)
            guard.visible = true
            guard_i += 1
    for i in range(guard_i, guards.size()):
        if guards[i] != null:
            guards[i].visible = false
    if dog and dog.global_position == Vector2.ZERO:
        if level_data.level_id == &"L05":
            dog.setup(Vector2(540, 490))
        elif level_data.level_id == &"L06":
            dog.setup(Vector2(360, 475))
        elif level_data.level_id == &"L07":
            dog.setup(Vector2(470, 500))
        elif level_data.level_id == &"L08":
            dog.setup(Vector2(310, 500))
        elif level_data.level_id == &"L09":
            dog.setup(Vector2(690, 455))
        elif level_data.level_id == &"L10":
            dog.setup(Vector2(680, 435))
        elif level_data.level_id == &"L11":
            dog.setup(Vector2(560, 380))
        else:
            dog.setup(Vector2(520, 465))
func is_event_active(data: EventPointData) -> bool:
    if data.activation_flag != &"" and not world_state.get_flag(data.activation_flag):
        return false
    if data.activation_phase != 0:
        if boss == null or boss.phase != data.activation_phase:
            return false
    if data.event_group == &"BOSS_COMBAT":
        return boss != null and boss_started
    if level_data != null and level_data.level_id == &"L11":
        match data.event_id:
            &"L11_E01_GUARD_A": return not _l11_event_done(&"L11_E01_GUARD_A")
            &"L11_E02_DYNAMITE": return not _l11_event_done(&"L11_E02_DYNAMITE") and not l11_dynamite_missed
            &"L11_E03_DOG": return _l11_event_done(&"L11_E01_GUARD_A") and not _l11_event_done(&"L11_E03_DOG")
            &"L11_E04_POISON": return _l11_event_done(&"L11_E03_DOG") and not _l11_event_done(&"L11_E04_POISON")
            &"L11_E05_GUARD_B": return _l11_event_done(&"L11_E01_GUARD_A") and not _l11_event_done(&"L11_E05_GUARD_B")
            &"L11_E06_CALTROP": return _l11_event_done(&"L11_E04_POISON") and _l11_event_done(&"L11_E05_GUARD_B") and not _l11_event_done(&"L11_E06_CALTROP")
            &"L11_E07_GATE": return _l11_event_done(&"L11_E06_CALTROP") and not _l11_event_done(&"L11_E07_GATE")
        return false
    if level_data != null and level_data.level_id == &"L10":
        if data.event_id == &"L10_E04_CALTROP":
            var caltrop_node := _find_event_node(&"L10_E04_CALTROP")
            return l10_caltrop_armed and caltrop_node != null and not caltrop_node.resolved_state
        var ordered_l10 := [&"L10_E01_DYNAMITE_A", &"L10_E02_GUARD_A", &"L10_E03_DOG", &"L10_E04_POISON"]
        var wanted_index_l10 := ordered_l10.find(data.event_id)
        if wanted_index_l10 < 0:
            return false
        for i in range(wanted_index_l10):
            var prior_node_l10 := _find_event_node(ordered_l10[i])
            if prior_node_l10 != null and not prior_node_l10.resolved_state:
                return false
        return not data.non_blocking and data.event_group != &"OPTIONAL"
    if level_data != null and level_data.level_id == &"L09":
        var ordered_l09 := [&"L09_E01_TRIPWIRE", &"L09_E02_GUARD_A", &"L09_E03_DYNAMITE", &"L09_E04_DOG"]
        var wanted_index := ordered_l09.find(data.event_id)
        if wanted_index < 0:
            return false
        for i in range(wanted_index):
            var prior_id: StringName = ordered_l09[i]
            for node in event_nodes:
                if node.data.event_id == prior_id and not node.resolved_state:
                    return false
        return not data.non_blocking and data.event_group != &"OPTIONAL"
    if level_data != null and level_data.level_id == &"L08":
        match data.event_id:
            &"L08_E01_GUARD_A": return not _l08_event_done(&"L08_E01_GUARD_A")
            &"L08_E02_DOG": return _l08_event_done(&"L08_E01_GUARD_A") and not _l08_event_done(&"L08_E02_DOG")
            &"L08_E03_GUARD_B": return world_state.get_flag(&"L08_DOG_ALLY") and _l08_event_done(&"L08_E02_DOG") and not _l08_event_done(&"L08_E03_GUARD_B")
            &"L08_E04_POISON": return _l08_event_done(&"L08_E03_GUARD_B") and world_state.get_flag(&"L08_GUARD_B_SAFE") and not _l08_event_done(&"L08_E04_POISON")
            &"L08_E05_CALTROP": return _l08_event_done(&"L08_E04_POISON") and world_state.get_flag(&"L08_POISON_SAFE") and not _l08_event_done(&"L08_E05_CALTROP")
            &"L08_E06_BRIDGE": return _l08_event_done(&"L08_E05_CALTROP") and world_state.get_flag(&"L08_CALTROP_SAFE") and not _l08_event_done(&"L08_E06_BRIDGE")
    if level_data != null and level_data.level_id == &"L07":
        match data.event_id:
            &"L07_E01_GUARD_A": return not _l07_event_done(&"L07_E01_GUARD_A")
            &"L07_E02_GUARD_B": return _l07_event_done(&"L07_E01_GUARD_A") or not _l07_event_done(&"L07_E02_GUARD_B")
            &"L07_E03_DOG": return _l07_event_done(&"L07_E01_GUARD_A") and not _l07_event_done(&"L07_E03_DOG")
            &"L07_E04_BRIDGE":
                if l07_b_was_early:
                    return _l07_event_done(&"L07_E05_POISON") and world_state.get_flag(&"L07_BRIDGE_OPEN") and not _l07_event_done(&"L07_E04_BRIDGE")
                return _l07_event_done(&"L07_E03_DOG") and world_state.get_flag(&"L07_BRIDGE_OPEN") and not _l07_event_done(&"L07_E04_BRIDGE")
            &"L07_E05_POISON":
                if l07_b_was_early:
                    return _l07_event_done(&"L07_E03_DOG") and not _l07_event_done(&"L07_E05_POISON")
                return _l07_event_done(&"L07_E04_BRIDGE") and not _l07_event_done(&"L07_E05_POISON")
    if level_data != null and level_data.level_id == &"L06":
        match data.event_id:
            &"L06_E01_DOG": return not _l06_event_done(&"L06_E01_DOG")
            &"L06_E02_GUARD_A": return _l06_event_done(&"L06_E01_DOG") and not _l06_event_done(&"L06_E02_GUARD_A")
            &"L06_E03_BRIDGE": return _l06_event_done(&"L06_E02_GUARD_A") and world_state.get_flag(&"L06_GUARD_A_SAFE") and not _l06_event_done(&"L06_E03_BRIDGE")
            &"L06_E04_GUARD_B": return _l06_event_done(&"L06_E03_BRIDGE") and not _l06_event_done(&"L06_E04_GUARD_B")
            &"L06_E05_CALTROP": return _l06_event_done(&"L06_E04_GUARD_B") and world_state.get_flag(&"L06_GUARD_B_SAFE") and not _l06_event_done(&"L06_E05_CALTROP")
    if level_data != null and level_data.level_id == &"L05":
        match data.event_id:
            &"L05_E01_GUARD_A": return not _l05_event_done(&"L05_E01_GUARD_A")
            &"L05_E02_DOG": return _l05_event_done(&"L05_E01_GUARD_A") and not _l05_event_done(&"L05_E02_DOG")
            &"L05_E03_BRIDGE": return _l05_event_done(&"L05_E02_DOG") and not _l05_event_done(&"L05_E03_BRIDGE")
            &"L05_E04_POISON": return _l05_event_done(&"L05_E03_BRIDGE") and not _l05_event_done(&"L05_E04_POISON")
            &"L05_E05_GUARD_B": return _l05_event_done(&"L05_E04_POISON") and world_state.get_flag(&"L05_GUARD_B_ACTIVE") and not _l05_event_done(&"L05_E05_GUARD_B")
            &"L05_E06_CALTROP": return _l05_event_done(&"L05_E05_GUARD_B") and not _l05_event_done(&"L05_E06_CALTROP")
    if level_data != null and level_data.level_id == &"L04":
        match data.event_id:
            &"L04_E01_GUARD": return not world_state.get_flag(&"L04_GUARD_SAFE")
            &"L04_E02_TRIPWIRE": return not world_state.get_flag(&"L04_TRIPWIRE_SAFE")
            &"L04_E03_CRATE": return world_state.get_flag(&"L04_GUARD_SAFE") and world_state.get_flag(&"L04_TRIPWIRE_SAFE") and not world_state.get_flag(&"L04_CRATE_STOLEN") and not world_state.get_flag(&"L04_SHORTCUT_USED")
            &"L04_E04_WATERGAP": return world_state.get_flag(&"L04_GUARD_SAFE") and world_state.get_flag(&"L04_TRIPWIRE_SAFE") and (world_state.get_flag(&"L04_CRATE_STOLEN") or world_state.get_flag(&"L04_SHORTCUT_USED")) and not world_state.get_flag(&"L04_WATERGAP_SAFE")
    return true
func _l06_event_done(event_id: StringName) -> bool:
    for node in event_nodes:
        if node.data.event_id == event_id:
            return node.resolved_state
    return false

func _l05_event_done(event_id: StringName) -> bool:
    for node in event_nodes:
        if node.data.event_id == event_id:
            return node.resolved_state
    return false

func _l08_event_done(event_id: StringName) -> bool:
    for node in event_nodes:
        if node.data.event_id == event_id:
            return node.resolved_state
    return false

func _l11_event_done(event_id: StringName) -> bool:
    for node in event_nodes:
        if node.data.event_id == event_id:
            return node.resolved_state
    return false

func _l07_event_done(event_id: StringName) -> bool:
    for node in event_nodes:
        if node.data.event_id == event_id:
            return node.resolved_state
    return false

func is_ninja_at_blocking_event(route_index: int) -> bool:
    if level_data != null and level_data.level_id == &"L11":
        # E02 (dynamite) is deliberately non-blocking; all other main events block the fixed route.
        var current_l11 := _current_main_event()
        if current_l11 == null or current_l11.resolved_state or current_l11.data.non_blocking:
            return false
        return route_index >= current_l11.data.route_index
    if level_data != null and level_data.level_id == &"L10":
        var caltrop := _find_event_node(&"L10_E04_CALTROP")
        if caltrop != null and is_event_active(caltrop.data) and not caltrop.resolved_state and route_index >= caltrop.data.route_index:
            return true
        var current_l10 := _current_main_event()
        if current_l10 == null or current_l10.resolved_state:
            return false
        return route_index >= current_l10.data.route_index
    if level_data != null and level_data.level_id == &"L10":
        var caltrop := _find_event_node(&"L10_E04_CALTROP")
        if caltrop != null and is_event_active(caltrop.data) and not caltrop.resolved_state and route_index >= caltrop.data.route_index:
            return true
        var current_l10 := _current_main_event()
        if current_l10 == null or current_l10.resolved_state:
            return false
        return route_index >= current_l10.data.route_index

    if level_data != null and level_data.level_id == &"L08":
        var current_l08 := _current_main_event()
        if current_l08 == null or current_l08.resolved_state:
            return false
        return route_index >= current_l08.data.route_index
    if level_data != null and level_data.level_id == &"L07":
        var current_l07 := _current_main_event()
        if current_l07 == null or current_l07.resolved_state or current_l07.data.non_blocking:
            return false
        return route_index >= current_l07.data.route_index
    if level_data != null and level_data.level_id == &"L06":
        var current_l06 := _current_main_event()
        if current_l06 == null or current_l06.resolved_state:
            return false
        return route_index >= current_l06.data.route_index
    if level_data != null and level_data.level_id == &"L05":
        var current_l05 := _current_main_event()
        if current_l05 == null or current_l05.resolved_state:
            return false
        return route_index >= current_l05.data.route_index
    if level_data != null and level_data.level_id == &"L04":
        var blocker := _l04_blocking_event()
        if blocker == null:
            return false
        return route_index >= blocker.data.route_index and not blocker.resolved_state
    var current := _current_main_event()
    if current == null or current.data.non_blocking or current.data.event_group != &"MAIN":
        return false
    return route_index >= current.data.route_index and not current.resolved_state
func _l04_blocking_event() -> UnifiedEventPoint:
    # 两条路线共同的前半段允许任意顺序：Ninja 会在自己先到达的未处理事件处停住。
    for wanted in [&"L04_E01_GUARD", &"L04_E02_TRIPWIRE"]:
        for node in event_nodes:
            if node.data.event_id == wanted and is_event_active(node.data):
                return node

    # 两个前置事件都完成后，分叉点本身必须阻挡 Ninja；否则 Ninja 会直接穿过分叉，
    # 让“选箱子还是抄捷径”失去实际意义。E04 此时可以先保持 inactive，直到 A/B 任一路线成立。
    var watergap: UnifiedEventPoint = null
    for node in event_nodes:
        if node.data.event_id == &"L04_E04_WATERGAP":
            watergap = node
            break
    if watergap != null and not world_state.get_flag(&"L04_WATERGAP_SAFE"):
        return watergap
    return null

func on_player_action_started(data: EventPointData, action_id: StringName) -> void:
    if boss != null and data.event_group == &"BOSS_COMBAT" and boss.phase != 2:
        return
    var seen := _ninja_sees_cat()
    var suspicion_gain := EventBehaviorRegistry.suspicion_for(data)
    if suspicion_observer != null:
        suspicion_gain = suspicion_observer.suspicion_for_action(data.interaction_time)
    if seen and action_id != &"PASSIVE" and action_id != &"EMOTE_CHECK":
        _apply_suspicion(suspicion_gain, action_id)
    event_log.append_event({"event_id": data.event_id, "action": action_id, "success": true, "suspicion": suspicion, "suspicion_gain": suspicion_gain if seen else 0.0, "seen_by_ninja": seen})

func _ninja_sees_cat() -> bool:
    if suspicion_observer != null:
        return suspicion_observer.sees_subject()
    if ninja == null or cat == null:
        return false
    var dist := ninja.global_position.distance_to(cat.global_position)
    if dist <= 24.0:
        return true
    if dist > 100.0:
        return false
    return ninja.is_facing_point(cat.global_position) and ninja.facing.dot((cat.global_position - ninja.global_position).normalized()) >= cos(deg_to_rad(45.0))

func on_player_action_cancelled(_data: EventPointData) -> void:
    pass

func _on_cat_action_started(action_id: StringName) -> void:
    if action_id in [&"BITE", &"PUSH"] and _ninja_sees_cat():
        _apply_suspicion(15.0, action_id)

func _on_cat_meow() -> void:
    if level_finished or level_failed:
        return
    if level_data != null and level_data.level_id == &"L10":
        var guard_event := _find_event_node(&"L10_E02_GUARD_A")
        if guard_event != null and is_event_active(guard_event.data) and not guard_event.resolved_state and cat != null and cat.global_position.distance_to(guard_event.global_position) <= 150.0:
            guard_event.resolve(&"MEOW")
            return
        event_log.append_event({"event_id": &"L10_CAT_MEOW", "action": &"MEOW", "success": true})
        return

    if level_finished or level_failed:
        return
    if level_data != null and level_data.level_id == &"L07":
        # L07 只允许喵叫处理真正的 GuardPoint，且一次只影响当前附近的守卫。
        for node in event_nodes:
            if node.data.event_id not in [&"L07_E01_GUARD_A", &"L07_E02_GUARD_B"]:
                continue
            if not is_event_active(node.data) or node.resolved_state:
                continue
            if cat != null and cat.global_position.distance_to(node.global_position) <= 150.0:
                node.resolve(&"MEOW")
                return
        event_log.append_event({"event_id": &"CAT_MEOW", "action": &"MEOW", "success": true, "level_id": &"L07"})
        return
    # L06 专门教学“狗也能当队友”：喵叫只做反馈，不允许直接替代狗协同。
    if level_data == null or level_data.level_id != &"L06":
        for guard in guards:
            if guard == null:
                continue
            if guard.has_method("distract"):
                guard.call("distract", cat.global_position)
            elif guard.has_method("depart"):
                guard.call("depart", cat.global_position)
    var current := _current_main_event()
    if level_data != null and level_data.level_id == &"L04":
        for node in event_nodes:
            if node.data.event_type == &"GUARD" and is_event_active(node.data) and cat.global_position.distance_to(node.global_position) <= 150.0:
                node.resolve(&"MEOW")
                break
    elif current != null and current.data.event_type == &"GUARD" and cat.global_position.distance_to(current.global_position) <= 150.0:
        if level_data == null or level_data.level_id != &"L06" or current.data.required_action != &"SEND_DOG":
            current.resolve(&"MEOW")
    event_log.append_event({"event_id": &"CAT_MEOW", "action": &"MEOW", "success": true})
func _on_cat_emote() -> void:
    if level_finished or level_failed:
        return
    if ninja == null or cat == null:
        return
    var in_range := ninja.global_position.distance_to(cat.global_position) <= 150.0
    var in_sight := _ninja_sees_cat()
    if not in_range or not in_sight:
        event_log.append_event({"event_id": &"CAT_EMOTE", "action": &"EMOTE", "success": false, "reason": "OUT_OF_SIGHT"})
        _show_toast("卖萌失败：要在他的视线里。")
        return

    # GDD 细节：卖萌瞬间若叼着道具，道具掉落原地。
    if cat.carry_item != &"":
        _drop_carry_item()
    var before := suspicion
    suspicion = 0.0
    event_log.append_event({"event_id": &"CAT_EMOTE", "action": &"EMOTE", "success": true, "suspicion_before": before, "suspicion_after": suspicion})
    var current := _current_main_event()
    if current != null and current.data.event_type == &"EMOTE_CHECK":
        current.resolve(&"EMOTE")
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

func event_resolved(data: EventPointData, action_id: StringName, point: UnifiedEventPoint = null) -> void:
    if level_failed or level_finished:
        return
    for flag in data.success_flags:
        world_state.set_flag(flag)
    if level_data != null and level_data.level_id == &"L05":
        match data.event_id:
            &"L05_E01_GUARD_A":
                l05_guard_a_depart_time = _l05_now()
                _show_toast("守卫 A 已被引开。记住：8 秒后 B 会换岗。")
            &"L05_E04_POISON":
                l05_poisoned = false
                l05_poison_tick_timer = 5.0
                _show_toast("解毒成功，毒雾段安全了。")
    if level_data != null and level_data.level_id == &"L06":
        match data.event_id:
            &"L06_E01_DOG":
                world_state.set_flag(&"L06_DOG_ALLY")
                _show_toast("狗狗加入队伍：以后可以用 E 派它去守卫那里。")
            &"L06_E03_BRIDGE":
                _show_toast("木桥放下：前面的空档留给你和狗狗继续配合。")
            &"L06_E05_CALTROP":
                _show_toast("铁蒺藜处理完成，出口就在前面。")
    if level_data != null and level_data.level_id == &"L08":
        match data.event_id:
            &"L08_E01_GUARD_A":
                if guards.size() > 0 and guards[0] != null:
                    guards[0].call("depart", cat.global_position if cat else Vector2(390, 370), 6.0)
                world_state.set_flag(&"L08_GUARD_A_DEPARTED")
                _show_toast("守卫 A 已离岗：下一步先把狗变成你的队友。")
            &"L08_E02_DOG":
                world_state.set_flag(&"L08_DOG_ALLY")
                _show_toast("狗狗加入队伍：现在用 E 派它去守卫 B。")
            &"L08_E03_GUARD_B":
                l08_dog_assist_pending = true
                if dog != null and guards.size() > 1 and guards[1] != null:
                    dog.lure_to(guards[1].global_position)
                _show_toast("狗狗正在赶去守卫 B：到位前忍者先别动。")
            &"L08_E04_POISON":
                _show_toast("毒雾段安全：最后两处就能赶上末班船。")
            &"L08_E05_CALTROP":
                _show_toast("蒺藜清掉了：最后一段桥还等着放下。")
            &"L08_E06_BRIDGE":
                l08_bridge_open = true
                world_state.set_flag(&"L08_BRIDGE_OPEN")
                _show_toast("桥放下了！末班船就在前面。")
    if level_data != null and level_data.level_id == &"L11":
        match data.event_id:
            &"L11_E01_GUARD_A":
                world_state.set_flag(&"L11_GUARD_A_SAFE")
                l11_guard_b_window = 8.0
                if guards.size() > 0 and guards[0] != null:
                    guards[0].call("depart", cat.global_position if cat else Vector2(350, 250), 6.0)
                _show_toast("守卫 A 离岗：右翼线程启动，8 秒后补位。")
                event_log.append_event({"event_id": &"L11_THREAD_RIGHT_ARM", "action": &"ARM_GUARD_B_TIMER", "success": true, "delay": 8.0, "world_changes": [&"guard_b_timer_started"]})
            &"L11_E02_DYNAMITE":
                l11_dynamite_window = -1.0
                world_state.set_flag(&"L11_DYNAMITE_SAFE")
                _show_toast("炸药已处理：中央线程清空。继续赶场。")
            &"L11_E03_DOG":
                l11_dog_diverted = true
                world_state.set_flag(&"L11_DOG_DIVERTED")
                if dog != null:
                    dog.lure_to(Vector2(490, 360))
                    dog.bark()
                _show_toast("狗被鱼引走：左侧压力暂时减轻。")
            &"L11_E04_POISON":
                l11_poison_safe = true
                world_state.set_flag(&"L11_POISON_SAFE")
                _show_toast("毒雾处理完成：别停，城门已经在眼前。")
            &"L11_E05_GUARD_B":
                l11_guard_b_window = -1.0
                l11_guard_b_urgent = false
                world_state.set_flag(&"L11_GUARD_B_SAFE")
                world_state.set_flag(&"L11_GUARD_B_URGENT", false)
                if guards.size() > 1 and guards[1] != null:
                    guards[1].call("depart", cat.global_position if cat else Vector2(820, 250), 6.0)
                _show_toast("右翼守卫也被引开了：最后一段清蒺藜。")
            &"L11_E06_CALTROP":
                world_state.set_flag(&"L11_CALTROP_SAFE")
                _show_toast("城门蒺藜清空：最后一关就是开门。")
            &"L11_E07_GATE":
                world_state.set_flag(&"L11_GATE_OPEN")
                _show_toast("城门打开：一路忙到最后，终于赶上了。")
    if level_data != null and level_data.level_id == &"L10":
        match data.event_id:
            &"L10_E01_DYNAMITE_A":
                l10_guard_a_shifted = true
                world_state.set_flag(&"L10_DYNAMITE_A_SAFE")
                world_state.set_flag(&"L10_GUARD_A_SHIFTED")
                if guards.size() > 0 and guards[0] != null:
                    guards[0].call("setup", Vector2(600, 300))
                event_log.append_event({"event_id": &"L10_CHAIN_01", "action": &"DYNAMITE_TO_GUARD_SHIFT", "success": true, "caused_event_id": &"L10_E02_GUARD_A", "world_changes": [&"guard_a_shifted"], "route_change": &"L10_E02_GUARD_A"})
                _show_toast("炸药被处理后，守卫 A 换位了。")
            &"L10_E02_GUARD_A":
                l10_guard_a_departed = true
                l10_guard_a_stays = false
                world_state.set_flag(&"L10_GUARD_A_DEPARTED")
                if guards.size() > 0 and guards[0] != null:
                    guards[0].call("depart", cat.global_position if cat else Vector2(560, 360), 6.0)
                event_log.append_event({"event_id": &"L10_CHAIN_02", "action": &"GUARD_TO_DOG", "success": true, "caused_event_id": &"L10_E03_DOG", "world_changes": [&"guard_a_departed"], "route_change": &"L10_E03_DOG"})
                _show_toast("守卫 A 离岗：现在把狗引开。")
            &"L10_E03_DOG":
                l10_dog_pending = true
                if dog != null:
                    dog.lure_to(Vector2(740, 430))
                event_log.append_event({"event_id": &"L10_CHAIN_03", "action": &"DOG_STARTLED", "success": true, "caused_event_id": &"L10_E04_POISON", "world_changes": [&"dog_route_changed"], "route_change": l10_route_mode})
                _show_toast("狗被鱼吸走：下一段路线开始改变。")
            &"L10_E04_CALTROP":
                l10_caltrop_armed = false
                l10_caltrop_cleared = true
                l10_caltrop_deadline = -1.0
                world_state.set_flag(&"L10_CALTROP_CLEARED")
                _show_toast("蒺藜清掉了：赶去毒雾。")
                if ninja != null:
                    ninja.release_event()
            &"L10_E04_POISON":
                world_state.set_flag(&"L10_POISON_SAFE")
                _show_toast("毒雾段处理完成：东门就在前面。")
    if level_data != null and level_data.level_id == &"L07":
        match data.event_id:
            &"L07_E01_GUARD_A":
                l07_guard_a_depart_time = _l05_now()
                world_state.set_flag(&"L07_GUARD_A_DEPARTED")
                if guards.size() > 0 and guards[0] != null:
                    guards[0].call("depart", cat.global_position if cat else Vector2(360, 170), 6.0)
                _show_toast("守卫 A 离岗：8 秒后 B 才是稳定换岗解。")
            &"L07_E02_GUARD_B":
                if guards.size() > 1 and guards[1] != null:
                    guards[1].call("depart", cat.global_position if cat else Vector2(650, 210), 6.0)
                var early := l07_guard_a_depart_time < 0.0 or (_l05_now() - l07_guard_a_depart_time) < 8.0
                world_state.set_flag(&"L07_GUARD_B_ACTIVE")
                if early:
                    l07_b_was_early = true
                    world_state.set_flag(&"L07_BRIDGE_BLOCKED")
                    world_state.set_flag(&"L07_POISON_FIRST")
                    event_log.append_event({
                        "event_id": &"L07_ORDER_DIAGNOSTIC",
                        "action": &"RESOLVE_GUARD_B_EARLY",
                        "success": false,
                        "fail_code": &"FAIL_WRONG_ORDER",
                        "world_changes": [&"guard_b_active", &"bridge_blocked", &"poison_first"],
                    })
                    _apply_l07_route_branch(true)
                    _show_toast("守卫 B 提前补位：桥口被堵，他改走毒雾侧线。")
                else:
                    _show_toast("守卫 B 稳定补位：后面的桥口保持原路线。")
            &"L07_E03_DOG":
                _l07_start_dog_route()
            &"L07_E04_BRIDGE":
                l07_bridge_open = true
                world_state.set_flag(&"L07_BRIDGE_OPEN")
                world_state.set_flag(&"L07_BRIDGE_BLOCKED", false)
                _show_toast("狗的路线已经把桥口窗口拉开了。")
            &"L07_E05_POISON":
                world_state.set_flag(&"L07_POISON_ROUTE_SAFE")
                _show_toast("毒雾窗口处理完成：码头出口安全。")
    if level_data == null or level_data.level_id not in [&"L07", &"L11"]:
        _apply_event_side_effect(data, action_id)
    else:
        # L07/L11 Guard A/B must only affect their own guard; generic GUARD_DISTRACT would move both.
        if data.event_type != &"GUARD":
            _apply_event_side_effect(data, action_id)
    var late_window := 99.0
    if point != null and data.timeout > 0.0:
        late_window = max(0.0, data.timeout - point.timer)
    var caused_event_id: StringName = data.caused_event_ids[0] if not data.caused_event_ids.is_empty() else &""
    var next_route_event: StringName = &""
    if level_data != null and level_data.level_id == &"L04":
        var next_node := _current_main_event()
        next_route_event = next_node.data.event_id if next_node != null else &"GOAL"
    if level_data != null and level_data.level_id == &"L10":
        var next_l10 := _current_main_event()
        next_route_event = next_l10.data.event_id if next_l10 != null else &"GOAL"
    if level_data != null and level_data.level_id == &"L11":
        var next_l11 := _current_main_event()
        next_route_event = next_l11.data.event_id if next_l11 != null else &"GOAL"
    event_log.append_event({
        "event_id": data.event_id,
        "event_type": data.event_type,
        "action": action_id,
        "success": true,
        "risk_level": data.risk_level,
        "high_risk": data.high_risk,
        "tags": data.banter_tags,
        "late_success_window": late_window,
        "caused_event_id": caused_event_id,
        "world_changes": data.success_flags,
        "route_change": next_route_event if level_data != null and level_data.level_id in [&"L04", &"L10", &"L11"] else active_main_event_index + 1,
    })
    if previous_event_id != &"":
        chain_rescue += 1
    previous_event_id = data.event_id
    if data.high_risk:
        high_risk_rescue += 1
    if level_data != null and level_data.level_id == &"L04":
        # L04 不用单一索引锁死顺序：解决任一当前阻挡事件后，都重新计算下一阻挡点。
        if ninja:
            ninja.release_event()
    elif level_data != null and level_data.level_id == &"L06" and data.event_id in [&"L06_E02_GUARD_A", &"L06_E04_GUARD_B"]:
        # 必须等狗真实抵达守卫位置后再放行 Ninja。
        l06_dog_help_pending = true
    elif level_data != null and level_data.level_id == &"L08" and data.event_id == &"L08_E03_GUARD_B":
        # 事件先解决，忍者继续等待；狗到位后再 release_event()。
        l08_dog_assist_pending = true
    elif level_data != null and level_data.level_id == &"L10" and data.event_id == &"L10_E03_DOG":
        # 事件先解决，忍者继续等待；狗真正到位后再切换路线并释放。
        l10_dog_pending = true
    elif data.event_group == &"MAIN" and _find_main_event_index(data.event_id) == active_main_event_index:
        active_main_event_index += 1
        if ninja and not (level_data != null and level_data.level_id == &"L07" and data.event_id == &"L07_E03_DOG"):
            ninja.release_event()
    GlobalAudioManager.play_event_sfx("success")
    if level_data != null and level_data.level_id == &"L04" and world_state.get_flag(&"L04_GUARD_SAFE") and world_state.get_flag(&"L04_TRIPWIRE_SAFE") and not world_state.get_flag(&"L04_CRATE_STOLEN") and not world_state.get_flag(&"L04_SHORTCUT_USED"):
        _show_toast("两处都处理好了：现在选箱子稳走，或抄捷径抢时间。")
    else:
        _show_toast("处理成功：%s" % data.display_name)
func _apply_event_side_effect(data: EventPointData, action_id: StringName) -> void:
    # Flags remain declarative facts; non-trivial behavior is expressed by EventEffectData.
    if data.event_type == &"STEAL_CRATE" and cat != null:
        cat.carry_item = &"CRATE"
        _set_carry_visual(&"CRATE")
        _show_toast("路线 A：箱子到手了。把它送到木桥。")
    for effect_resource in data.success_effects:
        var effect := effect_resource as EventEffectData
        if effect == null:
            continue
        _apply_effect(effect)
    if data.consume_carry_item != &"" and cat != null and cat.carry_item == data.consume_carry_item:
        cat.carry_item = &""
        _clear_carry_visual()

func _set_carry_visual(item: StringName) -> void:
    _clear_carry_visual()
    if cat == null:
        return
    var path := ""
    match item:
        &"CRATE": path = "res://assets/props/crate.png"
        &"FISH": path = "res://assets/props/fish.png"
        &"ANTIDOTE": path = "res://assets/props/life_pot.png"
    if path.is_empty():
        return
    var tex := load(path) as Texture2D
    if tex == null:
        return
    carry_visual = Sprite2D.new()
    carry_visual.name = "CarryVisual"
    carry_visual.texture = tex
    var s := 26.0 / maxf(tex.get_width(), tex.get_height())
    carry_visual.scale = Vector2(s, s)
    carry_visual.position = Vector2(0, -20)
    cat.add_child(carry_visual)

func _clear_carry_visual() -> void:
    if carry_visual != null and is_instance_valid(carry_visual):
        carry_visual.queue_free()
    carry_visual = null

func _drop_carry_item() -> void:
    if cat == null or cat.carry_item == &"":
        return
    if carry_visual != null and is_instance_valid(carry_visual):
        var dropped := carry_visual.duplicate() as Sprite2D
        dropped.top_level = true
        dropped.global_position = cat.global_position + Vector2(10, 12)
        add_child(dropped)
        var tw := create_tween()
        tw.tween_property(dropped, "modulate:a", 0.0, 0.35)
        tw.tween_callback(dropped.queue_free)
    cat.carry_item = &""
    _clear_carry_visual()

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
                if level_data != null and level_data.level_id == &"L05":
                    dog.lure_to(Vector2(360, 560))
                else:
                    dog.lure_to(cat.global_position + Vector2(120, 0))
        &"DOG_LURE_GUARD":
            _send_l06_dog_to_guard(int(effect.amount))
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

func _send_l06_dog_to_guard(guard_index: int) -> void:
    if level_data == null or level_data.level_id != &"L06" or dog == null:
        return
    if guard_index < 0 or guard_index >= guards.size():
        return
    var guard := guards[guard_index]
    if guard == null:
        return
    l06_dog_guard_target = guard_index
    l06_dog_help_pending = true
    dog.lure_to(guard.global_position)
    event_log.append_event({
        "event_id": StringName("L06_DOG_SENT_%d" % guard_index),
        "action": &"DOG_ASSIST",
        "success": true,
        "guard_index": guard_index,
    })
    _show_toast("狗狗出发：去把守卫引开。")

func _on_l06_dog_arrived(_target: Vector2) -> void:
    if level_data == null or level_data.level_id != &"L06" or l06_dog_guard_target < 0:
        return
    var idx := l06_dog_guard_target
    if idx >= guards.size():
        return
    var guard := guards[idx]
    if guard != null:
        guard.call("depart", dog.global_position, 6.0)
    dog.bark()
    var flag: StringName = &"L06_GUARD_A_SAFE" if idx == 0 else &"L06_GUARD_B_SAFE"
    world_state.set_flag(flag)
    event_log.append_event({
        "event_id": StringName("L06_DOG_BARK_GUARD_%d" % idx),
        "action": &"BARK",
        "success": true,
        "guard_index": idx,
        "world_changes": [flag],
    })
    _show_toast("狗狗成功把守卫 %s 引开了！" % ("A" if idx == 0 else "B"))
    l06_dog_guard_target = -1
    l06_dog_help_pending = false
    if ninja != null:
        ninja.release_event()

func _on_l08_dog_arrived(_target: Vector2) -> void:
    if level_data == null or level_data.level_id != &"L08" or not l08_dog_assist_pending:
        return
    l08_dog_assist_pending = false
    if guards.size() > 1 and guards[1] != null and dog != null:
        guards[1].call("depart", dog.global_position, 6.0)
        dog.bark()
    world_state.set_flag(&"L08_DOG_GUARD_B_DONE")
    world_state.set_flag(&"L08_GUARD_B_SAFE")
    event_log.append_event({
        "event_id": &"L08_DOG_ASSIST_GUARD_B",
        "action": &"BARK",
        "success": true,
        "world_changes": [&"guard_b_safe", &"dog_assist"],
    })
    _show_toast("狗狗到位了！守卫 B 被引开，忍者可以继续。")
    if ninja != null:
        ninja.release_event()

func _l07_start_dog_route() -> void:
    if dog == null:
        return
    l07_dog_route_pending = true
    dog.lure_to(Vector2(685, 470))
    event_log.append_event({
        "event_id": &"L07_DOG_ROUTE",
        "action": &"DOG_ROUTE_CHANGE",
        "success": true,
        "world_changes": [&"dog_distracted"],
    })
    _show_toast("狗的路线改变了：桥口窗口正在打开……")

func _on_l07_dog_arrived(_target: Vector2) -> void:
    if level_data == null or level_data.level_id != &"L07" or not l07_dog_route_pending:
        return
    l07_dog_route_pending = false
    l07_bridge_open = true
    world_state.set_flag(&"L07_BRIDGE_OPEN")
    world_state.set_flag(&"L07_DOG_ROUTE_CHANGED")
    event_log.append_event({
        "event_id": &"L07_DOG_ROUTE_CHANGED",
        "action": &"DOG_ROUTE_READY",
        "success": true,
        "world_changes": [&"dog_distracted", &"bridge_open"],
    })
    if ninja != null:
        ninja.release_event()
    _show_toast("狗已经到位：桥口窗口打开。")

func _apply_l07_route_branch(early: bool) -> void:
    if not early or ninja == null:
        return
    var alt_points := [
        Vector2(110, 480),
        Vector2(420, 220),
        Vector2(650, 210),
        Vector2(590, 470),
        Vector2(590, 430),
        Vector2(720, 220),
        Vector2(840, 360),
        Vector2(1000, 350),
    ]
    ninja.replace_scripted_route(alt_points, 2)
    for node in event_nodes:
        if node.data.event_id == &"L07_E04_BRIDGE":
            node.data.route_index = 6
            node.position = alt_points[6]
        elif node.data.event_id == &"L07_E05_POISON":
            node.data.route_index = 5
            node.position = alt_points[5]
    event_log.append_event({
        "event_id": &"L07_ROUTE_BRANCH",
        "action": &"NINJA_SWITCH_TO_POISON_FIRST",
        "success": true,
        "world_changes": [&"route_changed"],
    })

func _on_event_failed(data: EventPointData, code: StringName) -> void:
    if level_failed or level_finished:
        return
    GlobalAudioManager.play_event_sfx("fail")
    event_failed.emit(code)
    for flag in data.failure_flags:
        world_state.set_flag(flag)
    event_log.append_event({"event_id": data.event_id, "action": &"FAIL", "success": false, "fail_code": code, "ninja_hp_before": ninja.hp if ninja else 0})
    if ninja:
        # 坠崖直接死；其余威胁扣 1 心但继续推进。
        ninja.take_damage(3 if code == &"FAIL_NINJA_DEATH" else 1)
    if level_data != null and level_data.level_id == &"L05":
        if data.event_id == &"L05_E01_GUARD_A" and not level_failed:
            l05_guard_a_depart_time = _l05_now()
            _show_toast("守卫 A 已离岗：8 秒后 B 会换岗。")
        if data.event_id == &"L05_E04_POISON" and not level_failed:
            l05_poisoned = true
            l05_poison_tick_timer = 5.0
            _show_toast("毒雾触发：每 5 秒 -1 心。尽快让他穿出去。")
    if level_data != null and level_data.level_id == &"L06":
        # 失败路径仍允许继续：守卫被忍者自己处理掉，后续事件继续开放，但记一次扣心。
        if data.event_id == &"L06_E02_GUARD_A":
            world_state.set_flag(&"L06_GUARD_A_SAFE")
        elif data.event_id == &"L06_E04_GUARD_B":
            world_state.set_flag(&"L06_GUARD_B_SAFE")
    if level_data != null and level_data.level_id == &"L11":
        match data.event_id:
            &"L11_E02_DYNAMITE":
                l11_dynamite_missed = true
                world_state.set_flag(&"L11_DYNAMITE_MISSED")
            &"L11_E05_GUARD_B":
                l11_guard_b_urgent = true
                world_state.set_flag(&"L11_GUARD_B_URGENT")
                world_state.set_flag(&"L11_GUARD_B_SAFE")
    if level_data != null and level_data.level_id == &"L10":
        match data.event_id:
            &"L10_E02_GUARD_A":
                l10_guard_a_stays = true
                l10_guard_a_departed = false
                world_state.set_flag(&"L10_GUARD_A_STAYS")
                _show_toast("守卫 A 留岗：后面会被迫进入毒雾路线。")
            &"L10_E04_CALTROP":
                l10_caltrop_armed = false
                l10_caltrop_deadline = -1.0
                _show_toast("忍者硬闯蒺藜，掉 1 心，但任务继续。")
    if level_data != null and level_data.level_id == &"L08":
        # L08 允许失败后继续，但保留心数损失；Guard B 失败后视作“忍者自己扛过去”。
        if data.event_id == &"L08_E01_GUARD_A":
            world_state.set_flag(&"L08_GUARD_A_SAFE")
        elif data.event_id == &"L08_E03_GUARD_B":
            world_state.set_flag(&"L08_GUARD_B_SAFE")
            l08_dog_assist_pending = false
    if level_failed:
        return
    if ninja:
        ninja.release_event()
    if data.event_group == &"MAIN":
        var idx := _find_main_event_index(data.event_id)
        if idx == active_main_event_index:
            active_main_event_index += 1
    _set_label(status_label, "忍者受伤了！HP %d/3    R 重开" % (ninja.hp if ninja else 0))
    _show_toast(_fail_reason(code))
func _current_main_event() -> UnifiedEventPoint:
    if level_data != null and level_data.level_id == &"L11":
        var ordered_l11 := [&"L11_E01_GUARD_A", &"L11_E03_DOG", &"L11_E04_POISON", &"L11_E05_GUARD_B", &"L11_E06_CALTROP", &"L11_E07_GATE"]
        for wanted in ordered_l11:
            var node_l11 := _find_event_node(wanted)
            if node_l11 != null and not node_l11.resolved_state and is_event_active(node_l11.data):
                return node_l11
        return null
    if level_data != null and level_data.level_id == &"L10":
        var ordered_l10_main := [&"L10_E01_DYNAMITE_A", &"L10_E02_GUARD_A", &"L10_E03_DOG", &"L10_E04_POISON"]
        for wanted in ordered_l10_main:
            var node_l10 := _find_event_node(wanted)
            if node_l10 != null and not node_l10.resolved_state and is_event_active(node_l10.data):
                return node_l10
        return null

    if level_data != null and level_data.level_id == &"L09":
        var ordered_l09 := [&"L09_E01_TRIPWIRE", &"L09_E02_GUARD_A", &"L09_E03_DYNAMITE", &"L09_E04_DOG"]
        for wanted in ordered_l09:
            for node in event_nodes:
                if node.data.event_id == wanted and not node.resolved_state and is_event_active(node.data):
                    return node
        return null
    if level_data != null and level_data.level_id == &"L08":
        var ordered := [&"L08_E01_GUARD_A", &"L08_E02_DOG", &"L08_E03_GUARD_B", &"L08_E04_POISON", &"L08_E05_CALTROP", &"L08_E06_BRIDGE"]
        for wanted in ordered:
            for node in event_nodes:
                if node.data.event_id == wanted and not node.resolved_state and is_event_active(node.data):
                    return node
        return null
    if level_data != null and level_data.level_id == &"L07":
        var ordered := [&"L07_E01_GUARD_A", &"L07_E02_GUARD_B", &"L07_E03_DOG"]
        if l07_b_was_early:
            ordered += [&"L07_E05_POISON", &"L07_E04_BRIDGE"]
        else:
            ordered += [&"L07_E04_BRIDGE", &"L07_E05_POISON"]
        for wanted in ordered:
            for node in event_nodes:
                if node.data.event_id == wanted and not node.resolved_state and is_event_active(node.data):
                    return node
        return null
    if level_data != null and level_data.level_id == &"L06":
        var ordered := [&"L06_E01_DOG", &"L06_E02_GUARD_A", &"L06_E03_BRIDGE", &"L06_E04_GUARD_B", &"L06_E05_CALTROP"]
        for wanted in ordered:
            for node in event_nodes:
                if node.data.event_id == wanted and not node.resolved_state and is_event_active(node.data):
                    return node
        return null
    if level_data != null and level_data.level_id == &"L05":
        var ordered := [&"L05_E01_GUARD_A", &"L05_E02_DOG", &"L05_E03_BRIDGE", &"L05_E04_POISON", &"L05_E05_GUARD_B", &"L05_E06_CALTROP"]
        for wanted in ordered:
            for node in event_nodes:
                if node.data.event_id == wanted and not node.resolved_state:
                    return node
        return null
    if level_data != null and level_data.level_id == &"L04":
        for wanted in [&"L04_E01_GUARD", &"L04_E02_TRIPWIRE", &"L04_E03_CRATE", &"L04_E04_WATERGAP"]:
            for node in event_nodes:
                if node.data.event_id == wanted and is_event_active(node.data):
                    return node
        return null
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
        paws = score_system.evaluate(true, ninja.hp, max_suspicion, elapsed, high_risk_rescue, chain_rescue, shortcut_mastery, level_data.score_rules)
    _set_label(paw_label, "猫爪：%d / 3" % paws)
    _set_label(status_label, "任务完成！忍者：‘果然是我实力超群。’")
    _show_toast("结算中……")
    event_log.append_event({"event_id": &"GOAL", "event_type": &"GOAL", "action": &"COMPLETE", "success": true, "paws": paws, "emergency": emergency})
    var level_id := String(level_data.level_id)
    var first_clear := not save_manager.data.completed_levels.has(level_id)
    save_manager.mark_level_complete(level_id, paws, int(elapsed * 1000.0), int(max_suspicion))
    # 猫技艺计数（GDD §11.3）：事件级 + 关级摘要
    var unlocked: Array[String] = []
    for e in event_log.entries:
        unlocked.append_array(talent_tracker.ingest_event(e, save_manager.data))
    unlocked.append_array(talent_tracker.ingest_event({
        "event_type": "LEVEL",
        "level_clean": true,
        "max_suspicion": max_suspicion,
        "no_sprint": cat != null and cat.sprint_time <= 0.0,
        "dependency_depth": chain_rescue,
        "emergency_rescue": emergency,
    }, save_manager.data))
    if not unlocked.is_empty():
        save_manager.save_game()
    var result := {
        "level_id": level_id,
        "paws": paws,
        "mission_complete": true,
        "ninja_hp": ninja.hp if ninja else 0,
        "max_suspicion": max_suspicion,
        "elapsed_time": elapsed,
        "high_risk_rescue": high_risk_rescue,
        "chain_rescue": chain_rescue,
        "emergency": emergency,
        "unlocked_talents": unlocked,
    }
    SettlementContext.set_pending(result, event_log.entries, level_data.next_scene_path, level_data.scene_path, first_clear)
    level_completed.emit(result)
    await get_tree().create_timer(1.2).timeout
    if is_inside_tree():
        get_tree().change_scene_to_file("res://scenes/settlement/izakaya_settlement.tscn")

func on_ninja_dead() -> void:
    if level_failed or level_finished:
        return
    level_failed = true
    event_failed.emit(&"FAIL_NINJA_DEATH")
    _set_label(status_label, "任务失败：忍者倒下了（3 心耗尽）    R 重开")

func _process(_delta: float) -> void:
    _update_l05_state(_delta)
    _update_l07_state(_delta)
    _update_l10_state(_delta)
    _update_l11_state(_delta)
    if reading_phase:
        if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("confirm"):
            _end_reading_tour()
        return
    if not level_finished and not level_failed:
        _try_emergency()
        var elapsed := Time.get_ticks_msec() / 1000.0 - start_time
        _set_label(timer_label, "时间 %.1fs" % elapsed)
        _set_label(carry_label, "口中：" + (String(cat.carry_item) if cat and cat.carry_item != &"" else "空"))
        _set_label(suspicion_label, _suspicion_text())
        _update_hud()
    elif level_finished:
        if Input.is_action_pressed("retry"):
            SettlementContext.clear()
            get_tree().reload_current_scene()
    elif level_failed and Input.is_action_pressed("retry"):
        SettlementContext.clear()
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
        var base_state := "事件 %d/%d | Boss %s | 机关 %d | 应急 %s" % [active_main_event_index, _main_event_count(), "已启动" if boss_started else "未启动", boss_mechanics_success, "可用" if emergency_available else "—"]
        if level_data != null and level_data.level_id == &"L05":
            var shift := "B 已换岗" if l05_guard_b_activated else ("B 还剩 %.1fs" % maxf(0.0, 8.0 - (_l05_now() - l05_guard_a_depart_time)) if l05_guard_a_depart_time >= 0.0 else "先处理守卫 A")
            base_state += " | " + shift
        if level_data != null and level_data.level_id == &"L07":
            var shift_l07 := "B 稳定换岗" if l07_guard_b_activated else ("B 换岗倒计时 %.1fs" % maxf(0.0, 8.0 - (_l05_now() - l07_guard_a_depart_time)) if l07_guard_a_depart_time >= 0.0 else "先处理 A")
            var route_l07 := "毒雾优先线" if l07_b_was_early else "桥→毒雾标准线"
            var dog_l07 := "狗已改线" if world_state.get_flag(&"L07_DOG_ROUTE_CHANGED") else "狗未改线"
            base_state += " | " + shift_l07 + " | " + route_l07 + " | " + dog_l07
        if level_data != null and level_data.level_id == &"L08":
            var dog_l08 := "狗队友已建立" if world_state.get_flag(&"L08_DOG_ALLY") else "先喂狗"
            var assist_l08 := "狗已到位" if world_state.get_flag(&"L08_DOG_GUARD_B_DONE") else ("狗正在赶路" if l08_dog_assist_pending else "未派狗")
            var bridge_l08 := "桥已放下" if l08_bridge_open else "桥未处理"
            base_state += " | " + dog_l08 + " | " + assist_l08 + " | " + bridge_l08
        if level_data != null and level_data.level_id == &"L09":
            base_state += " | 雷雨：忍者 66px/s | 窗口：0.5s | 鱼：Q"
        if level_data != null and level_data.level_id == &"L11":
            var dyn := "炸药 %.1fs" % maxf(0.0, l11_dynamite_window) if l11_dynamite_window >= 0.0 and not l11_dynamite_missed else ("炸药已处理" if world_state.get_flag(&"L11_DYNAMITE_SAFE") else "炸药已失误")
            var gb := "B 倒计时 %.1fs" % maxf(0.0, l11_guard_b_window) if l11_guard_b_window > 0.0 else ("B 高压" if l11_guard_b_urgent else ("B 已处理" if world_state.get_flag(&"L11_GUARD_B_SAFE") else "B 未启动"))
            var dog_l11 := "狗已引走" if l11_dog_diverted else "狗未引走"
            base_state += " | 双线程 | " + dyn + " | " + gb + " | " + dog_l11
        if level_data != null and level_data.level_id == &"L10":
            var l10_guard := "A 已换位" if l10_guard_a_shifted else "A 未换位"
            if l10_guard_a_departed:
                l10_guard += "/已离岗"
            elif l10_guard_a_stays:
                l10_guard += "/留岗"
            var l10_cal := "蒺藜窗口开" if l10_caltrop_armed else ("蒺藜已清" if l10_caltrop_cleared else "蒺藜未开")
            base_state += " | 炸药→守卫→狗→路线 | " + l10_guard + " | " + l10_cal + " | 路线:" + String(l10_route_mode)
        state_label.text = base_state
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
