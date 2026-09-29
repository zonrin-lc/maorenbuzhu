class_name ProgressManagerClass
extends Node

const LEVEL_ORDER := ["L01","L02","L03","L04","L05","L06","L07","L08","L09","L10","L11","L12"]

func is_level_unlocked(level_id: String, save: SaveData) -> bool:
    var idx := LEVEL_ORDER.find(level_id)
    # 未知关卡 ID 必须 fail-closed：find() 返回 -1，而 -1 <= 0 原本会判为「已解锁」，
    # 于是被手改坏的存档（last_level_id = "L99"）会让「继续游戏」永久卡死在不存在的场景。
    if idx < 0:
        return false
    if idx == 0:
        return true
    return save.completed_levels.has(LEVEL_ORDER[idx - 1])

func chapter_clear(chapter: int, save: SaveData) -> bool:
    match chapter:
        1: return save.completed_levels.has("L04")
        2: return save.completed_levels.has("L08")
        3: return save.completed_levels.has("L12")
    return false

func chapter_unlocked(chapter: int, save: SaveData) -> bool:
    if chapter == 1:
        return true
    return chapter_clear(chapter - 1, save)

func fish_total(save: SaveData) -> int:
    var total := 0
    for level_id in LEVEL_ORDER:
        total += _bit_count(int(save.fish_collected.get(level_id, 0)))
    return total

func paws_total(save: SaveData, difficulty: String = "NORMAL") -> int:
    var total := 0
    for level_id in LEVEL_ORDER:
        total += int(save.best_paws.get("%s:%s" % [difficulty, level_id], 0))
    return total

func _bit_count(mask: int) -> int:
    var c := 0
    while mask != 0:
        c += mask & 1
        mask >>= 1
    return c
