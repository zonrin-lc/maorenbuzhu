class_name SettlementResultFlow
extends Node

signal settlement_finished
signal save_warning(message: String)

@export var compact_duration_seconds := 10.0

func present(result: Dictionary, first_clear: bool) -> void:
    # Presentation consumes the finalized result; it does not recalculate score.
    var mode := "FULL" if first_clear else "COMPACT"
    print("[Settlement] mode=%s paws=%s level=%s" % [mode, result.get("paws", 0), result.get("level_id", "")])

func commit_meta(progress_manager: Node, save_manager: Node, level_id: String, result: Dictionary) -> void:
    progress_manager.mark_level_complete(level_id, result)
    if not save_manager.save_game():
        save_warning.emit("本次进度未保存")
    settlement_finished.emit()
