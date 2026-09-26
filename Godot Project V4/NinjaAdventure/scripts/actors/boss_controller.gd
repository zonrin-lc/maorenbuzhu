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
    if not active:
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
    queue_redraw()

func is_in_charge_window() -> bool:
    return active and phase == 2 and charge_timer <= charge_window

func _draw() -> void:
    var body := Color("#7c2d12") if active else Color("#57534e")
    draw_circle(Vector2.ZERO, 26.0, body)
    draw_circle(Vector2(-7, -5), 3.0, Color("#fef3c7"))
    draw_circle(Vector2(7, -5), 3.0, Color("#fef3c7"))
    draw_circle(Vector2(-7, -5), 1.3, Color.BLACK)
    draw_circle(Vector2(7, -5), 1.3, Color.BLACK)
    if active:
        draw_arc(Vector2.ZERO, 34.0, 0.0, TAU * float(hp) / 100.0, 36, Color("#ef4444"), 4.0)
