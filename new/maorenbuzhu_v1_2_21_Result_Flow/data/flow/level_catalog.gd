class_name LevelCatalog
extends Resource

@export var level_ids: Array[String] = [
    "L01","L02","L03","L04","L05","L06","L07","L08","L09","L10","L11","L12"
]

@export var level_names: Dictionary = {
    "L01":"第一份差事", "L02":"他总是踩同一个坑", "L03":"谁在看猫", "L04":"村口大事故",
    "L05":"月夜码头", "L06":"狗也能当队友", "L07":"谁先走", "L08":"最后一班船",
    "L09":"雷雨夜", "L10":"炸药不能乱碰", "L11":"越靠近城门越忙", "L12":"守门武士"
}

@export var chapter_names: Dictionary = {
    "1":"第一章 · 村庄", "2":"第二章 · 月夜码头", "3":"第三章 · 天守阁"
}

func chapter_for_level(level_id: String) -> int:
    var i := level_ids.find(level_id)
    if i < 4: return 1
    if i < 8: return 2
    return 3

func previous_level(level_id: String) -> String:
    var i := level_ids.find(level_id)
    if i <= 0: return ""
    return level_ids[i - 1]

func scene_path(level_id: String) -> String:
    return "res://scenes/levels/%s.tscn" % level_id
