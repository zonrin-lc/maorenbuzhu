class_name BalanceDirector
extends RefCounted

## 首轮平衡体验层：不改变通关规则，只把三星时间线性映射成清晰的节奏提示。
## 0.00-0.69：舒适；0.70-0.89：冲刺；0.90-0.99：临界；>=1.00：已超三星线。

var target_time: float = 60.0
var level_id: StringName = &""
var last_phase: StringName = &""
var warning_fired := {&"RUSH": false, &"CRITICAL": false, &"OVERTIME": false}

func setup(level_data: LevelData) -> void:
    if level_data == null:
        return
    level_id = level_data.level_id
    target_time = maxf(1.0, level_data.score_rules.target_time if level_data.score_rules != null else level_data.target_time)
    last_phase = &"COMFORT"
    warning_fired = {&"RUSH": false, &"CRITICAL": false, &"OVERTIME": false}

func phase_for(elapsed: float) -> StringName:
    var ratio := elapsed / target_time
    if ratio < 0.70:
        return &"COMFORT"
    if ratio < 0.90:
        return &"RUSH"
    if ratio < 1.00:
        return &"CRITICAL"
    return &"OVERTIME"

func status_text(elapsed: float) -> String:
    match phase_for(elapsed):
        &"COMFORT": return "节奏舒适"
        &"RUSH": return "三星冲刺"
        &"CRITICAL": return "三星临界"
        _: return "已超过三星线"

func next_warning(elapsed: float) -> String:
    var phase := phase_for(elapsed)
    if phase == &"RUSH" and not warning_fired[&"RUSH"]:
        warning_fired[&"RUSH"] = true
        last_phase = phase
        return "接近三星时间线，开始赶场。"
    if phase == &"CRITICAL" and not warning_fired[&"CRITICAL"]:
        warning_fired[&"CRITICAL"] = true
        last_phase = phase
        return "三星时间线只剩一点窗口。"
    if phase == &"OVERTIME" and not warning_fired[&"OVERTIME"]:
        warning_fired[&"OVERTIME"] = true
        last_phase = phase
        return "已经超过三星时间线，继续完成任务即可。"
    return ""
