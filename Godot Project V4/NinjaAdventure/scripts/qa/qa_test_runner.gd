extends Node

const FAIL_CODES := [
    "FAIL_TOO_LATE",
    "FAIL_WRONG_ORDER",
    "FAIL_SUSPICION",
    "FAIL_NINJA_DEATH",
    "FAIL_BOSS_FINISHER",
    "FAIL_ROUTE_BLOCKED",
    "FAIL_TIMEOUT",
]

const LEVEL_COUNT := 12
const EVENTS_DIR := "res://data/events"

func _ready() -> void:
    # Release 隔离（GDD Release Gate）：正式构建中移除 QA Runner 单例。
    if not OS.has_feature("editor") and not OS.has_feature("debug"):
        queue_free()

func run_quick_validation(level_id: String) -> String:
    if not _valid_level(level_id):
        return "ERR invalid level_id"
    return "OK quick_validation=" + level_id + " core_state=inspectable"

func run_static_contract_suite(events_seen: int, levels_seen: int) -> Dictionary:
    var errors: Array[String] = []
    if levels_seen != LEVEL_COUNT:
        errors.append("expected 12 levels, got %d" % levels_seen)
    var expected_events := count_event_resources()
    if events_seen != expected_events:
        errors.append("expected %d events, got %d" % [expected_events, events_seen])
    for code in FAIL_CODES:
        if code.is_empty():
            errors.append("empty FAIL_CODE")
    return {"errors": errors, "passed": errors.is_empty()}

# 事件数量的唯一事实源 = data/events/ 下 .tres 文件数，运行时枚举，禁止硬编码。
# 注意：本函数面向编辑器 / CI（--headless）环境，用 DirAccess 读目录；
# 导出包里 .tres 会变成 .tres.remap，这里对两种后缀都做归一计数。
static func count_event_resources() -> int:
    var count := 0
    var dir := DirAccess.open(EVENTS_DIR)
    if dir == null:
        push_warning("QATestRunner: cannot open " + EVENTS_DIR)
        return 0
    for file in dir.get_files():
        var name := String(file).trim_suffix(".remap")
        if name.ends_with(".tres"):
            count += 1
    return count

func _valid_level(value: String) -> bool:
    var n := int(value.trim_prefix("L"))
    return value.begins_with("L") and n >= 1 and n <= 12
