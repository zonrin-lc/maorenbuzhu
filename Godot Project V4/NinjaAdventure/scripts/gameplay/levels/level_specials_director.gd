class_name LevelSpecialsDirector
extends RefCounted

# 关卡特例簇：L03-L11 的关卡定制逻辑（从 UnifiedLevelManager 抽出，逻辑与数值逐字保持不变）。
# 与 BossDirector 同一先例：ULM 在 _ready 注入依赖；信号/主干仍由 ULM 接入。

# L03
var suspicion_observer: SuspicionObserver
var emote_safe_zone: EmoteSafeZone

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

# L09
var l09_storm_fx: L09StormFX

# L10
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

# 依赖注入（由 UnifiedLevelManager 在 _ready 填充；feedback_director 在 _setup_feedback_director 延迟绑定）。
var level_id: StringName = &""
var level_data: LevelData
var level_manager  # CarryPickup.setup 的 manager 实参（运行时为 UnifiedLevelManager；不标注类型以避免类循环引用）
var ninja: NinjaController
var cat: CatController
var dog: DogController
var guards: Array[Node] = []
var event_nodes: Array[UnifiedEventPoint] = []
var world_state: WorldState
var event_log: EventLog
var feedback_director: FeedbackDirector
var add_host_child: Callable
var show_toast: Callable
var find_event_node: Callable
var host_is_event_active: Callable
var get_active_main_event_index: Callable
var is_reading_phase: Callable
var is_level_failed: Callable
var is_level_finished: Callable
var notify_high_risk: Callable

func setup_level() -> void:
    _setup_l03_suspicion()
    _setup_l05_carry_items()
    _setup_l06_dog_ally()
    _setup_l07_dependency_chain()
    _setup_l08_combo()
    _setup_l09_storm()
    _setup_l10_chain()
    _setup_l11_busy_gate()

func _setup_l03_suspicion() -> void:
    if level_id != &"L03":
        return
    suspicion_observer = SuspicionObserver.new()
    suspicion_observer.name = "SuspicionObserver"
    suspicion_observer.observer_path = NodePath("../Ninja")
    suspicion_observer.subject_path = NodePath("../Cat")
    suspicion_observer.z_index = -5
    add_host_child.call(suspicion_observer)

    emote_safe_zone = EmoteSafeZone.new()
    emote_safe_zone.name = "EmoteSafeZone"
    emote_safe_zone.position = Vector2(720, 470)
    emote_safe_zone.z_index = -4
    add_host_child.call(emote_safe_zone)

func _setup_l05_carry_items() -> void:
    if level_id != &"L05":
        return
    var root := Node2D.new()
    root.name = "L05CarryPickups"
    add_host_child.call(root)
    var fish := CarryPickup.new()
    fish.name = "FishPickup"
    root.add_child(fish)
    fish.position = Vector2(300, 510)
    fish.setup(&"FISH", level_manager)

    var antidote := CarryPickup.new()
    antidote.name = "AntidotePickup"
    root.add_child(antidote)
    antidote.position = Vector2(745, 235)
    antidote.setup(&"ANTIDOTE", level_manager)

    show_toast.call("Q：叼取鱼肉 / 解毒药。先看守卫 A 的换岗节奏。")

func _setup_l06_dog_ally() -> void:
    if level_id != &"L06":
        return
    var root := Node2D.new()
    root.name = "L06CarryPickups"
    add_host_child.call(root)
    var fish := CarryPickup.new()
    fish.name = "FishPickup"
    root.add_child(fish)
    fish.position = Vector2(250, 490)
    fish.setup(&"FISH", level_manager)
    show_toast.call("L06：Q 叼鱼肉；先和狗狗成为队友，再用 E 派狗去引开守卫。")

func _setup_l07_dependency_chain() -> void:
    if level_id != &"L07":
        return
    var root := Node2D.new()
    root.name = "L07CarryPickups"
    add_host_child.call(root)

    var fish := CarryPickup.new()
    fish.name = "FishPickup"
    root.add_child(fish)
    fish.position = Vector2(300, 350)
    fish.setup(&"FISH", level_manager)

    var antidote := CarryPickup.new()
    antidote.name = "AntidotePickup"
    root.add_child(antidote)
    antidote.position = Vector2(860, 250)
    antidote.setup(&"ANTIDOTE", level_manager)

    show_toast.call("L07：先处理谁会改变后面的路线。A 离岗 8 秒后，B 才是稳定解。")

func _setup_l08_combo() -> void:
    if level_id != &"L08":
        return
    var root := Node2D.new()
    root.name = "L08CarryPickups"
    add_host_child.call(root)
    var fish := CarryPickup.new()
    fish.name = "FishPickup"
    root.add_child(fish)
    fish.position = Vector2(250, 500)
    fish.setup(&"FISH", level_manager)

    var antidote := CarryPickup.new()
    antidote.name = "AntidotePickup"
    root.add_child(antidote)
    antidote.position = Vector2(610, 225)
    antidote.setup(&"ANTIDOTE", level_manager)
    show_toast.call("L08：先清守卫 A，再喂狗成为队友；然后派狗、送药、清蒺藜、放桥。")

func _setup_l09_storm() -> void:
    if level_id != &"L09":
        return
    l09_storm_fx = L09StormFX.new()
    l09_storm_fx.name = "L09StormFX"
    add_host_child.call(l09_storm_fx)

    var root := Node2D.new()
    root.name = "L09CarryPickups"
    add_host_child.call(root)
    var fish := CarryPickup.new()
    fish.name = "FishPickup"
    root.add_child(fish)
    fish.position = Vector2(685, 445)
    fish.setup(&"FISH", level_manager)
    show_toast.call("雷雨夜：忍者全程加速。Q 叼鱼，E 处理狗；每个窗口都更短。")

func _setup_l10_chain() -> void:
    if level_id != &"L10":
        return
    var root := Node2D.new()
    root.name = "L10ChainPickups"
    add_host_child.call(root)

    var fish := CarryPickup.new()
    fish.name = "FishPickup"
    root.add_child(fish)
    fish.position = Vector2(635, 430)
    fish.setup(&"FISH", level_manager)

    var antidote := CarryPickup.new()
    antidote.name = "AntidotePickup"
    root.add_child(antidote)
    antidote.position = Vector2(705, 260)
    antidote.setup(&"ANTIDOTE", level_manager)

    l10_late_antidote = CarryPickup.new()
    l10_late_antidote.name = "LateAntidotePickup"
    root.add_child(l10_late_antidote)
    l10_late_antidote.position = Vector2(800, 500)
    l10_late_antidote.setup(&"ANTIDOTE", level_manager)
    l10_late_antidote.visible = false
    l10_late_antidote.set_process(false)
    l10_late_antidote.picked_up.connect(on_l10_late_antidote_picked)
    show_toast.call("L10：先看炸药会改变谁的位置，再处理守卫、狗和提前开的蒺藜。")

func _setup_l11_busy_gate() -> void:
    if level_id != &"L11":
        return
    var root := Node2D.new()
    root.name = "L11CarryPickups"
    add_host_child.call(root)

    var fish := CarryPickup.new()
    fish.name = "FishPickup"
    root.add_child(fish)
    fish.position = Vector2(270, 500)
    fish.setup(&"FISH", level_manager)

    var antidote := CarryPickup.new()
    antidote.name = "AntidotePickup"
    root.add_child(antidote)
    antidote.position = Vector2(710, 505)
    antidote.setup(&"ANTIDOTE", level_manager)

    show_toast.call("L11：左右两条线程会同时变忙。炸药先处理；A 离岗后，B 的补位倒计时启动。")

func now() -> float:
    return Time.get_ticks_msec() / 1000.0

# 每帧更新：保持 ULM 原 _process 中的调用顺序（L05 -> L07 -> L10 -> L11）。
func update(delta: float) -> void:
    _update_l05_state(delta)
    _update_l07_state(delta)
    _update_l10_state(delta)
    _update_l11_state(delta)

func _l05_guard_b_ready() -> bool:
    return l05_guard_a_depart_time >= 0.0 and now() - l05_guard_a_depart_time >= 8.0

func _update_l05_state(delta: float) -> void:
    if level_id != &"L05" or is_reading_phase.call() or is_level_finished.call() or is_level_failed.call():
        return
    if l05_guard_a_depart_time >= 0.0 and not l05_guard_b_activated and _l05_guard_b_ready():
        l05_guard_b_activated = true
        world_state.set_flag(&"L05_GUARD_B_ACTIVE")
        if guards.size() > 1 and level_data.ninja_route.waypoints.size() > 6:
            var guard_b := guards[1]
            if guard_b != null and guard_b.has_method("setup"):
                guard_b.call("setup", level_data.ninja_route.waypoints[6] + Vector2(0, 70))
        show_toast.call("守卫 A 的空缺到了：B 正在 8 秒后换岗到路线上。")
        event_log.append_event({"event_id": &"L05_GUARD_B_SHIFT", "action": &"ROTATE", "success": true, "delay": 8.0})
    if l05_poisoned:
        l05_poison_tick_timer -= delta
        if l05_poison_tick_timer <= 0.0:
            l05_poison_tick_timer = 5.0
            if ninja != null and not ninja.waiting_for_event:
                ninja.take_damage(1)
                event_log.append_event({"event_id": &"L05_POISON_TICK", "action": &"POISON", "success": false, "ninja_hp": ninja.hp})
                show_toast.call("毒雾发作：忍者 -1 心。")

func _update_l07_state(_delta: float) -> void:
    if level_id != &"L07" or is_reading_phase.call() or is_level_finished.call() or is_level_failed.call():
        return
    if l07_guard_a_depart_time >= 0.0 and not l07_guard_b_activated and not l07_b_was_early and now() - l07_guard_a_depart_time >= 8.0:
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
        show_toast.call("8 秒到了：守卫 B 稳定换岗。现在处理不会改变后续路线。")

func _update_l10_state(delta: float) -> void:
    if level_id != &"L10" or is_reading_phase.call() or is_level_finished.call() or is_level_failed.call():
        return
    var current := current_main_event()
    if current != null and current.data.event_id == &"L10_E05_POISON" and cat != null and cat.carry_item == &"":
        if l10_late_antidote != null and is_instance_valid(l10_late_antidote) and not l10_late_antidote.visible:
            l10_late_antidote.visible = true
            l10_late_antidote.set_process(true)
            show_toast.call("晚到方案：毒雾前才出现最后一瓶解毒药。来得及，但这是高风险。")
            event_log.append_event({
                "event_id": &"L10_LATE_ANTIDOTE_WINDOW",
                "action": &"SPAWN_LATE",
                "success": true,
                "world_changes": [&"late_antidote_available"],
            })
    if l10_caltrop_armed and not l10_caltrop_cleared and ninja != null and ninja.waypoint_index >= 4:
        if l10_caltrop_deadline < 0.0:
            l10_caltrop_deadline = 2.5
            show_toast.call("蒺藜窗口提前：2.5 秒内处理，否则忍者会硬闯。")
        else:
            l10_caltrop_deadline -= delta
            if l10_caltrop_deadline <= 0.0:
                var caltrop := find_event_node.call(&"L10_E04_CALTROP") as UnifiedEventPoint
                if caltrop != null and not caltrop.resolved_state:
                    caltrop.fail(&"FAIL_WRONG_ORDER")
                l10_caltrop_armed = false
                l10_caltrop_deadline = -1.0

func _update_l11_state(delta: float) -> void:
    if level_id != &"L11" or is_reading_phase.call() or is_level_finished.call() or is_level_failed.call():
        return

    var dynamite := find_event_node.call(&"L11_E02_DYNAMITE") as UnifiedEventPoint
    if l11_dynamite_window < 0.0 and not l11_dynamite_missed and dynamite != null and not dynamite.resolved_state and world_state.get_flag(&"L11_READING_DONE"):
        l11_dynamite_window = 6.0

    if l11_dynamite_window >= 0.0 and not l11_dynamite_missed and dynamite != null and not dynamite.resolved_state:
        l11_dynamite_window -= delta
        if l11_dynamite_window <= 0.0:
            l11_dynamite_window = 0.0
            l11_dynamite_missed = true
            world_state.set_flag(&"L11_DYNAMITE_MISSED")
            dynamite.fail(&"FAIL_TOO_LATE")
            show_toast.call("炸药来不及了！忍者前方少了一层缓冲，剩下的要抢着处理。")

    if l11_guard_b_window >= 0.0 and not world_state.get_flag(&"L11_GUARD_B_SAFE"):
        l11_guard_b_window -= delta
        if l11_guard_b_window <= 0.0:
            l11_guard_b_window = 0.0
            l11_guard_b_urgent = true
            world_state.set_flag(&"L11_GUARD_B_URGENT")
            show_toast.call("右翼守卫已经补位：靠近城门后窗口只剩最后一轮。")

    # E05 is a real blocking event; when Ninja reaches it, failure causes one heart loss but does not end the level.
    if ninja != null and ninja.waypoint_index >= 5:
        var guard_b := find_event_node.call(&"L11_E05_GUARD_B") as UnifiedEventPoint
        if guard_b != null and not guard_b.resolved_state and guard_b.is_inside_tree():
            if guard_b.timer >= guard_b.data.timeout and not l11_guard_b_urgent:
                l11_guard_b_urgent = true
                world_state.set_flag(&"L11_GUARD_B_URGENT")

func start_l11_pressure_after_reading() -> void:
    if level_id != &"L11":
        return
    world_state.set_flag(&"L11_READING_DONE")
    l11_dynamite_window = 6.0

# 读图结束时的关卡提示；返回 true 表示本关已处理（ULM 否则显示默认提示）。
func on_reading_tour_ended() -> bool:
    if level_id == &"L05":
        show_toast.call("码头节奏：守卫 A 离岗后 8 秒，守卫 B 换岗到路线。")
        return true
    if level_id == &"L11":
        start_l11_pressure_after_reading()
        show_toast.call("L11：炸药线程已经倒计时；守卫 A 处理后，右翼线程会一起启动。")
        return true
    return false

# 合并自 ULM 中五个完全相同的 _lXX_event_done。
func event_done(event_id: StringName) -> bool:
    for node in event_nodes:
        if node.data.event_id == event_id:
            return node.resolved_state
    return false

# ULM.is_event_active 的关卡分支部分（L11 -> L10 -> L09 -> L08 -> L07 -> L06 -> L05 -> L04，顺序不变）。
func is_event_active(data: EventPointData) -> bool:
    if level_id == &"L11":
        match data.event_id:
            &"L11_E01_GUARD_A": return not event_done(&"L11_E01_GUARD_A")
            &"L11_E02_DYNAMITE": return not event_done(&"L11_E02_DYNAMITE") and not l11_dynamite_missed
            &"L11_E03_DOG": return event_done(&"L11_E01_GUARD_A") and not event_done(&"L11_E03_DOG")
            &"L11_E04_POISON": return event_done(&"L11_E03_DOG") and not event_done(&"L11_E04_POISON")
            &"L11_E05_GUARD_B": return event_done(&"L11_E01_GUARD_A") and not event_done(&"L11_E05_GUARD_B")
            &"L11_E06_CALTROP": return event_done(&"L11_E04_POISON") and event_done(&"L11_E05_GUARD_B") and not event_done(&"L11_E06_CALTROP")
            &"L11_E07_GATE": return event_done(&"L11_E06_CALTROP") and not event_done(&"L11_E07_GATE")
        return false
    if level_id == &"L10":
        if data.event_id == &"L10_E04_CALTROP":
            var caltrop_node := find_event_node.call(&"L10_E04_CALTROP") as UnifiedEventPoint
            return l10_caltrop_armed and caltrop_node != null and not caltrop_node.resolved_state
        var ordered_l10 := [&"L10_E01_DYNAMITE_A", &"L10_E02_GUARD_A", &"L10_E03_DOG", &"L10_E05_POISON"]
        var wanted_index_l10 := ordered_l10.find(data.event_id)
        if wanted_index_l10 < 0:
            return false
        for i in range(wanted_index_l10):
            var prior_node_l10 := find_event_node.call(ordered_l10[i]) as UnifiedEventPoint
            if prior_node_l10 != null and not prior_node_l10.resolved_state:
                return false
        return not data.non_blocking and data.event_group != &"OPTIONAL"
    if level_id == &"L09":
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
    if level_id == &"L08":
        match data.event_id:
            &"L08_E01_GUARD_A": return not event_done(&"L08_E01_GUARD_A")
            &"L08_E02_DOG": return event_done(&"L08_E01_GUARD_A") and not event_done(&"L08_E02_DOG")
            &"L08_E03_GUARD_B": return world_state.get_flag(&"L08_DOG_ALLY") and event_done(&"L08_E02_DOG") and not event_done(&"L08_E03_GUARD_B")
            &"L08_E04_POISON": return event_done(&"L08_E03_GUARD_B") and world_state.get_flag(&"L08_GUARD_B_SAFE") and not event_done(&"L08_E04_POISON")
            &"L08_E05_CALTROP": return event_done(&"L08_E04_POISON") and world_state.get_flag(&"L08_POISON_SAFE") and not event_done(&"L08_E05_CALTROP")
            &"L08_E06_BRIDGE": return event_done(&"L08_E05_CALTROP") and world_state.get_flag(&"L08_CALTROP_SAFE") and not event_done(&"L08_E06_BRIDGE")
    if level_id == &"L07":
        match data.event_id:
            &"L07_E01_GUARD_A": return not event_done(&"L07_E01_GUARD_A")
            &"L07_E02_GUARD_B": return event_done(&"L07_E01_GUARD_A") and not event_done(&"L07_E02_GUARD_B")
            &"L07_E03_DOG": return event_done(&"L07_E01_GUARD_A") and not event_done(&"L07_E03_DOG")
            &"L07_E04_BRIDGE":
                if l07_b_was_early:
                    return event_done(&"L07_E05_POISON") and world_state.get_flag(&"L07_BRIDGE_OPEN") and not event_done(&"L07_E04_BRIDGE")
                return event_done(&"L07_E03_DOG") and world_state.get_flag(&"L07_BRIDGE_OPEN") and not event_done(&"L07_E04_BRIDGE")
            &"L07_E05_POISON":
                if l07_b_was_early:
                    return event_done(&"L07_E03_DOG") and not event_done(&"L07_E05_POISON")
                return event_done(&"L07_E04_BRIDGE") and not event_done(&"L07_E05_POISON")
    if level_id == &"L06":
        match data.event_id:
            &"L06_E01_DOG": return not event_done(&"L06_E01_DOG")
            &"L06_E02_GUARD_A": return event_done(&"L06_E01_DOG") and not event_done(&"L06_E02_GUARD_A")
            &"L06_E03_BRIDGE": return event_done(&"L06_E02_GUARD_A") and world_state.get_flag(&"L06_GUARD_A_SAFE") and not event_done(&"L06_E03_BRIDGE")
            &"L06_E04_GUARD_B": return event_done(&"L06_E03_BRIDGE") and not event_done(&"L06_E04_GUARD_B")
            &"L06_E05_CALTROP": return event_done(&"L06_E04_GUARD_B") and world_state.get_flag(&"L06_GUARD_B_SAFE") and not event_done(&"L06_E05_CALTROP")
    if level_id == &"L05":
        match data.event_id:
            &"L05_E01_GUARD_A": return not event_done(&"L05_E01_GUARD_A")
            &"L05_E02_DOG": return event_done(&"L05_E01_GUARD_A") and not event_done(&"L05_E02_DOG")
            &"L05_E03_BRIDGE": return event_done(&"L05_E02_DOG") and not event_done(&"L05_E03_BRIDGE")
            &"L05_E04_POISON": return event_done(&"L05_E03_BRIDGE") and not event_done(&"L05_E04_POISON")
            &"L05_E05_GUARD_B": return event_done(&"L05_E04_POISON") and world_state.get_flag(&"L05_GUARD_B_ACTIVE") and not event_done(&"L05_E05_GUARD_B")
            &"L05_E06_CALTROP": return event_done(&"L05_E05_GUARD_B") and not event_done(&"L05_E06_CALTROP")
    if level_id == &"L04":
        match data.event_id:
            &"L04_E01_GUARD": return not world_state.get_flag(&"L04_GUARD_SAFE")
            &"L04_E02_TRIPWIRE": return not world_state.get_flag(&"L04_TRIPWIRE_SAFE")
            &"L04_E03_CRATE": return world_state.get_flag(&"L04_GUARD_SAFE") and world_state.get_flag(&"L04_TRIPWIRE_SAFE") and not world_state.get_flag(&"L04_CRATE_STOLEN") and not world_state.get_flag(&"L04_SHORTCUT_USED")
            &"L04_E04_WATERGAP": return world_state.get_flag(&"L04_GUARD_SAFE") and world_state.get_flag(&"L04_TRIPWIRE_SAFE") and (world_state.get_flag(&"L04_CRATE_STOLEN") or world_state.get_flag(&"L04_SHORTCUT_USED")) and not world_state.get_flag(&"L04_WATERGAP_SAFE")
    return true

func is_ninja_at_blocking_event(route_index: int) -> bool:
    if level_id == &"L11":
        # E02 (dynamite) is deliberately non-blocking; all other main events block the fixed route.
        var current_l11 := current_main_event()
        if current_l11 == null or current_l11.resolved_state or current_l11.data.non_blocking:
            return false
        return route_index >= current_l11.data.route_index
    if level_id == &"L10":
        var caltrop := find_event_node.call(&"L10_E04_CALTROP") as UnifiedEventPoint
        if caltrop != null and host_is_event_active.call(caltrop.data) and not caltrop.resolved_state and route_index >= caltrop.data.route_index:
            return true
        var current_l10 := current_main_event()
        if current_l10 == null or current_l10.resolved_state:
            return false
        return route_index >= current_l10.data.route_index

    if level_id == &"L08":
        var current_l08 := current_main_event()
        if current_l08 == null or current_l08.resolved_state:
            return false
        return route_index >= current_l08.data.route_index
    if level_id == &"L07":
        var current_l07 := current_main_event()
        if current_l07 == null or current_l07.resolved_state or current_l07.data.non_blocking:
            return false
        return route_index >= current_l07.data.route_index
    if level_id == &"L06":
        var current_l06 := current_main_event()
        if current_l06 == null or current_l06.resolved_state:
            return false
        return route_index >= current_l06.data.route_index
    if level_id == &"L05":
        var current_l05 := current_main_event()
        if current_l05 == null or current_l05.resolved_state:
            return false
        return route_index >= current_l05.data.route_index
    if level_id == &"L04":
        var blocker := l04_blocking_event()
        if blocker == null:
            return false
        return route_index >= blocker.data.route_index and not blocker.resolved_state
    var current := current_main_event()
    if current == null or current.data.non_blocking or current.data.event_group != &"MAIN":
        return false
    return route_index >= current.data.route_index and not current.resolved_state

func l04_blocking_event() -> UnifiedEventPoint:
    # 两条路线共同的前半段允许任意顺序：Ninja 会在自己先到达的未处理事件处停住。
    for wanted in [&"L04_E01_GUARD", &"L04_E02_TRIPWIRE"]:
        for node in event_nodes:
            if node.data.event_id == wanted and host_is_event_active.call(node.data):
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

func current_main_event() -> UnifiedEventPoint:
    if level_id == &"L11":
        var ordered_l11 := [&"L11_E01_GUARD_A", &"L11_E03_DOG", &"L11_E04_POISON", &"L11_E05_GUARD_B", &"L11_E06_CALTROP", &"L11_E07_GATE"]
        for wanted in ordered_l11:
            var node_l11 := find_event_node.call(wanted) as UnifiedEventPoint
            if node_l11 != null and not node_l11.resolved_state and host_is_event_active.call(node_l11.data):
                return node_l11
        return null
    if level_id == &"L10":
        var ordered_l10_main := [&"L10_E01_DYNAMITE_A", &"L10_E02_GUARD_A", &"L10_E03_DOG", &"L10_E05_POISON"]
        for wanted in ordered_l10_main:
            var node_l10 := find_event_node.call(wanted) as UnifiedEventPoint
            if node_l10 != null and not node_l10.resolved_state and host_is_event_active.call(node_l10.data):
                return node_l10
        return null

    if level_id == &"L09":
        var ordered_l09 := [&"L09_E01_TRIPWIRE", &"L09_E02_GUARD_A", &"L09_E03_DYNAMITE", &"L09_E04_DOG"]
        for wanted in ordered_l09:
            for node in event_nodes:
                if node.data.event_id == wanted and not node.resolved_state and host_is_event_active.call(node.data):
                    return node
        return null
    if level_id == &"L08":
        var ordered := [&"L08_E01_GUARD_A", &"L08_E02_DOG", &"L08_E03_GUARD_B", &"L08_E04_POISON", &"L08_E05_CALTROP", &"L08_E06_BRIDGE"]
        for wanted in ordered:
            for node in event_nodes:
                if node.data.event_id == wanted and not node.resolved_state and host_is_event_active.call(node.data):
                    return node
        return null
    if level_id == &"L07":
        var ordered := [&"L07_E01_GUARD_A", &"L07_E02_GUARD_B", &"L07_E03_DOG"]
        if l07_b_was_early:
            ordered += [&"L07_E05_POISON", &"L07_E04_BRIDGE"]
        else:
            ordered += [&"L07_E04_BRIDGE", &"L07_E05_POISON"]
        for wanted in ordered:
            for node in event_nodes:
                if node.data.event_id == wanted and not node.resolved_state and host_is_event_active.call(node.data):
                    return node
        return null
    if level_id == &"L06":
        var ordered := [&"L06_E01_DOG", &"L06_E02_GUARD_A", &"L06_E03_BRIDGE", &"L06_E04_GUARD_B", &"L06_E05_CALTROP"]
        for wanted in ordered:
            for node in event_nodes:
                if node.data.event_id == wanted and not node.resolved_state and host_is_event_active.call(node.data):
                    return node
        return null
    if level_id == &"L05":
        var ordered := [&"L05_E01_GUARD_A", &"L05_E02_DOG", &"L05_E03_BRIDGE", &"L05_E04_POISON", &"L05_E05_GUARD_B", &"L05_E06_CALTROP"]
        for wanted in ordered:
            for node in event_nodes:
                if node.data.event_id == wanted and not node.resolved_state:
                    return node
        return null
    if level_id == &"L04":
        for wanted in [&"L04_E01_GUARD", &"L04_E02_TRIPWIRE", &"L04_E03_CRATE", &"L04_E04_WATERGAP"]:
            for node in event_nodes:
                if node.data.event_id == wanted and host_is_event_active.call(node.data):
                    return node
        return null
    var i := 0
    for node in event_nodes:
        if node.data.event_group == &"MAIN":
            if i == int(get_active_main_event_index.call()):
                return node
            i += 1
    return null

# ULM.event_resolved 中的关卡分支（L05/L06/L08/L11/L10/L07），调用位置不变。
func on_event_resolved(data: EventPointData) -> void:
    if level_id == &"L05":
        match data.event_id:
            &"L05_E01_GUARD_A":
                l05_guard_a_depart_time = now()
                show_toast.call("守卫 A 已被引开。记住：8 秒后 B 会换岗。")
            &"L05_E04_POISON":
                l05_poisoned = false
                l05_poison_tick_timer = 5.0
                show_toast.call("解毒成功，毒雾段安全了。")
    if level_id == &"L06":
        match data.event_id:
            &"L06_E01_DOG":
                world_state.set_flag(&"L06_DOG_ALLY")
                show_toast.call("狗狗加入队伍：以后可以用 E 派它去守卫那里。")
            &"L06_E03_BRIDGE":
                show_toast.call("木桥放下：前面的空档留给你和狗狗继续配合。")
            &"L06_E05_CALTROP":
                show_toast.call("铁蒺藜处理完成，出口就在前面。")
    if level_id == &"L08":
        match data.event_id:
            &"L08_E01_GUARD_A":
                if guards.size() > 0 and guards[0] != null:
                    guards[0].call("depart", cat.global_position if cat else Vector2(390, 370), 6.0)
                world_state.set_flag(&"L08_GUARD_A_DEPARTED")
                show_toast.call("守卫 A 已离岗：下一步先把狗变成你的队友。")
            &"L08_E02_DOG":
                world_state.set_flag(&"L08_DOG_ALLY")
                show_toast.call("狗狗加入队伍：现在用 E 派它去守卫 B。")
            &"L08_E03_GUARD_B":
                l08_dog_assist_pending = true
                if dog != null and guards.size() > 1 and guards[1] != null:
                    dog.lure_to(guards[1].global_position)
                show_toast.call("狗狗正在赶去守卫 B：到位前忍者先别动。")
            &"L08_E04_POISON":
                show_toast.call("毒雾段安全：最后两处就能赶上末班船。")
            &"L08_E05_CALTROP":
                show_toast.call("蒺藜清掉了：最后一段桥还等着放下。")
            &"L08_E06_BRIDGE":
                l08_bridge_open = true
                world_state.set_flag(&"L08_BRIDGE_OPEN")
                show_toast.call("桥放下了！末班船就在前面。")
    if level_id == &"L11":
        match data.event_id:
            &"L11_E01_GUARD_A":
                world_state.set_flag(&"L11_GUARD_A_SAFE")
                l11_guard_b_window = 8.0
                if guards.size() > 0 and guards[0] != null:
                    guards[0].call("depart", cat.global_position if cat else Vector2(350, 250), 6.0)
                show_toast.call("守卫 A 离岗：右翼线程启动，8 秒后补位。")
                event_log.append_event({"event_id": &"L11_THREAD_RIGHT_ARM", "action": &"ARM_GUARD_B_TIMER", "success": true, "delay": 8.0, "world_changes": [&"guard_b_timer_started"]})
            &"L11_E02_DYNAMITE":
                l11_dynamite_window = -1.0
                world_state.set_flag(&"L11_DYNAMITE_SAFE")
                show_toast.call("炸药已处理：中央线程清空。继续赶场。")
            &"L11_E03_DOG":
                l11_dog_diverted = true
                world_state.set_flag(&"L11_DOG_DIVERTED")
                if dog != null:
                    dog.lure_to(Vector2(490, 360))
                    dog.bark()
                show_toast.call("狗被鱼引走：左侧压力暂时减轻。")
            &"L11_E04_POISON":
                l11_poison_safe = true
                world_state.set_flag(&"L11_POISON_SAFE")
                show_toast.call("毒雾处理完成：别停，城门已经在眼前。")
            &"L11_E05_GUARD_B":
                l11_guard_b_window = -1.0
                l11_guard_b_urgent = false
                world_state.set_flag(&"L11_GUARD_B_SAFE")
                world_state.set_flag(&"L11_GUARD_B_URGENT", false)
                if guards.size() > 1 and guards[1] != null:
                    guards[1].call("depart", cat.global_position if cat else Vector2(820, 250), 6.0)
                show_toast.call("右翼守卫也被引开了：最后一段清蒺藜。")
            &"L11_E06_CALTROP":
                world_state.set_flag(&"L11_CALTROP_SAFE")
                show_toast.call("城门蒺藜清空：最后一关就是开门。")
            &"L11_E07_GATE":
                world_state.set_flag(&"L11_GATE_OPEN")
                show_toast.call("城门打开：一路忙到最后，终于赶上了。")
    if level_id == &"L10":
        match data.event_id:
            &"L10_E01_DYNAMITE_A":
                l10_guard_a_shifted = true
                world_state.set_flag(&"L10_DYNAMITE_A_SAFE")
                world_state.set_flag(&"L10_GUARD_A_SHIFTED")
                if guards.size() > 0 and guards[0] != null:
                    guards[0].call("setup", Vector2(600, 300))
                event_log.append_event({"event_id": &"L10_CHAIN_01", "action": &"DYNAMITE_TO_GUARD_SHIFT", "success": true, "caused_event_id": &"L10_E02_GUARD_A", "world_changes": [&"guard_a_shifted"], "route_change": &"L10_E02_GUARD_A"})
                show_toast.call("炸药被处理后，守卫 A 换位了。")
            &"L10_E02_GUARD_A":
                l10_guard_a_departed = true
                l10_guard_a_stays = false
                world_state.set_flag(&"L10_GUARD_A_DEPARTED")
                if guards.size() > 0 and guards[0] != null:
                    guards[0].call("depart", cat.global_position if cat else Vector2(560, 360), 6.0)
                event_log.append_event({"event_id": &"L10_CHAIN_02", "action": &"GUARD_TO_DOG", "success": true, "caused_event_id": &"L10_E03_DOG", "world_changes": [&"guard_a_departed"], "route_change": &"L10_E03_DOG"})
                show_toast.call("守卫 A 离岗：现在把狗引开。")
            &"L10_E03_DOG":
                l10_dog_pending = true
                if dog != null:
                    dog.lure_to(Vector2(740, 430))
                event_log.append_event({"event_id": &"L10_CHAIN_03", "action": &"DOG_STARTLED", "success": true, "caused_event_id": &"L10_E05_POISON", "world_changes": [&"dog_route_changed"], "route_change": l10_route_mode})
                show_toast.call("狗被鱼吸走：下一段路线开始改变。")
            &"L10_E04_CALTROP":
                l10_caltrop_armed = false
                l10_caltrop_cleared = true
                l10_caltrop_deadline = -1.0
                world_state.set_flag(&"L10_CALTROP_CLEARED")
                show_toast.call("蒺藜清掉了：赶去毒雾。")
                if ninja != null:
                    ninja.release_event()
            &"L10_E05_POISON":
                world_state.set_flag(&"L10_POISON_SAFE")
                show_toast.call("毒雾段处理完成：东门就在前面。")
    if level_id == &"L07":
        match data.event_id:
            &"L07_E01_GUARD_A":
                l07_guard_a_depart_time = now()
                world_state.set_flag(&"L07_GUARD_A_DEPARTED")
                if guards.size() > 0 and guards[0] != null:
                    guards[0].call("depart", cat.global_position if cat else Vector2(360, 170), 6.0)
                show_toast.call("守卫 A 离岗：8 秒后 B 才是稳定换岗解。")
            &"L07_E02_GUARD_B":
                if guards.size() > 1 and guards[1] != null:
                    guards[1].call("depart", cat.global_position if cat else Vector2(650, 210), 6.0)
                var early := l07_guard_a_depart_time < 0.0 or (now() - l07_guard_a_depart_time) < 8.0
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
                    show_toast.call("守卫 B 提前补位：桥口被堵，他改走毒雾侧线。")
                else:
                    show_toast.call("守卫 B 稳定补位：后面的桥口保持原路线。")
            &"L07_E03_DOG":
                _l07_start_dog_route()
            &"L07_E04_BRIDGE":
                l07_bridge_open = true
                world_state.set_flag(&"L07_BRIDGE_OPEN")
                world_state.set_flag(&"L07_BRIDGE_BLOCKED", false)
                show_toast.call("狗的路线已经把桥口窗口拉开了。")
            &"L07_E05_POISON":
                world_state.set_flag(&"L07_POISON_ROUTE_SAFE")
                show_toast.call("毒雾窗口处理完成：码头出口安全。")

# ULM._on_event_failed 中的关卡分支（L05/L06/L11/L10/L08），调用位置不变（ninja 扣血之后、level_failed 检查之前）。
func on_event_failed(data: EventPointData, _code: StringName) -> void:
    if level_id == &"L05":
        if data.event_id == &"L05_E01_GUARD_A" and not is_level_failed.call():
            l05_guard_a_depart_time = now()
            show_toast.call("守卫 A 已离岗：8 秒后 B 会换岗。")
        if data.event_id == &"L05_E04_POISON" and not is_level_failed.call():
            l05_poisoned = true
            l05_poison_tick_timer = 5.0
            show_toast.call("毒雾触发：每 5 秒 -1 心。尽快让他穿出去。")
    if level_id == &"L06":
        # 失败路径仍允许继续：守卫被忍者自己处理掉，后续事件继续开放，但记一次扣心。
        if data.event_id == &"L06_E02_GUARD_A":
            world_state.set_flag(&"L06_GUARD_A_SAFE")
        elif data.event_id == &"L06_E04_GUARD_B":
            world_state.set_flag(&"L06_GUARD_B_SAFE")
    if level_id == &"L11":
        match data.event_id:
            &"L11_E02_DYNAMITE":
                l11_dynamite_missed = true
                world_state.set_flag(&"L11_DYNAMITE_MISSED")
            &"L11_E05_GUARD_B":
                l11_guard_b_urgent = true
                world_state.set_flag(&"L11_GUARD_B_URGENT")
                world_state.set_flag(&"L11_GUARD_B_SAFE")
    if level_id == &"L10":
        match data.event_id:
            &"L10_E02_GUARD_A":
                l10_guard_a_stays = true
                l10_guard_a_departed = false
                world_state.set_flag(&"L10_GUARD_A_STAYS")
                show_toast.call("守卫 A 留岗：后面会被迫进入毒雾路线。")
            &"L10_E04_CALTROP":
                l10_caltrop_armed = false
                l10_caltrop_deadline = -1.0
                show_toast.call("忍者硬闯蒺藜，掉 1 心，但任务继续。")
    if level_id == &"L08":
        # L08 允许失败后继续，但保留心数损失；Guard B 失败后视作“忍者自己扛过去”。
        if data.event_id == &"L08_E01_GUARD_A":
            world_state.set_flag(&"L08_GUARD_A_SAFE")
        elif data.event_id == &"L08_E03_GUARD_B":
            world_state.set_flag(&"L08_GUARD_B_SAFE")
            l08_dog_assist_pending = false

func send_l06_dog_to_guard(guard_index: int) -> void:
    if level_id != &"L06" or dog == null:
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
    show_toast.call("狗狗出发：去把守卫引开。")

func on_l06_dog_arrived(_target: Vector2) -> void:
    if level_id != &"L06" or l06_dog_guard_target < 0:
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
    show_toast.call("狗狗成功把守卫 %s 引开了！" % ("A" if idx == 0 else "B"))
    l06_dog_guard_target = -1
    l06_dog_help_pending = false
    if ninja != null:
        ninja.release_event()

func on_l08_dog_arrived(_target: Vector2) -> void:
    if level_id != &"L08" or not l08_dog_assist_pending:
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
    show_toast.call("狗狗到位了！守卫 B 被引开，忍者可以继续。")
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
    show_toast.call("狗的路线改变了：桥口窗口正在打开……")

func on_l07_dog_arrived(_target: Vector2) -> void:
    if level_id != &"L07" or not l07_dog_route_pending:
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
    show_toast.call("狗已经到位：桥口窗口打开。")

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
    if feedback_director != null:
        GlobalAudioManager.play_event_sfx("route_change")
        feedback_director.show_route_change("忍者改走毒雾侧线")
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

func on_l10_late_antidote_picked(_item_id: StringName) -> void:
    notify_high_risk.call()
    event_log.append_event({
        "event_id": &"L10_LATE_ANTIDOTE",
        "action": &"CARRY_LATE",
        "success": true,
        "high_risk": true,
        "world_changes": [&"late_antidote_taken"],
    })
    show_toast.call("高风险补救：最后一瓶解毒药到手。")

func on_l10_dog_arrived(_target: Vector2) -> void:
    if level_id != &"L10" or not l10_dog_pending:
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
        show_toast.call("守卫 A 还在岗：狗被鱼吸走后，忍者被迫走毒雾路线。")
    else:
        l10_route_mode = &"STANDARD"
        l10_caltrop_armed = true
        l10_caltrop_cleared = false
        l10_caltrop_deadline = -1.0
        world_state.set_flag(&"L10_CALTROP_WINDOW_EARLY")
        show_toast.call("狗已改线：蒺藜窗口提前，先清蒺藜再处理毒雾。")
    if ninja != null:
        ninja.release_event()

func _apply_l10_route_branch(poison_forced: bool) -> void:
    if ninja == null:
        return
    if poison_forced:
        var points := [Vector2(110,540), Vector2(270,410), Vector2(590,360), Vector2(680,435), Vector2(820,300), Vector2(860,340), Vector2(980,260)]
        ninja.replace_scripted_route(points, 3)
        var poison := find_event_node.call(&"L10_E05_POISON") as UnifiedEventPoint
        if poison != null:
            poison.data.route_index = 5
            poison.position = points[5]
        if feedback_director != null:
            GlobalAudioManager.play_event_sfx("route_change")
            feedback_director.show_route_change("守卫仍在岗：忍者被迫走毒雾侧线")
    else:
        var points := [Vector2(110,540), Vector2(270,410), Vector2(590,360), Vector2(680,435), Vector2(740,460), Vector2(860,340), Vector2(980,260)]
        ninja.replace_scripted_route(points, 3)
        var caltrop := find_event_node.call(&"L10_E04_CALTROP") as UnifiedEventPoint
        var poison := find_event_node.call(&"L10_E05_POISON") as UnifiedEventPoint
        if caltrop != null:
            caltrop.data.route_index = 4
            caltrop.position = points[4]
        if poison != null:
            poison.data.route_index = 5
            poison.position = points[5]
        if feedback_director != null:
            GlobalAudioManager.play_event_sfx("route_change")
            feedback_director.show_route_change("狗引开后：蒺藜窗口提前")
    event_log.append_event({
        "event_id": &"L10_ROUTE_CHANGE",
        "action": &"ROUTE_SWITCH",
        "success": true,
        "route_change": l10_route_mode,
    })

# ULM._update_hud 中各关卡的状态栏后缀（L12 Boss 段留在 ULM，属于 BossDirector 领域）。
func hud_suffix() -> String:
    if level_id == &"L05":
        var shift := "B 已换岗" if l05_guard_b_activated else ("B 还剩 %.1fs" % maxf(0.0, 8.0 - (now() - l05_guard_a_depart_time)) if l05_guard_a_depart_time >= 0.0 else "先处理守卫 A")
        return " | " + shift
    if level_id == &"L07":
        var shift_l07 := "B 稳定换岗" if l07_guard_b_activated else ("B 换岗倒计时 %.1fs" % maxf(0.0, 8.0 - (now() - l07_guard_a_depart_time)) if l07_guard_a_depart_time >= 0.0 else "先处理 A")
        var route_l07 := "毒雾优先线" if l07_b_was_early else "桥→毒雾标准线"
        var dog_l07 := "狗已改线" if world_state.get_flag(&"L07_DOG_ROUTE_CHANGED") else "狗未改线"
        return " | " + shift_l07 + " | " + route_l07 + " | " + dog_l07
    if level_id == &"L08":
        var dog_l08 := "狗队友已建立" if world_state.get_flag(&"L08_DOG_ALLY") else "先喂狗"
        var assist_l08 := "狗已到位" if world_state.get_flag(&"L08_DOG_GUARD_B_DONE") else ("狗正在赶路" if l08_dog_assist_pending else "未派狗")
        var bridge_l08 := "桥已放下" if l08_bridge_open else "桥未处理"
        return " | " + dog_l08 + " | " + assist_l08 + " | " + bridge_l08
    if level_id == &"L09":
        return " | 雷雨：忍者 66px/s | 窗口：0.5s | 鱼：Q"
    if level_id == &"L11":
        var dyn := "炸药 %.1fs" % maxf(0.0, l11_dynamite_window) if l11_dynamite_window >= 0.0 and not l11_dynamite_missed else ("炸药已处理" if world_state.get_flag(&"L11_DYNAMITE_SAFE") else "炸药已失误")
        var gb := "B 倒计时 %.1fs" % maxf(0.0, l11_guard_b_window) if l11_guard_b_window > 0.0 else ("B 高压" if l11_guard_b_urgent else ("B 已处理" if world_state.get_flag(&"L11_GUARD_B_SAFE") else "B 未启动"))
        var dog_l11 := "狗已引走" if l11_dog_diverted else "狗未引走"
        return " | 双线程 | " + dyn + " | " + gb + " | " + dog_l11
    if level_id == &"L10":
        var l10_guard := "A 已换位" if l10_guard_a_shifted else "A 未换位"
        if l10_guard_a_departed:
            l10_guard += "/已离岗"
        elif l10_guard_a_stays:
            l10_guard += "/留岗"
        var l10_cal := "蒺藜窗口开" if l10_caltrop_armed else ("蒺藜已清" if l10_caltrop_cleared else "蒺藜未开")
        return " | 炸药→守卫→狗→路线 | " + l10_guard + " | " + l10_cal + " | 路线:" + String(l10_route_mode)
    return ""
