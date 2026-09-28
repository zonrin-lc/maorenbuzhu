extends Node
class_name CatMeowPlayer

@export var min_repeat_interval := 0.35
@export var max_same_variant_streak := 2

var last_play_time := -999.0
var last_variant := -1
var same_variant_streak := 0

func can_play(now: float) -> bool:
    return now - last_play_time >= min_repeat_interval

func choose_variant(count: int, rng: RandomNumberGenerator) -> int:
    if count <= 1:
        return 0
    var v := rng.randi_range(0, count - 1)
    if v == last_variant and same_variant_streak >= max_same_variant_streak:
        v = (v + 1) % count
    return v

func mark_played(now: float, variant: int) -> void:
    last_play_time = now
    if variant == last_variant:
        same_variant_streak += 1
    else:
        last_variant = variant
        same_variant_streak = 1
