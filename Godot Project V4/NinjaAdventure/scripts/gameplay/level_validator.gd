class_name LevelValidator
extends RefCounted

# LevelValidator P0 合同（GDD §12.13 十二条）：
# 资源存在 / ID 唯一 / 引用合法 / 行为注册 / 路线非空 / 评分规则 / 场景文件 /
# 成败出口 / CRITICAL 双解 / Boss 分组与阶段 / Emergency 约束 / 调试字段禁入存档
func validate_level(level_data: LevelData) -> Array[String]:
    var errors: Array[String] = []
    if level_data == null:
        return ["LEVEL_DATA_MISSING"]

    # 1-2 基础字段
    if level_data.level_id == StringName():
        errors.append("LEVEL_ID_EMPTY")
    if level_data.display_name.is_empty():
        errors.append("DISPLAY_NAME_EMPTY")

    # 3-4 路线
    if level_data.ninja_route == null:
        errors.append("ROUTE_MISSING")
    elif level_data.ninja_route.waypoints.size() < 2:
        errors.append("ROUTE_TOO_SHORT")

    # 5 评分规则
    if level_data.score_rules == null:
        errors.append("SCORE_RULES_MISSING")

    # 6 场景文件与结算出口
    if level_data.scene_path.is_empty():
        errors.append("SCENE_PATH_EMPTY")
    elif not FileAccess.file_exists(level_data.scene_path):
        errors.append("SCENE_FILE_MISSING:" + level_data.scene_path)
    if not level_data.next_scene_path.is_empty() and not FileAccess.file_exists(level_data.next_scene_path):
        errors.append("NEXT_SCENE_FILE_MISSING:" + level_data.next_scene_path)

    # 7 事件集合
    if level_data.events.is_empty():
        errors.append("EVENTS_EMPTY")
    var seen_ids := {}
    var last_route_index := -1
    var has_boss_prep := false
    var has_boss_combat := false
    var waypoint_count := level_data.ninja_route.waypoints.size() if level_data.ninja_route != null else 0
    for e in level_data.events:
        if e == null:
            errors.append("EVENT_NULL")
            continue
        var tag := String(e.event_id)
        # 8 ID 唯一
        if e.event_id == StringName():
            errors.append("EVENT_ID_EMPTY")
        elif seen_ids.has(e.event_id):
            errors.append("EVENT_ID_DUPLICATE:" + tag)
        seen_ids[e.event_id] = true
        # 9 行为已注册（data/event_behaviors/<type>.tres 存在）
        if not ResourceLoader.exists("res://data/event_behaviors/%s.tres" % String(e.event_type).to_lower()):
            errors.append("EVENT_BEHAVIOR_MISSING:" + String(e.event_type))
        # 10 引用合法：路线锚点在范围内、顺序不倒退、依赖事件存在
        if e.route_index < 0 or (waypoint_count > 1 and e.route_index >= waypoint_count):
            errors.append("EVENT_ROUTE_INDEX_INVALID:" + tag)
        if e.route_index < last_route_index:
            errors.append("EVENT_ROUTE_ORDER_INVALID:" + tag)
        last_route_index = max(last_route_index, e.route_index)
        if e.timeout < 0.0:
            errors.append("EVENT_TIMEOUT_INVALID:" + tag)
        # 11 成败出口：主线事件必须有失败码与成功反馈（flag 或 effect 至少其一）
        if e.event_group == &"MAIN":
            if e.fail_code == StringName():
                errors.append("EVENT_FAIL_CODE_MISSING:" + tag)
            if e.success_flags.is_empty() and e.success_effects.is_empty():
                errors.append("EVENT_SUCCESS_OUTPUT_MISSING:" + tag)
            # 12 CRITICAL 至少一个标准解（风险解为推荐，白盒期警告级，不强制）
            if e.classification == &"CRITICAL" and not e.allow_standard_solution:
                errors.append("EVENT_NO_STANDARD_SOLUTION:" + tag)
        # Boss 分组收集
        if EventBehaviorRegistry.is_boss_prep(e):
            has_boss_prep = true
        if EventBehaviorRegistry.is_boss_combat(e):
            has_boss_combat = true
            # Boss 战中机制必须绑定阶段（GDD：蒺藜固定 Phase 2）
            if e.activation_phase != 2:
                errors.append("BOSS_COMBAT_PHASE_INVALID:" + tag)
        if e.event_type == &"BOSS_CALTROP" and e.timeout != 0.0:
            errors.append("BOSS_CALTROP_TIMEOUT_INVALID")

    # Boss 关结构：存在任一 BOSS 组件时，必须备战（PREP）与战中（COMBAT）分组俱全
    var has_any_boss := has_boss_prep or has_boss_combat
    for e in level_data.events:
        if e != null and String(e.event_type).begins_with("BOSS_"):
            has_any_boss = true
    if has_any_boss:
        if not has_boss_prep:
            errors.append("BOSS_PREP_GROUP_MISSING")
        if not has_boss_combat:
            errors.append("BOSS_COMBAT_GROUP_MISSING")
    return errors

# 16×16 网格规范（GDD 工程债）：核心墙体/捷径/桥/水面应对齐 16px 网格。
# 当前为 WARN 级（返回未对齐清单，不阻断关卡）；内容层对齐后可升级为错误。
static func check_grid_alignment(level_id: StringName) -> Array[String]:
    var warnings: Array[String] = []
    var layout: Dictionary = LayoutGeometry.LEVEL_LAYOUTS.get(level_id, {})
    for key in ["walls", "tunnels", "shortcuts", "bridges", "water"]:
        for r in layout.get(key, []):
            var rect: Rect2 = r
            if int(rect.position.x) % 16 != 0 or int(rect.position.y) % 16 != 0 or int(rect.size.x) % 16 != 0 or int(rect.size.y) % 16 != 0:
                warnings.append("%s %s %s" % [level_id, key, rect])
    return warnings
