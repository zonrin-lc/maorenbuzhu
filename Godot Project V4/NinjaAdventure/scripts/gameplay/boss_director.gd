class_name BossDirector
extends RefCounted

# Boss 领域状态（从 UnifiedLevelManager 抽出，逻辑与数值保持不变）。
var boss_started := false
var boss_mechanics_success := 0
var emergency_available := false
var emergency_used := false
# L12 Boss slice: prep must happen before Boss starts; zero-prep requires emergency rescue.
var l12_boss_overrun_logged := false

const EMERGENCY_POS := Vector2(930, 290)

# 依赖注入（由 UnifiedLevelManager 在关卡加载时填充）。
var boss: BossController
var ninja: NinjaController
var cat: CatController
var world_state: WorldState
var event_log: EventLog
var feedback_director: FeedbackDirector
var level_id: StringName = &""
var find_event_node: Callable
var show_toast: Callable
var complete_level: Callable
var notify_ninja_dead: Callable
var is_level_failed: Callable
var is_level_finished: Callable

func setup_l12_slice() -> void:
    if level_id != &"L12":
        return
    # Prep items become available only after the outer dynamite/gate event,
    # then remain usable while Ninja walks toward the Boss arena.
    show_toast.call("L12：先做吊车/酒葫芦准备；都不做也能打，但最后要赶去应急门。")

func l12_event_done(event_id: StringName) -> bool:
    var node := find_event_node.call(event_id) as UnifiedEventPoint
    return node != null and node.resolved_state

func l12_prep_count() -> int:
    var count := 0
    if world_state.get_flag(&"boss_crane_ready"):
        count += 1
    if world_state.get_flag(&"boss_gourd_ready"):
        count += 1
    return count

func apply_prepare_damage(amount: int) -> void:
    if boss:
        boss.prepare(amount)
        boss_mechanics_success += 1

func apply_combat_damage(amount: int, phase_required: int, source: StringName) -> bool:
    if boss and boss.phase == phase_required:
        boss.damage(amount, source)
        boss_mechanics_success += 1
        return true
    return false

func start_boss_sequence() -> void:
    if boss == null or boss_started:
        return
    boss_started = true
    emergency_available = false
    emergency_used = false
    l12_boss_overrun_logged = false
    world_state.set_flag(&"boss_started")
    GlobalAudioManager.set_music_state("BOSS_PREPARE")
    boss.start_boss()
    var prep := boss_mechanics_success
    if level_id == &"L12":
        if prep == 0:
            show_toast.call("Boss 出现！你一个机关都没做，只能准备应急救援。")
        elif prep == 1:
            show_toast.call("Boss 出现！准备机关生效了一项，剩下靠临场救场。")
        else:
            show_toast.call("Boss 出现！两项战前准备生效，Phase 2 处理蒺藜即可终结。")
    else:
        show_toast.call("Boss 出现！战场还没有结束。")
    event_log.append_event({"event_id": &"BOSS_START", "action": &"START", "success": true, "prep_mechanics": prep, "prepared_damage": 100 - boss.hp})

func on_phase(phase: int) -> void:
    GlobalAudioManager.play_event_sfx("boss_phase")
    if feedback_director != null:
        feedback_director.show_boss_phase(phase)
    world_state.set_flag(&"boss_phase_%d" % phase)
    if phase >= 1 and phase <= 3:
        GlobalAudioManager.set_music_state("BOSS_PHASE_%d" % phase)
    if phase == 2:
        show_toast.call("Boss 开始冲锋！现在处理蒺藜。")
    elif phase == 3:
        if boss_mechanics_success == 0:
            emergency_available = true
            show_toast.call("危险！赶去应急门救场。Boss 进入最后追击。")
            event_log.append_event({"event_id": &"BOSS_EMERGENCY_WINDOW", "action": &"OPEN", "success": true, "phase": 3})

func on_defeated() -> void:
    boss_started = false
    GlobalAudioManager.play_event_sfx("victory")
    GlobalAudioManager.set_music_state("BOSS_DEFEAT")
    complete_level.call(false)

func on_retreat() -> void:
    boss_started = false
    if emergency_used:
        event_log.append_event({"event_id": &"BOSS_RETREAT_EMERGENCY", "action": &"EMERGENCY", "success": true, "mechanics": boss_mechanics_success})
        complete_level.call(true)
        return
    # GDD: 1–2 mechanics = Ninja survives the Boss but loses 2 hearts in the final struggle.
    if boss_mechanics_success < 3 and ninja != null:
        var before := ninja.hp
        ninja.take_damage(2)
        event_log.append_event({"event_id": &"BOSS_HARD_FIGHT", "action": &"RETREAT_DAMAGE", "success": ninja.hp > 0, "ninja_hp_before": before, "ninja_hp_after": ninja.hp, "mechanics": boss_mechanics_success})
        if is_level_failed.call():
            return
    complete_level.call(false)

func can_finish() -> bool:
    # 0 mechanics: only emergency rescue can close the fight.
    # 1–2 mechanics: Boss retreats after Phase 3 as a hard-fought clear.
    # 3 mechanics: Boss HP reaches 0 first and defeated signal closes the level.
    return boss_mechanics_success > 0 or emergency_used

func on_overrun() -> void:
    if is_level_failed.call() or is_level_finished.call() or l12_boss_overrun_logged:
        return
    if level_id != &"L12":
        return
    if emergency_used or boss_mechanics_success > 0:
        return
    l12_boss_overrun_logged = true
    emergency_available = false
    event_log.append_event({"event_id": &"BOSS_OVERRUN", "action": &"FAIL", "phase": &"FAILED", "success": false, "reason": &"NO_PREP_NO_EMERGENCY"})
    show_toast.call("来不及救场！守门武士把忍者打出场地。")
    notify_ninja_dead.call()

func try_emergency() -> void:
    if not emergency_available or emergency_used or boss == null:
        return
    if cat.global_position.distance_to(EMERGENCY_POS) <= 60.0 and Input.is_action_pressed("interact"):
        emergency_used = true
        emergency_available = false
        if ninja:
            ninja.hp = max(1, ninja.hp)
        boss.retreat.emit()
        event_log.append_event({"event_id": &"EMERGENCY_RESCUE", "action": &"EMERGENCY", "success": true, "ninja_hp_after": ninja.hp})
