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
var prepare_time := 3.0 # Phase 1 战前准备窗口；Hard Mode 通过 LevelModifier.boss_prepare_delta 调整
var prepared_damage := 0
var manager: Node
var sprite: Sprite2D
var anim_time := 0.0
var anim_driver: AnimationFeedbackDriver

func _ready() -> void:
    sprite = SpriteAnimator.attach_boss(self, load("res://assets/actors/boss_giant_blue_samurai/idle.png"))
    anim_driver = AnimationFeedbackDriver.new()
    anim_driver.name = "AnimationFeedback"
    add_child(anim_driver)
    anim_driver.setup(sprite, &"boss")
    anim_driver.set_base_modulate(Color(0.55, 0.55, 0.6))

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
    if anim_driver != null:
        anim_driver.set_base_modulate(Color.WHITE)
    if anim_driver != null:
        anim_driver.play(AnimationFeedbackDriver.State.ACTION, 0.45)
    timer = 0.0
    charge_timer = 0.0
    if prepared_damage > 0:
        hp = max(1, hp - prepared_damage)
        prepared_damage = 0
    # 阶段只经 set_phase 单一出口变更。此前这里先直接 `phase = 1`，再调 set_phase(1)
    # 会被其守卫挡掉，导致 phase_changed(1) 永不 emit：Boss 开场音乐停在 PREPARE、
    # world_state 也拿不到 boss_phase_1。
    set_phase(1)
    # 注意：不在此处按 HP 同步阶段——阶段推进由时间线驱动（P1→P2→P3），
    # 预伤害只降血量，不得跳过 Phase 2（战中蒺藜窗口），见 GDD §6.3。

func damage(amount: int, source: StringName) -> void:
    if not active:
        return
    hp = max(0, hp - amount)
    if anim_driver != null:
        anim_driver.play(AnimationFeedbackDriver.State.DEATH if hp <= 0 else AnimationFeedbackDriver.State.HIT, 1.2 if hp <= 0 else 0.42)
    _sync_phase_from_hp()
    if hp <= 0:
        active = false
        if anim_driver != null:
            anim_driver.set_base_modulate(Color(0.55, 0.55, 0.6))
            anim_driver.play(AnimationFeedbackDriver.State.DEATH, 1.2)
        defeated.emit()
        return
    timer = 0.0
    # charge_timer 驱动 Phase 2→3；Phase 2 期间被伤害不应重置它，否则 Boss 永远卡在 P2。
    if phase < 2:
        charge_timer = 0.0
    queue_redraw()

func set_phase(new_phase: int) -> void:
    # Phase 改变只有一个出口（GDD §4.8 / 实现债收口）：任何来源统一走这里 emit
    if new_phase == phase:
        return
    phase = new_phase
    phase_changed.emit(phase)
    queue_redraw()

func _sync_phase_from_hp() -> void:
    var new_phase := phase
    if hp <= 30:
        new_phase = 3
    elif hp <= 60:
        new_phase = 2
    elif new_phase < 1:
        new_phase = 1
    # 血量只许把阶段往前推一格，不允许跨级跳阶段（保护 Phase 2 战中蒺藜窗口）。
    if new_phase > phase + 1:
        new_phase = phase + 1
    set_phase(new_phase)

func _process(delta: float) -> void:
    anim_time += delta
    SpriteAnimator.update_boss(sprite, anim_time)
    if not active:
        queue_redraw()
        return
    timer += delta
    if phase == 1 and timer >= prepare_time:
        set_phase(2)
        charge_timer = 0.0
    elif phase == 2:
        charge_timer += delta
        if charge_timer >= 5.0:
            set_phase(3)
    elif phase == 3 and timer >= 8.0 and hp > 0:
        if manager and manager.can_boss_finish():
            active = false
            if anim_driver != null:
                anim_driver.set_base_modulate(Color(0.55, 0.55, 0.6))
                anim_driver.play(AnimationFeedbackDriver.State.VICTORY, 0.80)
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
