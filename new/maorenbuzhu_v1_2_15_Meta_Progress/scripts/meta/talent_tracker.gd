class_name TalentTrackerClass
extends Node

const TALENT_RULES := {
    "EXTREME_CUT": {"counter": "extreme_cut", "threshold": 3},
    "DOG_ALLY": {"counter": "dog_ally", "threshold": 5},
    "CLEAN_PAWS": {"counter": "clean_paws", "threshold": 3},
    "CAT_STEP": {"counter": "cat_step", "threshold": 1},
    "PUPPET_MASTER": {"counter": "puppet_master", "threshold": 3},
    "LAST_SECOND": {"counter": "last_second", "threshold": 1},
}

func ingest_event(event: Dictionary, save: SaveData) -> Array[String]:
    var unlocked: Array[String] = []
    if event.get("event_type", "") == "TRIPWIRE" and float(event.get("late_success_window", 99.0)) <= 1.0:
        _inc(save, "extreme_cut")
    if event.get("event_type", "") == "DOG" and event.get("caused_event_type", "") == "GUARD":
        _inc(save, "dog_ally")
    if bool(event.get("level_clean", false)) and int(event.get("max_suspicion", 100)) < 20:
        _inc(save, "clean_paws")
    if bool(event.get("no_sprint", false)):
        _inc(save, "cat_step")
    if int(event.get("dependency_depth", 0)) >= 3:
        _inc(save, "puppet_master")
    if bool(event.get("emergency_rescue", false)):
        _inc(save, "last_second")
    for talent_id in TALENT_RULES.keys():
        var rule: Dictionary = TALENT_RULES[talent_id]
        if int(save.talent_counters.get(rule.counter, 0)) >= int(rule.threshold) and not save.unlocked_talents.has(talent_id):
            save.unlocked_talents.append(talent_id)
            unlocked.append(talent_id)
    return unlocked

func _inc(save: SaveData, counter: String) -> void:
    save.talent_counters[counter] = int(save.talent_counters.get(counter, 0)) + 1
