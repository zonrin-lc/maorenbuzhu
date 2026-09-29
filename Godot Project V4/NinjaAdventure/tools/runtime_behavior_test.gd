extends Node

# 运行时行为验证：改键按设备分离 / 跨启动持久化 / 恢复出厂 / 鱼收藏写档。
# 这些无法被静态审计或 headless 玩法回归覆盖（它们改的是 InputMap 与 SaveData），
# 故用真实引擎跑一遍。运行：
#   godot --headless --path . res://tools/runtime_behavior_test.tscn
#
# 通过 = 打印 RUNTIME: PASS；否则打印具体失败项并以非 0 退出。

const USER_CFG := "user://settings.cfg"

var _errors: Array[String] = []

func _ready() -> void:
    _run.call_deferred()

func _run() -> void:
    _test_device_scoped_rebind()
    _test_persistence_roundtrip()
    _test_restore_factory()
    _test_fish_collect_writes_save()
    if _errors.is_empty():
        print("RUNTIME: PASS")
        get_tree().quit(0)
    else:
        print("RUNTIME: FAIL (%d)" % _errors.size())
        for e in _errors:
            print("  " + e)
        get_tree().quit(1)

func _count_device(action: String, cls: StringName) -> int:
    var n := 0
    for ev in InputMap.action_get_events(action):
        if RebindManager.device_class_of(ev) == cls:
            n += 1
    return n

# 1) 改键鼠不得影响手柄绑定
func _test_device_scoped_rebind() -> void:
    var pad_before := _count_device("interact", RebindManager.DEVICE_PAD)
    var kbm_before := _count_device("interact", RebindManager.DEVICE_KBM)
    if pad_before == 0:
        _errors.append("setup: interact 原本就没有手柄绑定，无法验证设备隔离")
        return
    var mgr := RebindManager.new()
    add_child(mgr)
    var ev := InputEventKey.new()
    ev.physical_keycode = KEY_G
    var ok := mgr.apply_binding("interact", ev)
    if not ok:
        _errors.append("rebind: apply_binding(interact, G) 被拒")
    else:
        var pad_after := _count_device("interact", RebindManager.DEVICE_PAD)
        if pad_after != pad_before:
            _errors.append("rebind: 改键鼠后手柄绑定数变化 %d -> %d（应保持）" % [pad_before, pad_after])
        if _count_device("interact", RebindManager.DEVICE_KBM) != 1:
            _errors.append("rebind: 键鼠绑定数应为 1")
        var has_g := false
        for e2 in InputMap.action_get_events("interact"):
            if e2 is InputEventKey and (e2.physical_keycode if e2.physical_keycode != 0 else e2.keycode) == KEY_G:
                has_g = true
        if not has_g:
            _errors.append("rebind: 新键 G 未生效")
    mgr.queue_free()
    # 还原，避免影响后续用例
    RebindManager.restore_factory_defaults()

# 2) 持久化往返：改键 -> 存 -> 重新套用 -> 应还原
func _test_persistence_roundtrip() -> void:
    var mgr := RebindManager.new()
    add_child(mgr)
    var ev := InputEventKey.new()
    ev.physical_keycode = KEY_H
    if not mgr.apply_binding("interact", ev):
        _errors.append("persist: 改键失败")
        mgr.queue_free()
        return
    var payload := RebindManager._current_payload("interact")
    var stored: Array = payload.get(RebindManager.DEVICE_KBM, [])
    if stored.is_empty():
        _errors.append("persist: 键鼠 payload 为空")
    # 模拟重启：清空 InputMap 后从 payload 还原
    InputMap.action_erase_events("interact")
    RebindManager._apply_stored("interact", payload)
    var has_h := false
    for e2 in InputMap.action_get_events("interact"):
        if e2 is InputEventKey and (e2.physical_keycode if e2.physical_keycode != 0 else e2.keycode) == KEY_H:
            has_h = true
    if not has_h:
        _errors.append("persist: 从 payload 还原后 H 丢失")
    if _count_device("interact", RebindManager.DEVICE_PAD) == 0:
        _errors.append("persist: 还原后手柄绑定丢失（应无损保留）")
    mgr.queue_free()
    RebindManager.restore_factory_defaults()

# 3) 恢复出厂必须回到 project.godot 默认并清掉持久化
func _test_restore_factory() -> void:
    var ev := InputEventKey.new()
    ev.physical_keycode = KEY_J
    var mgr := RebindManager.new()
    add_child(mgr)
    mgr.apply_binding("interact", ev)
    mgr.queue_free()
    RebindManager.restore_factory_defaults()
    var has_j := false
    for e2 in InputMap.action_get_events("interact"):
        if e2 is InputEventKey and (e2.physical_keycode if e2.physical_keycode != 0 else e2.keycode) == KEY_J:
            has_j = true
    if has_j:
        _errors.append("restore: 恢复出厂后 J 仍在（应回到默认 E）")
    if _count_device("interact", RebindManager.DEVICE_PAD) == 0:
        _errors.append("restore: 恢复出厂后手柄绑定丢失")
    var cfg := ConfigFile.new()
    if cfg.load(USER_CFG) == OK and cfg.has_section("input") and cfg.has_section_key("input", "interact"):
        _errors.append("restore: 持久化覆盖未被清除")

# 4) 鱼收藏写入 bitmask 且去重
func _test_fish_collect_writes_save() -> void:
    # 必须用真实关卡 ID：ProgressManager.fish_total() 只统计 LEVEL_ORDER 里的关卡，
    # 用假 ID 会导致总数恒为 0（这是测试自身的坑，不是游戏缺陷）。
    var level_id := ProgressManagerClass.LEVEL_ORDER[0]
    var save := SaveManager.get_data()
    var had_prior := int(save.fish_collected.get(level_id, 0))
    save.fish_collected.erase(level_id)
    SaveManager.collect_fish(level_id, 0)
    SaveManager.collect_fish(level_id, 2)
    SaveManager.collect_fish(level_id, 0)  # 重复应幂等
    var mask := int(SaveManager.get_data().fish_collected.get(level_id, 0))
    if mask != 0b101:
        _errors.append("fish: bitmask 期望 0b101（索引0与2），实际 %d" % mask)
    var pm := ProgressManagerClass.new()
    if pm.fish_total(SaveManager.get_data()) < 2:
        _errors.append("fish: fish_total 未累计")
    pm.free()
    # 还原测试前的存档状态，不污染真实进度
    SaveManager.get_data().fish_collected.erase(level_id)
    if had_prior != 0:
        SaveManager.get_data().fish_collected[level_id] = had_prior
    SaveManager.save_game()
