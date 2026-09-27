class_name SaveData
extends Resource

@export var schema_version: int = 1
@export var selected_skin: String = "BLACK"
@export var selected_difficulty: String = "NORMAL"
@export var completed_levels: Array[String] = []
@export var best_paws: Dictionary = {}
@export var best_time_ms: Dictionary = {}
@export var best_max_suspicion: Dictionary = {}
@export var fish_collected: Dictionary = {}
@export var unlocked_skins: Array[String] = ["BLACK"]
@export var unlocked_talents: Array[String] = []
@export var talent_counters: Dictionary = {}
@export var tutorial_seen: Array[String] = []
@export var hard_mode_unlocked: bool = false
@export var hard_plus_unlocked: bool = false
@export var last_level_id: String = "L01"

func to_dict() -> Dictionary:
    return {
        "schema_version": schema_version,
        "selected_skin": selected_skin,
        "selected_difficulty": selected_difficulty,
        "completed_levels": completed_levels,
        "best_paws": best_paws,
        "best_time_ms": best_time_ms,
        "best_max_suspicion": best_max_suspicion,
        "fish_collected": fish_collected,
        "unlocked_skins": unlocked_skins,
        "unlocked_talents": unlocked_talents,
        "talent_counters": talent_counters,
        "tutorial_seen": tutorial_seen,
        "hard_mode_unlocked": hard_mode_unlocked,
        "hard_plus_unlocked": hard_plus_unlocked,
        "last_level_id": last_level_id,
    }

static func from_dict(raw: Dictionary) -> SaveData:
    var d := SaveData.new()
    d.schema_version = int(raw.get("schema_version", 1))
    d.selected_skin = str(raw.get("selected_skin", "BLACK"))
    d.selected_difficulty = str(raw.get("selected_difficulty", "NORMAL"))
    d.completed_levels = Array(raw.get("completed_levels", []))
    d.best_paws = Dictionary(raw.get("best_paws", {}))
    d.best_time_ms = Dictionary(raw.get("best_time_ms", {}))
    d.best_max_suspicion = Dictionary(raw.get("best_max_suspicion", {}))
    d.fish_collected = Dictionary(raw.get("fish_collected", {}))
    d.unlocked_skins = Array(raw.get("unlocked_skins", ["BLACK"]))
    d.unlocked_talents = Array(raw.get("unlocked_talents", []))
    d.talent_counters = Dictionary(raw.get("talent_counters", {}))
    d.tutorial_seen = Array(raw.get("tutorial_seen", []))
    d.hard_mode_unlocked = bool(raw.get("hard_mode_unlocked", false))
    d.hard_plus_unlocked = bool(raw.get("hard_plus_unlocked", false))
    d.last_level_id = str(raw.get("last_level_id", "L01"))
    return d
