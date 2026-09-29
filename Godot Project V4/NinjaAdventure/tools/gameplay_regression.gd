extends Node

# 12 关玩法回归（GDD 核心循环：读图 -> 猫处理事件 -> 忍者推进 -> Goal -> 居酒屋结算 -> 重试）。
# 运行：godot --headless --fixed-fps 60 --path . tools/gameplay_regression.tscn
# 注意：必须用包装场景运行（不能直接 -s 本脚本——-s 的 SceneTree 主循环不注册
# autoload 全局标识符，GlobalAudioManager 等无法编译）。本脚本为纯新增测试代码。
#
# 每关两条路径：
#   PASS：跳过读图 -> 每帧解决所有 is_event_active 的未决事件（内部 API 直接 resolve）-> 断言结算
#   FAIL：重载后不处理事件，让忍者踩坑（首个阻挡事件等真实超时，随后快进 fail/resolve 到终态）->
#         断言 fail_code 非空 -> 模拟 R 键 retry -> 断言场景重载且 WorldState 清空
# L12 附加断言：三机关全触发（boss_mechanics_success == 3）、Boss 被击败、phase 序列含 2。
#
# 预算用真实时间而非帧数：L05/L07 的守卫换岗 8 秒用的是 Time.get_ticks_msec()（墙钟），
# 与 delta 驱动的系统（受 time_scale 加速）不同步，帧预算在 headless 高帧率下会等不到。

# 覆盖范围：12 关全部跑通 PASS 路径（读图跳过→全事件依 is_event_active 依赖序解决→Goal→结算）
# 与 FAIL 路径（首个阻挡事件真实超时失败→fail_code 断言→快进至终态→R 键 retry→WorldState 清空断言）；
# L12 附加锁定：三机关全触发、Boss defeated、phase 序列含 2（锁死"阶段跳级"回归）。
# 未覆盖：真实逐帧输入（直接调 resolve/fail 内部 API）、猫的移动与喵叫/卖萌操作、
# 居酒屋结算场景内容、结算后下一关跳转（level_completed 载荷断言后即切走）。

const LEVELS := [
    ["L01", "res://scenes/levels/ch01_village/L01_first_job.tscn"],
    ["L02", "res://scenes/levels/ch01_village/L02_same_old_trap.tscn"],
    ["L03", "res://scenes/levels/ch01_village/L03_who_is_watching.tscn"],
    ["L04", "res://scenes/levels/ch01_village/L04_village_accident.tscn"],
    ["L05", "res://scenes/levels/ch02_dock/L05_moonlit_dock.tscn"],
    ["L06", "res://scenes/levels/ch02_dock/L06_dog_ally.tscn"],
    ["L07", "res://scenes/levels/ch02_dock/L07_who_goes_first.tscn"],
    ["L08", "res://scenes/levels/ch02_dock/L08_last_boat.tscn"],
    ["L09", "res://scenes/levels/ch03_castle/L09_storm_night.tscn"],
    ["L10", "res://scenes/levels/ch03_castle/L10_dont_touch_dynamite.tscn"],
    ["L11", "res://scenes/levels/ch03_castle/L11_busy_gate.tscn"],
    ["L12", "res://scenes/levels/ch03_castle/L12_gatekeeper_boss.tscn"],
]

const PASS_BUDGET_MSEC := 30000
const FAIL_BUDGET_MSEC := 45000
const RELOAD_BUDGET_MSEC := 5000
const ORGANIC_FAIL_WAIT_MSEC := 3000 # 首个阻挡事件等待真实超时的墙钟预算（最长 timeout 4s，加速后 <1s 即触发）
const CAT_PARK_POS := Vector2(70, 160) # 猫停泊点：多名关卡猫与忍者同点出生，不移开会物理卡住忍者

var _pass_done := false
var _pass_payload := {}
var _fail_code: StringName = &""
var _boss_phases: Array[int] = []
var _boss_defeated := false

func _ready() -> void:
    _run_all.call_deferred()

func _on_pass_completed(payload: Dictionary) -> void:
    _pass_done = true
    _pass_payload = payload

func _on_event_failed_captured(code: StringName) -> void:
    if _fail_code == &"":
        _fail_code = code

func _on_boss_phase_changed(phase: int) -> void:
    _boss_phases.append(phase)

func _on_boss_defeated() -> void:
    _boss_defeated = true

func _run_all() -> void:
    # 脱离包装场景：change_scene_to_file 会 free 当前场景，把自身 reparent 到 root 以存活，
    # 且让关卡成为 current_scene（ULM 的 R 键 retry 走 reload_current_scene，依赖这一点）。
    # 场景实例化期间父节点忙碌，reparent 必须推迟到此处（_ready 里做会被引擎拒绝）。
    var tree := get_tree()
    var wrapper := get_parent()
    if wrapper != null and wrapper == tree.current_scene:
        wrapper.remove_child(self)
        tree.root.add_child(self)
    var passed := 0
    for entry in LEVELS:
        var ok := await _run_level(entry[0], entry[1])
        if ok:
            passed += 1
    print("REGRESSION: %d/12" % passed)
    tree.quit(0 if passed == LEVELS.size() else 1)

func _load_level(scene_path: String) -> UnifiedLevelManager:
    var err := get_tree().change_scene_to_file(scene_path)
    if err != OK:
        return null
    await get_tree().process_frame
    await get_tree().process_frame
    await get_tree().process_frame
    return get_tree().current_scene as UnifiedLevelManager

func _prepare_run(ulm: UnifiedLevelManager) -> void:
    # 模拟玩家把猫带离出生点：多关猫与忍者同点出生，不挪开会把忍者物理卡死。
    # 必须先挪猫并等物理服务器同步（传送生效有一帧延迟），再结束读图解冻忍者，
    # 否则重叠 depenetration 会把忍者弹离路线（实测 L06 会被弹到墙角卡死）。
    if ulm.cat != null:
        ulm.cat.global_position = CAT_PARK_POS
        await get_tree().physics_frame
        await get_tree().physics_frame
    if ulm.reading_phase:
        ulm._end_reading_tour()
    # 忍者按距离步进（move_speed * delta），路点吸附半径 5px：每帧步长须 < 10px 防过冲振荡。
    var speed := 66.0
    if ulm.level_data != null and ulm.level_data.ninja_route != null:
        speed = ulm.level_data.ninja_route.move_speed
    Engine.time_scale = clampf(480.0 / maxf(speed, 1.0), 1.0, 12.0)

func _report(lid: String, ok: bool, reason: String) -> bool:
    if ok:
        print("LEVEL_REGRESSION: %s PASS" % lid)
    else:
        print("LEVEL_REGRESSION: %s FAIL %s" % [lid, reason])
    return ok

func _run_level(lid: String, scene_path: String) -> bool:
    var reasons: Array[String] = []
    await _run_pass(lid, scene_path, reasons)
    await _run_fail(lid, scene_path, reasons)
    return _report(lid, reasons.is_empty(), "; ".join(reasons))

func _run_pass(lid: String, scene_path: String, reasons: Array[String]) -> void:
    var ulm := await _load_level(scene_path)
    if ulm == null:
        reasons.append("pass: scene load failed")
        return
    _pass_done = false
    _pass_payload = {}
    _boss_phases.clear()
    _boss_defeated = false
    ulm.level_completed.connect(_on_pass_completed)
    if lid == "L12" and ulm.boss != null:
        ulm.boss.phase_changed.connect(_on_boss_phase_changed)
        ulm.boss.defeated.connect(_on_boss_defeated)
    await _prepare_run(ulm)
    var deadline := Time.get_ticks_msec() + PASS_BUDGET_MSEC
    while not _pass_done and Time.get_ticks_msec() < deadline:
        for node in ulm.event_nodes:
            if not node.resolved_state and ulm.is_event_active(node.data):
                node.resolve(EventBehaviorRegistry.action_for(node.data))
        await get_tree().process_frame
    Engine.time_scale = 1.0
    if not _pass_done:
        reasons.append("pass: no completion within %ds | %s" % [PASS_BUDGET_MSEC / 1000, _debug_state(ulm)])
        return
    if not bool(_pass_payload.get("mission_complete", false)):
        reasons.append("pass: mission_complete not true")
    if ulm.level_failed:
        reasons.append("pass: level_failed set")
    if ulm.event_log.entries.is_empty():
        reasons.append("pass: event_log empty")
    if lid == "L12":
        if not _boss_defeated:
            reasons.append("L12: boss not defeated")
        if not _boss_phases.has(2):
            reasons.append("L12: phase sequence %s missing 2" % str(_boss_phases))
        if ulm.boss_director == null or ulm.boss_director.boss_mechanics_success != 3:
            reasons.append("L12: boss_mechanics_success != 3")

# 首次失败后的快进：踩到的阻挡坑直接 fail，非阻挡 MAIN 直接 resolve，以抵达终态（通关或忍者倒下）。
func _finish_fast(ulm: UnifiedLevelManager) -> void:
    var ninja := ulm.ninja
    for node in ulm.event_nodes:
        if node.resolved_state or node.data.event_group != &"MAIN":
            continue
        if node.data.non_blocking:
            if ulm.is_event_active(node.data):
                node.resolve(EventBehaviorRegistry.action_for(node.data))
        elif ninja != null and ninja.waypoint_index >= node.data.route_index:
            node.fail(node.data.fail_code)

func _force_fail_blocking(ulm: UnifiedLevelManager) -> void:
    var ninja := ulm.ninja
    if ninja == null or not ninja.waiting_for_event:
        return
    for node in ulm.event_nodes:
        if node.resolved_state or node.data.non_blocking or node.data.event_group != &"MAIN":
            continue
        if ninja.waypoint_index >= node.data.route_index:
            node.fail(node.data.fail_code)
            return

func _run_fail(lid: String, scene_path: String, reasons: Array[String]) -> void:
    var ulm := await _load_level(scene_path)
    if ulm == null:
        reasons.append("fail: scene reload failed")
        return
    _fail_code = &""
    ulm.event_failed.connect(_on_event_failed_captured)
    await _prepare_run(ulm)
    var deadline := Time.get_ticks_msec() + FAIL_BUDGET_MSEC
    var wait_start_msec := 0
    while not (ulm.level_failed or ulm.level_finished) and Time.get_ticks_msec() < deadline:
        if _fail_code == &"":
            # 首个阻挡事件等待真实超时（验证 timeout 管线）；疑似 timeout=0 死等时强推。
            var ninja := ulm.ninja
            if ninja != null and ninja.waiting_for_event:
                if wait_start_msec == 0:
                    wait_start_msec = Time.get_ticks_msec()
                elif Time.get_ticks_msec() - wait_start_msec > ORGANIC_FAIL_WAIT_MSEC:
                    _force_fail_blocking(ulm)
            else:
                wait_start_msec = 0
        else:
            _finish_fast(ulm)
        await get_tree().process_frame
    Engine.time_scale = 1.0
    if _fail_code == &"":
        reasons.append("fail: no fail_code observed")
    if not (ulm.level_failed or ulm.level_finished):
        reasons.append("fail: no terminal state within %ds | %s" % [FAIL_BUDGET_MSEC / 1000, _debug_state(ulm)])
        return
    # R 键 retry：ULM._process 在 level_finished/level_failed 时 reload_current_scene。
    Input.action_press("retry")
    var old_ulm := ulm
    var reloaded := false
    var retry_deadline := Time.get_ticks_msec() + RELOAD_BUDGET_MSEC
    while Time.get_ticks_msec() < retry_deadline:
        await get_tree().process_frame
        var cur := get_tree().current_scene
        if cur != old_ulm and cur is UnifiedLevelManager:
            reloaded = true
            break
    Input.action_release("retry")
    if not reloaded:
        reasons.append("fail: retry did not reload scene")
        return
    var fresh := get_tree().current_scene as UnifiedLevelManager
    if not fresh.world_state.flags.is_empty():
        reasons.append("fail: world_state not reset after retry")

# 超时时的现场快照：忍者位置/等待状态 + 未决事件及其激活状态 + 世界旗标。
func _debug_state(ulm: UnifiedLevelManager) -> String:
    var parts: Array[String] = []
    if ulm.ninja != null:
        parts.append("ninja_wp=%d waiting=%s pos=%s" % [ulm.ninja.waypoint_index, ulm.ninja.waiting_for_event, str(ulm.ninja.position)])
    var pending: Array[String] = []
    for node in ulm.event_nodes:
        if not node.resolved_state:
            pending.append("%s(active=%s)" % [node.data.event_id, ulm.is_event_active(node.data)])
    parts.append("pending=[%s]" % ", ".join(pending))
    parts.append("flags=%s" % str(ulm.world_state.flags))
    return " | ".join(parts)
