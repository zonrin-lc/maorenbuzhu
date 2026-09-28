class_name AppFlow
extends Node

const MAIN_MENU := "res://scenes/flow/main_menu.tscn"
const CHAPTER_SELECT := "res://scenes/flow/chapter_select.tscn"
const LEVEL_SELECT := "res://scenes/flow/level_select.tscn"
const RESULT := "res://scenes/settlement/izakaya_settlement.tscn"

var level_catalog: LevelCatalog = LevelCatalog.new()
var save_manager: SaveManagerClass
var progress_manager: ProgressManagerClass
var settings_manager
var result_flow: ResultFlow

func _ready() -> void:
    save_manager = get_node("/root/SaveManager") as SaveManagerClass
    progress_manager = ProgressManagerClass.new()
    add_child(progress_manager)
    result_flow = ResultFlow.new()
    add_child(result_flow)

func save_data() -> SaveData:
    return save_manager.get_data()

func continue_level() -> String:
    var save := save_data()
    if save.last_level_id.is_empty():
        return "L01"
    if save.completed_levels.has(save.last_level_id):
        var next := _next_level(save.last_level_id)
        return next if not next.is_empty() else save.last_level_id
    return save.last_level_id

func _next_level(level_id: String) -> String:
    var i := level_catalog.level_ids.find(level_id)
    if i < 0 or i + 1 >= level_catalog.level_ids.size():
        return ""
    return level_catalog.level_ids[i + 1]

func can_start(level_id: String) -> bool:
    return progress_manager.is_level_unlocked(level_id, save_data())

func chapter_unlocked(chapter: int) -> bool:
    return progress_manager.chapter_unlocked(chapter, save_data())

func next_level(level_id: String) -> String:
    return _next_level(level_id)

func complete_level(level_id: String, paws: int, time_ms: int, max_suspicion: int, difficulty: String = "NORMAL") -> void:
    save_manager.mark_level_complete(level_id, paws, time_ms, max_suspicion, difficulty)

func go_to_level(level_id: String) -> void:
    if not can_start(level_id):
        return
    get_tree().change_scene_to_file(level_catalog.scene_path(level_id))
