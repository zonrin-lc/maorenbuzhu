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
var balance_director := BalanceDirector.new()
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

# Boss integration（Boss 领域状态与流程已抽出到 BossDirector，见 scripts/gameplay/boss_director.gd）
var boss_director: BossDirector
# 关卡特例簇（L03-L11 定制逻辑已抽出到 LevelSpecialsDirector，见 scripts/gameplay/levels/level_specials_director.gd）
var specials: LevelSpecialsDirector

# Hard Mode / Variant B（GDD §5.3）：修饰只作用于 _prepare_level_data() 深拷贝出的运行时副本，
# 磁盘上的 LevelData/RouteData/EventPointData .tres 永不被改写。
var active_variant: VariantData = null
var active_modifier: LevelModifier = null
var _suspicion_gain_mult := 1.0

const SUSPICION_NOTICE := 25.0
const SUSPICION_ALERT := 50.0
const SUSPICION_HIGH := 80.0

func _ready() -> void:
    _cache_nodes()
    save_manager = get_node("/root/SaveManager") as SaveManagerClass
    talent_tracker = TalentTrackerClass.new()
    add_child(talent_tracker)
    _prepare_level_data()
    SceneArtBuilder.build_floor(self)
    _setup_layout_geometry()
    _setup_layout_design()
    _setup_shortcuts()
    _setup_specials()
    _setup_boss_director()
    SceneArtBuilder.build_decorations(self, level_data)
    var errors := validator.validate_level(level_data)
    if not errors.is_empty():
        _set_label(status_label, "VALIDATION ERROR: " + ", ".join(errors))
        set_process(false)
        return
    balance_director.setup(level_data)
    ninja.setup(level_data.ninja_route, self)
    if cat:
        cat.meow_triggered.connect(_on_cat_meow)
        cat.emote_triggered.connect(_on_cat_emote)
        cat.action_started.connect(_on_cat_action_started)
    if boss:
        boss.setup(self)
        boss.phase_changed.connect(boss_director.on_phase)
        boss.defeated.connect(boss_director.on_defeated)
        boss.retreat.connect(boss_director.on_retreat)
    _build_events()
    _place_guards_and_dog()
    _set_label(status_label, "%s · %s" % [String(level_data.chapter_id), level_data.display_name])
    _set_label(help_label, "移动 / 疾跑 / 互动 / 叼取放置 / 喵叫 / 卖萌 / 重开")
    _show_toast("先观察，再让事情按你的顺序发生。")
    _play_chapter_music()
    GlobalAudioManager.play_event_sfx("read_map")
    if dog != null and not dog.barked.is_connected(_on_dog_barked):
        dog.barked.connect(_on_dog_barked)
    if dog != null and not dog.arrived_at_target.is_connected(specials.on_l06_dog_arrived):
        dog.arrived_at_target.connect(specials.on_l06_dog_arrived)
    if dog != null and not dog.arrived_at_target.is_connected(specials.on_l07_dog_arrived):
        dog.arrived_at_target.connect(specials.on_l07_dog_arrived)
    if dog != null and not dog.arrived_at_target.is_connected(specials.on_l08_dog_arrived):
        dog.arrived_at_target.connect(specials.on_l08_dog_arrived)
    if dog != null and not dog.arrived_at_target.is_connected(specials.on_l10_dog_arrived):
        dog.arrived_at_target.connect(specials.on_l10_dog_arrived)
    # L11 uses the dog as a timed diversion, not as an ally state.
    _setup_global_ui()
    _setup_feedback_director()
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
    if cat != null:
        ui.bind_cat(cat)
    add_child(TouchControls.new())
    _setup_pause(ui)

func _setup_feedback_director() -> void:
    feedback_director = FeedbackDirector.new()
    feedback_director.name = "FeedbackDirector"
    add_child(feedback_director)
    specials.feedback_director = feedback_director
    if boss_director != null:
        boss_director.feedback_director = feedback_director
    if ninja != null and ninja.has_signal("damaged"):
        ninja.damaged.connect(_on_feedback_ninja_damaged)

func _on_feedback_ninja_damaged(hp: int) -> void:
    GlobalAudioManager.play_event_sfx("damage")
    GlobalAudioManager.play_ninja_voice("hurt")
    if feedback_director != null:
        feedback_director.show_ninja_damage(hp)

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

# 关卡加载/重开（reload_current_scene 会重新走 _ready）的统一入口：
# 不开 Hard、不选 Variant B 时直接返回，默认路径与原行为完全一致。
func _prepare_level_data() -> void:
    if level_data == null:
        return
    var want_variant := false
    if level_data.variant != null and bool(GlobalFlowMemory.variant_b_selected.get(String(level_data.level_id), false)):
        want_variant = true
    var want_hard := save_manager.data.hard_mode_unlocked and save_manager.data.hard_mode_enabled
    if not want_variant and not want_hard:
        return
    level_data = level_data.duplicate(true)
    if want_variant:
        _apply_variant(level_data.variant)
    if want_hard:
        var modifier := load("res://data/modifiers/hard_mode.tres") as LevelModifier
        if modifier != null:
            _apply_level_modifier(modifier)

func _apply_level_modifier(mod: LevelModifier) -> void:
    active_modifier = mod
    if level_data.ninja_route != null:
        level_data.ninja_route.move_speed *= mod.ninja_speed_mult
    for event_data in level_data.events:
        event_data.hesitation_time = maxf(0.0, event_data.hesitation_time + mod.hesitation_delta)
        # hesitation 是事件总窗口的前段：犹豫缩短 = 总窗口同步缩短（hard 更紧）。
        if mod.hesitation_delta < 0.0 and event_data.timeout > 0.0:
            event_data.timeout = maxf(0.5, event_data.timeout + mod.hesitation_delta)
        if event_data.timeout > 0.0:
            event_data.timeout = maxf(0.5, event_data.timeout * mod.event_timeout_mult)
    _suspicion_gain_mult *= mod.suspicion_gain_mult
    if boss != null:
        boss.prepare_time = maxf(0.5, boss.prepare_time + mod.boss_prepare_delta)

func _apply_variant(v: VariantData) -> void:
    active_variant = v
    # timer_overrides: "target_time"（绝对值）或 "target_time_mult"；"event_timeout_mult" 作用于全部事件窗口。
    if v.timer_overrides.has("target_time"):
        level_data.target_time = float(v.timer_overrides["target_time"])
        if level_data.score_rules != null:
            level_data.score_rules.target_time = level_data.target_time
    else:
        var target_mult := float(v.timer_overrides.get("target_time_mult", 1.0))
        level_data.target_time *= target_mult
        if level_data.score_rules != null:
            level_data.score_rules.target_time *= target_mult
    var timeout_mult := float(v.timer_overrides.get("event_timeout_mult", 1.0))
    for event_data in level_data.events:
        if event_data.timeout > 0.0 and not is_equal_approx(timeout_mult, 1.0):
            event_data.timeout = maxf(0.5, event_data.timeout * timeout_mult)
        if v.event_overrides.has(event_data.event_id):
            var override: Dictionary = v.event_overrides[event_data.event_id]
            if override.has("timeout") and event_data.timeout > 0.0:
                event_data.timeout = maxf(0.5, float(override["timeout"]))
            if override.has("hesitation_time"):
                event_data.hesitation_time = maxf(0.0, float(override["hesitation_time"]))
    _suspicion_gain_mult *= v.suspicion_modifier
    # route_overrides: {"waypoints": [...]} 替换忍者路线（_prepare_level_data 已深拷贝，可安全改写）
    if v.route_overrides.has("waypoints") and level_data.ninja_route != null:
        var wps: Array = v.route_overrides["waypoints"]
        if wps.size() >= 2:
            level_data.ninja_route.waypoints = PackedVector2Array(wps)
    # npc_overrides: {"<event_id>": Vector2}（守卫）或 {"DOG": Vector2}——在 _place_guards_and_dog 应用

# 读图镜头巡游（GDD §2.1）：开场推进到每个主线事件点，再拉回全景；按互动/确认跳过
var reading_phase := false
var _tour_tween: Tween
var _cam: Camera2D
var save_manager: SaveManagerClass
var talent_tracker: TalentTrackerClass
var carry_visual: Sprite2D
var feedback_director: FeedbackDirector
var layout_presentation: LayoutPresentation

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
        if layout_presentation != null:
            _tour_tween.tween_callback(layout_presentation.set_focus.bind(node.position))
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
    if layout_presentation != null:
        layout_presentation.set_reading_mode(false)
    start_time = Time.get_ticks_msec() / 1000.0
    if not specials.on_reading_tour_ended():
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
    geometry.visible = false
    add_child(geometry)

func _setup_layout_design() -> void:
    if level_data == null or level_data.ninja_route == null:
        return
    layout_presentation = LayoutPresentation.new()
    layout_presentation.name = "LayoutPresentation"
    layout_presentation.z_index = -75
    var lid := String(level_data.level_id)
    layout_presentation.setup(level_data.level_id, level_data.ninja_route.waypoints, LAYOUT_ZONES.get(lid, []))
    add_child(layout_presentation)

func _setup_specials() -> void:
    specials = LevelSpecialsDirector.new()
    specials.level_id = level_data.level_id if level_data != null else &""
    specials.level_data = level_data
    specials.level_manager = self
    specials.ninja = ninja
    specials.cat = cat
    specials.dog = dog
    specials.guards = guards
    specials.event_nodes = event_nodes
    specials.world_state = world_state
    specials.event_log = event_log
    specials.add_host_child = Callable(self, "add_child")
    specials.show_toast = Callable(self, "_show_toast")
    specials.find_event_node = Callable(self, "_find_event_node")
    specials.host_is_event_active = Callable(self, "is_event_active")
    specials.get_active_main_event_index = func() -> int: return active_main_event_index
    specials.is_reading_phase = func() -> bool: return reading_phase
    specials.is_level_failed = func() -> bool: return level_failed
    specials.is_level_finished = func() -> bool: return level_finished
    specials.notify_high_risk = func() -> void: high_risk_rescue += 1
    specials.setup_level()

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
    if feedback_director != null:
        feedback_director.show_shortcut()
    shortcut_mastery = true
    if level_data != null and level_data.level_id == &"L07":
        world_state.set_flag(&"L07_SHORTCUT_USED")
    if level_data != null and level_data.level_id == &"L04" and world_state.get_flag(&"L04_GUARD_SAFE") and world_state.get_flag(&"L04_TRIPWIRE_SAFE"):
        world_state.set_flag(&"L04_SHORTCUT_USED")
        # Route B 已经满足水沟前置条件，释放当前可能正在水沟前等待的 Ninja。
        if ninja != null:
            ninja.release_event()
    event_log.append_event({"event_id": &"SHORTCUT", "action": &"CAT_SHORTCUT", "success": true, "level_id": level_data.level_id if level_data else &""})
    GlobalAudioManager.play_event_sfx("shortcut")
    _show_toast("捷径成功：猫先到了。" if level_data == null or level_data.level_id != &"L04" else "路线 B：抄近路，直接去处理木桥。")

# 装饰层（GDD §8.2 四级装饰：永不抢玩法反馈）——确定性散布（种子=level_id），非随机地图
const PLAY_RECT := Rect2(40, 115, 1020, 500)

func _find_event_node(event_id: StringName) -> UnifiedEventPoint:
    for node in event_nodes:
        if node.data.event_id == event_id:
            return node
    return null

func _setup_boss_director() -> void:
    if boss == null:
        return
    boss_director = BossDirector.new()
    boss_director.boss = boss
    boss_director.ninja = ninja
    boss_director.cat = cat
    boss_director.world_state = world_state
    boss_director.event_log = event_log
    boss_director.level_id = level_data.level_id if level_data != null else &""
    boss_director.find_event_node = Callable(self, "_find_event_node")
    boss_director.show_toast = Callable(self, "_show_toast")
    boss_director.complete_level = Callable(self, "_complete_level")
    boss_director.notify_ninja_dead = Callable(self, "on_ninja_dead")
    boss_director.is_level_failed = func() -> bool: return level_failed
    boss_director.is_level_finished = func() -> bool: return level_finished
    boss_director.setup_l12_slice()


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
                &"L10_E05_POISON": point.position = Vector2(860, 340)
        if level_data.level_id == &"L11":
            match data.event_id:
                &"L11_E01_GUARD_A": point.position = Vector2(350, 250)
                &"L11_E02_DYNAMITE": point.position = Vector2(500, 430)
                &"L11_E03_DOG": point.position = Vector2(610, 300)
                &"L11_E04_POISON": point.position = Vector2(720, 430)
                &"L11_E05_GUARD_B": point.position = Vector2(820, 250)
                &"L11_E06_CALTROP": point.position = Vector2(900, 380)
                &"L11_E07_GATE": point.position = Vector2(980, 220)
        if level_data.level_id == &"L12":
            match data.event_id:
                &"L12_E01_DYNAMITE": point.position = Vector2(270, 410)
                &"L12_E02_BOSS_CRANE": point.position = Vector2(540, 250)
                &"L12_E03_BOSS_GOURD": point.position = Vector2(410, 330)
                &"L12_E04_BOSS_CALTROP": point.position = Vector2(800, 430)
        if active_variant != null and active_variant.event_overrides.has(data.event_id):
            var event_override: Dictionary = active_variant.event_overrides[data.event_id]
            if event_override.has("position"):
                point.position = event_override["position"]
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
            if active_variant != null and active_variant.npc_overrides.has(data.event_id):
                center = active_variant.npc_overrides[data.event_id]
            if guard.has_method("setup"):
                guard.call("setup", center)
            guard.visible = true
            guard_i += 1
    for i in range(guard_i, guards.size()):
        if guards[i] != null:
            guards[i].visible = false
    if dog and active_variant != null and active_variant.npc_overrides.has(&"DOG"):
        dog.setup(active_variant.npc_overrides[&"DOG"])
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
    if level_data != null and level_data.level_id == &"L12":
        match data.event_id:
            &"L12_E01_DYNAMITE":
                return not boss_director.l12_event_done(&"L12_E01_DYNAMITE")
            &"L12_E02_BOSS_CRANE", &"L12_E03_BOSS_GOURD":
                return world_state.get_flag(&"l12_gate_open") and not boss_director.boss_started and not boss_director.l12_event_done(data.event_id)
            &"L12_E04_BOSS_CALTROP":
                return boss != null and boss_director.boss_started and boss.phase == 2 and not boss_director.l12_event_done(&"L12_E04_BOSS_CALTROP")
    if data.activation_flag != &"" and not world_state.get_flag(data.activation_flag):
        return false
    if data.activation_phase != 0:
        if boss == null or boss.phase != data.activation_phase:
            return false
    if data.event_group == &"BOSS_COMBAT":
        return boss != null and boss_director.boss_started
    if level_data != null and level_data.level_id == &"L12":
        match data.event_id:
            &"L12_E01_DYNAMITE":
                world_state.set_flag(&"l12_gate_open")
                _show_toast("外门清空：吊车和酒葫芦准备现在都可以做。")
            &"L12_E02_BOSS_CRANE":
                _show_toast("吊车机关已准备：Boss 开场会先吃掉 40% 血。")
            &"L12_E03_BOSS_GOURD":
                _show_toast("酒葫芦已经动过手脚：Boss 开场再掉 30% 血。")
            &"L12_E04_BOSS_CALTROP":
                _show_toast("蒺藜命中！Boss 最后一段血量被清空。")
    return specials.is_event_active(data)

func is_ninja_at_blocking_event(route_index: int) -> bool:
    # 对外 API 保留（NinjaController 调用），实现已迁移到 LevelSpecialsDirector。
    return specials.is_ninja_at_blocking_event(route_index)

func on_player_action_started(data: EventPointData, action_id: StringName) -> void:
    if boss != null and data.event_group == &"BOSS_COMBAT" and boss.phase != 2:
        return
    var seen := _ninja_sees_cat()
    var suspicion_gain := EventBehaviorRegistry.suspicion_for(data)
    if specials.suspicion_observer != null:
        suspicion_gain = specials.suspicion_observer.suspicion_for_action(data.interaction_time)
    if seen and action_id != &"PASSIVE" and action_id != &"EMOTE_CHECK":
        _apply_suspicion(suspicion_gain, action_id)
    event_log.append_event({"event_id": data.event_id, "action": action_id, "phase": &"ACTION_START", "suspicion": suspicion, "suspicion_gain": suspicion_gain if seen else 0.0, "seen_by_ninja": seen})

func _ninja_sees_cat() -> bool:
    if specials.suspicion_observer != null:
        return specials.suspicion_observer.sees_subject()
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
    if feedback_director != null:
        feedback_director.show_cat_action(action_id)
    match action_id:
        &"BITE", &"PUSH", &"INTERACT", &"PLACE_ANTIDOTE", &"PLACE_CRATE", &"FEED", &"SEND_DOG": GlobalAudioManager.play_event_sfx("interact")
        _: pass
    if action_id in [&"BITE", &"PUSH"] and _ninja_sees_cat():
        _apply_suspicion(15.0, action_id)

func _on_cat_meow() -> void:
    GlobalAudioManager.play_cat_meow()
    if level_finished or level_failed:
        return
    if feedback_director != null:
        feedback_director.show_cat_action(&"MEOW")
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
    var current := specials.current_main_event()
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
    if feedback_director != null:
        feedback_director.show_cat_action(&"EMOTE")
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
    var current := specials.current_main_event()
    if current != null and current.data.event_type == &"EMOTE_CHECK":
        current.resolve(&"EMOTE")
    GlobalAudioManager.play_event_sfx("emote")
    _show_toast("卖萌成功，怀疑清零。")

func _apply_suspicion(amount: float, source: StringName) -> void:
    if amount > 0.0:
        amount *= _suspicion_gain_mult
    var before := suspicion
    suspicion = clamp(suspicion + amount, 0.0, 100.0)
    max_suspicion = max(max_suspicion, suspicion)
    event_log.append_event({"event_id": &"SUSPICION", "action": source, "phase": &"INFO", "suspicion_before": before, "suspicion_after": suspicion})
    suspicion_changed.emit(suspicion)
    if amount > 0.0:
        GlobalAudioManager.play_ninja_voice("confused")
    if feedback_director != null:
        feedback_director.show_suspicion(suspicion)
    if suspicion >= 100.0:
        level_failed = true
        event_failed.emit(&"FAIL_SUSPICION")
        _set_label(status_label, "任务失败：被忍者发现你在搞事情。R 重开")

func event_resolved(data: EventPointData, action_id: StringName, point: UnifiedEventPoint = null) -> void:
    if level_failed or level_finished:
        return
    if feedback_director != null:
        feedback_director.show_event_resolved(data.event_type, data.display_name, action_id)
    for flag in data.success_flags:
        world_state.set_flag(flag)
    specials.on_event_resolved(data)
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
        var next_node := specials.current_main_event()
        next_route_event = next_node.data.event_id if next_node != null else &"GOAL"
    if level_data != null and level_data.level_id == &"L10":
        var next_l10 := specials.current_main_event()
        next_route_event = next_l10.data.event_id if next_l10 != null else &"GOAL"
    if level_data != null and level_data.level_id == &"L11":
        var next_l11 := specials.current_main_event()
        next_route_event = next_l11.data.event_id if next_l11 != null else &"GOAL"
    event_log.append_event({
        "event_id": data.event_id,
        "event_type": data.event_type,
        "action": action_id,
        "phase": &"RESOLVED",
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
        # GDD §7.4：仅当前一事件通过 caused_event_id 依赖链改变了本事件时，才计 chain_rescue。
        var prev_node := _find_event_node(previous_event_id)
        if prev_node != null and data.event_id in prev_node.data.caused_event_ids:
            chain_rescue += 1
    previous_event_id = data.event_id
    GlobalAudioManager.play_ninja_voice("proud")
    if data.high_risk:
        high_risk_rescue += 1
    if level_data != null and level_data.level_id == &"L04":
        # L04 不用单一索引锁死顺序：解决任一当前阻挡事件后，都重新计算下一阻挡点。
        if ninja:
            ninja.release_event()
    elif level_data != null and level_data.level_id == &"L06" and data.event_id in [&"L06_E02_GUARD_A", &"L06_E04_GUARD_B"]:
        # 必须等狗真实抵达守卫位置后再放行 Ninja。
        specials.l06_dog_help_pending = true
    elif level_data != null and level_data.level_id == &"L08" and data.event_id == &"L08_E03_GUARD_B":
        # 事件先解决，忍者继续等待；狗到位后再 release_event()。
        specials.l08_dog_assist_pending = true
    elif level_data != null and level_data.level_id == &"L10" and data.event_id == &"L10_E03_DOG":
        # 事件先解决，忍者继续等待；狗真正到位后再切换路线并释放。
        specials.l10_dog_pending = true
    elif data.event_group == &"MAIN" and _find_main_event_index(data.event_id) == active_main_event_index:
        active_main_event_index += 1
        if ninja and not (level_data != null and level_data.level_id == &"L07" and data.event_id == &"L07_E03_DOG"):
            ninja.release_event()
    GlobalAudioManager.play_event_sfx(GlobalAudioManager.event_sfx_for(data.event_type, action_id))
    if level_data != null and level_data.level_id == &"L04" and world_state.get_flag(&"L04_GUARD_SAFE") and world_state.get_flag(&"L04_TRIPWIRE_SAFE") and not world_state.get_flag(&"L04_CRATE_STOLEN") and not world_state.get_flag(&"L04_SHORTCUT_USED"):
        _show_toast("两处都处理好了：现在选箱子稳走，或抄捷径抢时间。")
    else:
        _show_toast("处理成功：%s" % data.display_name)
func _apply_event_side_effect(data: EventPointData, action_id: StringName) -> void:
    # Flags remain declarative facts; non-trivial behavior is expressed by EventEffectData.
    if data.event_type == &"STEAL_CRATE" and cat != null:
        cat.set_carry_item(&"CRATE")
        _set_carry_visual(&"CRATE")
        _show_toast("路线 A：箱子到手了。把它送到木桥。")
    for effect_resource in data.success_effects:
        var effect := effect_resource as EventEffectData
        if effect == null:
            continue
        _apply_effect(effect)
    if data.consume_carry_item != &"" and cat != null and cat.carry_item == data.consume_carry_item:
        cat.set_carry_item(&"")
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
    cat.set_carry_item(&"")
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
            specials.send_l06_dog_to_guard(int(effect.amount))
        &"BOSS_PREPARE_DAMAGE":
            if boss_director != null:
                boss_director.apply_prepare_damage(int(effect.amount))
        &"BOSS_COMBAT_DAMAGE":
            if boss_director != null and boss_director.apply_combat_damage(int(effect.amount), effect.phase_required, effect.effect_type):
                high_risk_rescue += 1
        _:
            pass

func _on_event_failed(data: EventPointData, code: StringName) -> void:
    if level_failed or level_finished:
        return
    if feedback_director != null:
        feedback_director.show_event_failed(code, data.display_name)
    GlobalAudioManager.play_event_sfx("fail")
    event_failed.emit(code)
    for flag in data.failure_flags:
        world_state.set_flag(flag)
    event_log.append_event({"event_id": data.event_id, "action": &"FAIL", "phase": &"FAILED", "success": false, "fail_code": code, "ninja_hp_before": ninja.hp if ninja else 0})
    if ninja:
        # 坠崖直接死；其余威胁扣 1 心但继续推进。
        ninja.take_damage(3 if code == &"FAIL_NINJA_DEATH" else 1)
    specials.on_event_failed(data, code)
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
    if boss != null and not boss_director.boss_started:
        boss_director.start_boss_sequence()
        return
    if specials.current_main_event() != null:
        return
    if boss != null and boss.active:
        return
    _complete_level(false)

func can_boss_finish() -> bool:
    # 对外 API 保留（BossController 直接调用），实现已迁移到 BossDirector。
    return boss_director != null and boss_director.can_finish()

func on_boss_overrun() -> void:
    # 对外 API 保留（BossController 通过 has_method/call 调用），实现已迁移到 BossDirector。
    if boss_director != null:
        boss_director.on_overrun()

func _complete_level(emergency: bool) -> void:
    if level_finished:
        return
    level_finished = true
    var elapsed := Time.get_ticks_msec() / 1000.0 - start_time
    var paws := 1
    if not emergency:
        var boss_mechanics := boss_director.boss_mechanics_success if boss_director != null else 0
        paws = score_system.evaluate(true, ninja.hp, max_suspicion, elapsed, high_risk_rescue, chain_rescue, shortcut_mastery, level_data.score_rules, boss_mechanics)
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
        "target_time": balance_director.target_time,
        "time_ratio": elapsed / maxf(1.0, balance_director.target_time),
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
    specials.update(_delta)
    if reading_phase:
        if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("confirm"):
            _end_reading_tour()
        return
    if not level_finished and not level_failed:
        if boss_director != null:
            boss_director.try_emergency()
        var elapsed := Time.get_ticks_msec() / 1000.0 - start_time
        _set_label(timer_label, "时间 %.1fs / %.0fs · %s" % [elapsed, balance_director.target_time, balance_director.status_text(elapsed)])
        var balance_warning := balance_director.next_warning(elapsed)
        if not balance_warning.is_empty():
            _show_toast(balance_warning)
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
        var boss_state_text := "未启动"
        var boss_mechanics := 0
        var emergency_text := "—"
        if boss_director != null:
            boss_state_text = "已启动" if boss_director.boss_started else "未启动"
            boss_mechanics = boss_director.boss_mechanics_success
            emergency_text = "可用" if boss_director.emergency_available else "—"
        var base_state := "事件 %d/%d | Boss %s | 机关 %d | 应急 %s" % [active_main_event_index, _main_event_count(), boss_state_text, boss_mechanics, emergency_text]
        base_state += specials.hud_suffix()
        if level_data != null and level_data.level_id == &"L12":
            var crane := "✓吊车" if world_state.get_flag(&"boss_crane_ready") else "○吊车"
            var gourd := "✓葫芦" if world_state.get_flag(&"boss_gourd_ready") else "○葫芦"
            var cal := "✓蒺藜" if world_state.get_flag(&"L12_E04_BOSS_CALTROP") else "○蒺藜"
            var phase := boss.phase if boss else 0
            var hp := boss.hp if boss else 100
            var emergency := "应急开启" if boss_director.emergency_available else "应急—"
            base_state += " | Boss P%d HP%d | %s %s %s | %s" % [phase, hp, crane, gourd, cal, emergency]
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
    if boss_director != null and boss_director.boss_started:
        draw_circle(BossDirector.EMERGENCY_POS, 24.0, Color(0.9, 0.2, 0.2, 0.15))
        draw_arc(BossDirector.EMERGENCY_POS, 28.0, 0.0, TAU, 32, Color("#f87171"), 2.0)
