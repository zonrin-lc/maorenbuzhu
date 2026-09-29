extends Node2D

# 结算音乐会漏到章节过场（无人重置音乐状态）。
const UI_FONT := preload("res://theme/ui_font.tres")

func _ready() -> void:
    GlobalAudioManager.stop_music()
    queue_redraw()

# Chapter 1 结束页。原先唯一出口是「Enter → L01」，导致第二章（L05+）在
# 线性流程里永远到不了（只能靠「继续游戏」绕）。现在给出完整三向出口：
#   confirm(Enter) -> 第二章 L05    retry(R) -> 重玩第一章    cancel(ESC) -> 主菜单
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("confirm"):
        get_viewport().set_input_as_handled()
        get_tree().change_scene_to_file("res://scenes/levels/ch02_dock/L05_moonlit_dock.tscn")
    elif event.is_action_pressed("retry"):
        get_viewport().set_input_as_handled()
        get_tree().change_scene_to_file("res://scenes/levels/ch01_village/L01_first_job.tscn")
    elif event.is_action_pressed("cancel") or event.is_action_pressed("pause"):
        get_viewport().set_input_as_handled()
        get_tree().change_scene_to_file("res://scenes/flow/main_menu.tscn")

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color("#0f172a"))
    var cx := 640.0
    draw_string(UI_FONT, Vector2(cx - 220, 260), "第一章完成", HORIZONTAL_ALIGNMENT_CENTER, 440, 42, Color("#fbbf24"))
    draw_string(UI_FONT, Vector2(cx - 360, 320), "你已经学会：提前行动、制造误差、临场急救。", HORIZONTAL_ALIGNMENT_CENTER, 720, 22, Color("#f8fafc"))
    draw_string(UI_FONT, Vector2(cx - 300, 390), "Enter 进入第二章    R 重玩第一章    ESC 返回主菜单", HORIZONTAL_ALIGNMENT_CENTER, 600, 18, Color("#94a3b8"))
