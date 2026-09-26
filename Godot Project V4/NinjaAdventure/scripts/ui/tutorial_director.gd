class_name TutorialDirector
extends Node

@export var save_section: String = "tutorials"
var seen: Dictionary = {}

func show_once(data: Resource) -> bool:
    if data == null:
        return false
    var tutorial_id: String = str(data.get("tutorial_id"))
    if tutorial_id.is_empty() or seen.get(tutorial_id, false):
        return false
    seen[tutorial_id] = true
    # 这里只负责生命周期；具体展示由 TutorialToast 负责。
    return true

func reset_session() -> void:
    seen.clear()
