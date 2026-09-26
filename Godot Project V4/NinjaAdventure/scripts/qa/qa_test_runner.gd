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
const EXPECTED_EVENT_COUNT := 46

func run_quick_validation(level_id: String) -> String:
    if not _valid_level(level_id):
        return "ERR invalid level_id"
    return "OK quick_validation=" + level_id + " core_state=inspectable"

func run_static_contract_suite(events_seen: int, levels_seen: int) -> Dictionary:
    var errors: Array[String] = []
    if levels_seen != LEVEL_COUNT:
        errors.append("expected 12 levels, got %d" % levels_seen)
    if events_seen != EXPECTED_EVENT_COUNT:
        errors.append("expected 46 events, got %d" % events_seen)
    for code in FAIL_CODES:
        if code.is_empty():
            errors.append("empty FAIL_CODE")
    return {"errors": errors, "passed": errors.is_empty()}

func _valid_level(value: String) -> bool:
    var n := int(value.trim_prefix("L"))
    return value.begins_with("L") and n >= 1 and n <= 12
