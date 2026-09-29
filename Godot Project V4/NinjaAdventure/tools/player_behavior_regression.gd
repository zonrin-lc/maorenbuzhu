extends Node

# 玩家行为级回归（GDD §15.3 债项：「CI 升级为玩法级回归」中「真实逐帧输入」部分）。
# 运行：godot --headless --fixed-fps 60 --path . tools/player_behavior_regression.tscn
#
# 与 gameplay_regression.gd 的分工：
#   gameplay_regression —— 走内部 API（EventNode.resolve / fail）验证「状态机 / 事件依赖 /
#                          Boss 阶段 / Retry」。快、稳，但绕过了输入层。
#   本脚本              —— 走真实输入层（Input.action_press 模拟键鼠/手柄），验证
#                          「玩家真的按键能不能推进玩法」：猫移动、真实碰撞、靠近事件、
#                          按住互动键完成 interaction_time、喵叫触发。慢一些，但抓的是
#                          状态机测试抓不到的接线回归。
#
# 每关检查两项：
#   MOVE   按住方向键，断言猫的 global_position 真的位移（验证输入→速度→move_and_slide 管线）
#   ACTION 对第一个「可用普通互动键完成」的活动事件：把猫挪到 58px 内并按住 interact，
#          断言事件经由 resolved 信号变为已解决（而非直接调 resolve()）
# 任一项不成立即该关 FAIL。

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

const MOVE_BUDGET_FRAMES := 40
const ACTION_BUDGET_FRAMES := 90
const INTERACT_REACH := 52.0

var _moves_ok := 0
var _actions_ok := 0

func _ready() -> void:
    _run_all.call_deferred()

func _run_all() -> void:
    var tree := get_tree()
    var wrapper := get_parent()
    if wrapper != null and wrapper == tree.current_scene:
        wrapper.remove_child(self)
        tree.root.add_child(self)
    for entry in LEVELS:
        await _run_level(String(entry[0]), String(entry[1]))
    print("PLAYER_BEHAVIOR: move=%d/%d action=%d/%d" % [
        _moves_ok, LEVELS.size(), _actions_ok, LEVELS.size()])
    var all_ok := _moves_ok == LEVELS.size() and _actions_ok == LEVELS.size()
    tree.quit(0 if all_ok else 1)

func _load_level(scene_path: String) -> UnifiedLevelManager:
    if get_tree().change_scene_to_file(scene_path) != OK:
        return null
    for i in 3:
        await get_tree().process_frame
    return get_tree().current_scene as UnifiedLevelManager

func _prepare(ulm: UnifiedLevelManager) -> void:
    if ulm.cat != null:
        ulm.cat.global_position = Vector2(70, 160)
        await get_tree().physics_frame
        await get_tree().physics_frame
    if ulm.reading_phase:
        ulm._end_reading_tour()
    await get_tree().process_frame

# CHECK 1：真实方向键 → 猫位移
func _check_move(ulm: UnifiedLevelManager) -> bool:
    if ulm.cat == null:
        return false
    var start := ulm.cat.global_position
    Input.action_press("move_right")
    for i in MOVE_BUDGET_FRAMES:
        await get_tree().physics_frame
    Input.action_release("move_right")
    var moved := ulm.cat.global_position.distance_to(start)
    return moved > 4.0

# 找一个能用「按住 interact」完成的活动事件（排除喵叫/卖萌教学/被动/需搬运的）
func _find_interact_event(ulm: UnifiedLevelManager) -> UnifiedEventPoint:
    for node in ulm.event_nodes:
        if node.resolved_state or not ulm.is_event_active(node.data):
            continue
        var required := EventBehaviorRegistry.action_for(node.data)
        if required == &"MEOW" or required == &"EMOTE_CHECK" or required == &"PASSIVE":
            continue
        if node.data.consume_carry_item != &"":
            continue
        return node
    return null

# CHECK 2：真实按住 interact → 事件经信号解决
func _check_action(ulm: UnifiedLevelManager) -> bool:
    var node := _find_interact_event(ulm)
    if node == null:
        # 该关没有「普通互动」类活动事件（例如全是喵叫/被动），不强求。
        return true
    if ulm.cat == null:
        return false
    var resolved := false
    node.resolved.connect(func(_d, _a): resolved = true)
    # 挪到事件 58px 判定圈内（留余量），并等物理同步
    ulm.cat.global_position = node.global_position + Vector2(0, -20)
    await get_tree().physics_frame
    await get_tree().physics_frame
    Input.action_press("interact")
    for i in ACTION_BUDGET_FRAMES:
        await get_tree().process_frame
        if resolved or node.resolved_state:
            break
    Input.action_release("interact")
    return resolved or node.resolved_state

func _run_level(lid: String, scene_path: String) -> void:
    var ulm := await _load_level(scene_path)
    if ulm == null:
        print("PLAYER_BEHAVIOR: %s FAIL load" % lid)
        return
    await _prepare(ulm)
    var move_ok := await _check_move(ulm)
    if move_ok:
        _moves_ok += 1
    var action_ok := await _check_action(ulm)
    if action_ok:
        _actions_ok += 1
    if move_ok and action_ok:
        print("PLAYER_BEHAVIOR: %s PASS" % lid)
    else:
        var why := []
        if not move_ok:
            why.append("move_no_displacement")
        if not action_ok:
            why.append("interact_no_resolve")
        print("PLAYER_BEHAVIOR: %s FAIL %s" % [lid, ",".join(why)])
