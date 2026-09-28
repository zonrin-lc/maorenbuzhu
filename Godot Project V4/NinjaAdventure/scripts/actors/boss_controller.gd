class_name BossController
extends Node2D

signal phase_changed(phase: int)
signal defeated
signal retreat

var phase := 0
var hp := 100
var active := false
var timer := 0.0
var charge_timer := 0.0
var charge_window := 2.0
var prepared_damage := 0
var manager: Node
var sprite: Sprite2D
var anim_time := 0.0

func _ready() -> void:
    sprite = SpriteAnimator.attach_boss(self, load("res://assets/actors/boss_giant_blue_samurai/idle.png"))
    sprite.modulate = Color(0.55, 0.55, 0.6)

func setup(owner: Node) -> void:
    manager = owner
    phase = 0
    hp = 100
    active = false
    timer = 0.0
    charge_timer = 0.0
    prepared_damage = 0
    queue_redraw()

func prepare(amount: int) -> void:
    prepared_damage += amount

func start_boss() -> void:
    active = true
    phase = 1
    timer = 0.0
    charge_timer = 0.0
    if prepared_damage > 0:
        hp = max(1, hp - prepared_damage)
        prepared_damage = 0
        _sync_phase_from_hp()
    phase_changed.emit(phase)
    queue_redraw()

func damage(amount: int, source: StringName) -> void:
    if not active:
        return
    hp = max(0, hp - amount)
    _sync_phase_from_hp()
    if hp <= 0:
        active = false
        defeated.emit()
        return
    timer = 0.0
    charge_timer = 0.0
    queue_redraw()

func _sync_phase_from_hp() -> void:
    if hp <= 30:
        phase = 3
    elif hp <= 60:
        phase = 2
    elif phase < 1:
        phase = 1
    phase_changed.emit(phase)

func _process(delta: float) -> void:
    sprite.modulate = Color.WHITE if active else Color(0.55, 0.55, 0.6)
    anim_time += delta
    SpriteAnimator.update_boss(sprite, anim_time)
    if not active:
        queue_redraw()
        return
    timer += delta
    if phase == 1 and timer >= 3.0:
        phase = 2
        charge_timer = 0.0
        phase_changed.emit(phase)
    elif phase == 2:
        charge_timer += delta
        if charge_timer >= 5.0:
            phase = 3
            phase_changed.emit(phase)
    elif phase == 3 and timer >= 8.0 and hp > 0:
        if manager and manager.can_boss_finish():
            active = false
            retreat.emit()
        elif timer >= 12.0 and manager and manager.has_method("on_boss_overrun"):
            active = false
            manager.call("on_boss_overrun")
    queue_redraw()

func is_in_charge_window() -> bool:
    return active and phase == 2 and charge_timer <= charge_window

func _draw() -> void:
    if active:
        draw_circle(Vector2.ZERO, 58.0, Color(0.5, 0.05, 0.05, 0.08))
        draw_arc(Vector2.ZERO, 54.0, 0.0, TAU, 48, Color(0.95, 0.25, 0.25, 0.22), 2.0)
        draw_arc(Vector2.ZERO, 34.0, 0.0, TAU * float(hp) / 100.0, 36, Color("#ef4444"), 4.0)
