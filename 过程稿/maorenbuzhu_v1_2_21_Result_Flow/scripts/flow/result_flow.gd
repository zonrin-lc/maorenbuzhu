class_name ResultFlow
extends Node

const RESULT_SCENE := "res://scenes/flow/result.tscn"
const MAIN_MENU := "res://scenes/flow/main_menu.tscn"
const CHAPTER_SELECT := "res://scenes/flow/chapter_select.tscn"
const LEVEL_SELECT := "res://scenes/flow/level_select.tscn"

var pending_result: Dictionary = {}

func set_result(level_id: String, paws: int, time_ms: int, max_suspicion: int, difficulty: String = "NORMAL", fail_code: String = "") -> void:
    pending_result = {
        "level_id": level_id,
        "paws": paws,
        "time_ms": time_ms,
        "max_suspicion": max_suspicion,
        "difficulty": difficulty,
        "fail_code": fail_code,
    }

func has_result() -> bool:
    return not pending_result.is_empty()

func consume_result() -> Dictionary:
    var out := pending_result.duplicate(true)
    pending_result.clear()
    return out

func next_level_id(app: AppFlow) -> String:
    if pending_result.is_empty():
        return ""
    return app.next_level(str(pending_result.get("level_id", "")))

func can_go_next(app: AppFlow) -> bool:
    var next := next_level_id(app)
    return not next.is_empty() and app.can_start(next)

func finish_level(app: AppFlow, level_id: String, paws: int, time_ms: int, max_suspicion: int, difficulty: String = "NORMAL", fail_code: String = "") -> void:
    app.complete_level(level_id, paws, time_ms, max_suspicion, difficulty)
    set_result(level_id, paws, time_ms, max_suspicion, difficulty, fail_code)
    get_tree().change_scene_to_file(RESULT_SCENE)

func retry(app: AppFlow) -> void:
    var level_id := str(pending_result.get("level_id", ""))
    pending_result.clear()
    if not level_id.is_empty():
        app.go_to_level(level_id)

func go_next(app: AppFlow) -> void:
    var next := next_level_id(app)
    pending_result.clear()
    if not next.is_empty() and app.can_start(next):
        app.go_to_level(next)
    elif not next.is_empty():
        GlobalFlowMemory.selected_chapter = app.level_catalog.chapter_for_level(next)
        get_tree().change_scene_to_file(LEVEL_SELECT)
    else:
        GlobalFlowMemory.selected_chapter = 3
        get_tree().change_scene_to_file(CHAPTER_SELECT)
