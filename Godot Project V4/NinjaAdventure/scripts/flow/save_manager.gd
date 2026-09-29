class_name SaveManagerClass
extends Node

const SAVE_PATH := "user://save.cfg"
const TEMP_PATH := "user://save.tmp"
const BACKUP_PATH := "user://save.backup.cfg"
const CURRENT_SCHEMA := 1

var data: SaveData

func _ready() -> void:
    load_game()

func load_game() -> bool:
    if not FileAccess.file_exists(SAVE_PATH):
        # 主存档缺失：先尝试读备份。断电/崩溃可能正好停在「SAVE→BACKUP」与
        # 「TEMP→SAVE」两次 rename 之间，此时备份是唯一幸存的进度。此前直接
        # 新建空档再 save_game()，会把那份备份删掉 = 永久丢档。
        if FileAccess.file_exists(BACKUP_PATH) and _load_backup_or_reset(false):
            return true
        data = SaveData.new()
        return save_game()
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return _load_backup_or_reset()
    var text := file.get_as_text()
    file.close()
    var parsed = JSON.parse_string(text)
    if typeof(parsed) != TYPE_DICTIONARY:
        return _load_backup_or_reset()
    var raw: Dictionary = parsed
    var version := int(raw.get("schema_version", 1))
    if version > CURRENT_SCHEMA:
        return _load_backup_or_reset(false)
    data = SaveData.from_dict(raw)
    _migrate(data)
    return true

# 载入时校验 last_level_id：它直接决定「继续游戏」跳哪个场景，且完全来自磁盘。
# 非法值（手改存档 / 版本漂移）会让按钮永久失效。
func _sanitize_last_level(target: SaveData) -> void:
    if target.last_level_id in ProgressManagerClass.LEVEL_ORDER:
        return
    target.last_level_id = "L01"

func save_game() -> bool:
    if data == null:
        data = SaveData.new()
    data.schema_version = CURRENT_SCHEMA
    var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(data.to_dict()))
    file.flush()
    # 写盘失败（磁盘满/IO 错误）时 store_string 只留下截断内容。必须在动备份
    # 之前检测，否则会把截断的临时档提升成正式档，反过来毁掉好存档。
    var write_err := file.get_error()
    file.close()
    if write_err != OK:
        DirAccess.remove_absolute(TEMP_PATH)
        push_warning("SaveManager: 写入失败（错误 %d），保留原存档。" % write_err)
        return false
    if FileAccess.file_exists(BACKUP_PATH):
        DirAccess.remove_absolute(BACKUP_PATH)
    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.rename_absolute(SAVE_PATH, BACKUP_PATH)
    var err := DirAccess.rename_absolute(TEMP_PATH, SAVE_PATH)
    if err != OK:
        if FileAccess.file_exists(BACKUP_PATH):
            DirAccess.rename_absolute(BACKUP_PATH, SAVE_PATH)
        return false
    return true

func get_data() -> SaveData:
    if data == null:
        data = SaveData.new()
    return data

func reset_save() -> bool:
    data = SaveData.new()
    return save_game()

func mark_level_complete(level_id: String, paws: int, time_ms: int, max_suspicion: int, difficulty: String = "NORMAL") -> void:
    if not data.completed_levels.has(level_id):
        data.completed_levels.append(level_id)
    var key := "%s:%s" % [difficulty, level_id]
    data.best_paws[key] = maxi(int(data.best_paws.get(key, 0)), paws)
    var old_time := int(data.best_time_ms.get(key, 0))
    if old_time <= 0 or time_ms < old_time:
        data.best_time_ms[key] = time_ms
    var old_suspicion := int(data.best_max_suspicion.get(key, -1))
    if old_suspicion < 0 or max_suspicion < old_suspicion:
        data.best_max_suspicion[key] = max_suspicion
    data.last_level_id = level_id
    _refresh_unlocks()
    save_game()

func collect_fish(level_id: String, fish_index: int) -> void:
    var key := level_id
    var mask := int(data.fish_collected.get(key, 0))
    mask |= 1 << fish_index
    data.fish_collected[key] = mask
    save_game()

func unlock_skin(skin_id: String) -> void:
    if not data.unlocked_skins.has(skin_id):
        data.unlocked_skins.append(skin_id)
        save_game()

func unlock_talent(talent_id: String) -> void:
    if not data.unlocked_talents.has(talent_id):
        data.unlocked_talents.append(talent_id)
        save_game()

func mark_tutorial_seen(tutorial_id: String) -> void:
    if not data.tutorial_seen.has(tutorial_id):
        data.tutorial_seen.append(tutorial_id)
        save_game()

func _refresh_unlocks() -> void:
    if data.completed_levels.size() >= 12:
        data.hard_mode_unlocked = true
    var all_three := true
    for i in range(1, 13):
        var key := "NORMAL:L%02d" % i
        if int(data.best_paws.get(key, 0)) < 3:
            all_three = false
            break
    data.hard_plus_unlocked = all_three
    if data.completed_levels.has("L04"):
        unlock_skin("ORANGE")
    if data.completed_levels.has("L08"):
        unlock_skin("WHITE")
    if data.completed_levels.has("L12"):
        unlock_skin("GRAY")
    if all_three:
        unlock_skin("CYCLOP")

func _migrate(target: SaveData) -> void:
    if target.unlocked_skins.is_empty():
        target.unlocked_skins = ["BLACK"]
    target.schema_version = CURRENT_SCHEMA
    _sanitize_last_level(target)

func _load_backup_or_reset(reset: bool = true) -> bool:
    if FileAccess.file_exists(BACKUP_PATH):
        var backup := FileAccess.open(BACKUP_PATH, FileAccess.READ)
        if backup:
            var parsed = JSON.parse_string(backup.get_as_text())
            backup.close()
            if typeof(parsed) == TYPE_DICTIONARY:
                data = SaveData.from_dict(parsed)
                _sanitize_last_level(data)
                return true
    data = SaveData.new()
    if reset:
        return save_game()
    return false
