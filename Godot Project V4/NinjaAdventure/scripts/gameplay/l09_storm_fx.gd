class_name L09StormFX
extends Node2D

@export var rain_count := 150
@export var area := Rect2(40, 115, 1020, 500)
@export var rain_speed := 520.0

var phase := 0.0
var flash_timer := 0.0
var next_flash := 6.5

func _ready() -> void:
    z_index = 40
    set_process(true)
    queue_redraw()

func _process(delta: float) -> void:
    phase += delta
    flash_timer = maxf(0.0, flash_timer - delta)
    next_flash -= delta
    if next_flash <= 0.0:
        flash_timer = 0.10
        # 固定节奏，不改变关卡因果，只提供雷雨压力演出。
        next_flash = 7.0 + fmod(phase * 1.37, 4.0)
    queue_redraw()

func _draw() -> void:
    draw_rect(area, Color(0.05, 0.08, 0.18, 0.12), true)
    var width := area.size.x
    var height := area.size.y
    for i in range(rain_count):
        var seed := float(i * 37)
        var x := area.position.x + fmod(seed * 1.91 + phase * 70.0, width)
        var y := area.position.y + fmod(seed * 2.73 + phase * rain_speed, height)
        var len := 7.0 + fmod(seed, 7.0)
        var drift := -5.0 - fmod(seed, 3.0)
        draw_line(Vector2(x, y), Vector2(x + drift, y + len), Color(0.70, 0.80, 1.0, 0.20), 1.0)
    if flash_timer > 0.0:
        var a := 0.18 + flash_timer * 0.9
        draw_rect(area, Color(0.88, 0.94, 1.0, a), true)
