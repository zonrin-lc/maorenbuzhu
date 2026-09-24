extends Node2D

func _ready() -> void:
    queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
    if event.pressed and event.keycode == KEY_ENTER:
        get_tree().change_scene_to_file("res://scenes/levels/L01_first_job.tscn")

func _draw() -> void:
    draw_rect(Rect2(0,0,1100,680), Color("#0f172a"))
    draw_string(ThemeDB.fallback_font, Vector2(350,250), "第一章完成", HORIZONTAL_ALIGNMENT_LEFT, -1, 42, Color("#fbbf24"))
    draw_string(ThemeDB.fallback_font, Vector2(300,310), "你已经学会：提前行动、制造误解、暗中救场。", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#f8fafc"))
    draw_string(ThemeDB.fallback_font, Vector2(390,380), "Enter 重新挑战第一关", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#94a3b8"))
