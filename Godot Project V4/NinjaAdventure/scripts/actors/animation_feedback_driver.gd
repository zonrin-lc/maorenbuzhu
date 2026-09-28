class_name AnimationFeedbackDriver
extends Node

# v1.5.3：统一“动作层级”反馈。只处理表现，不改变玩法判定。
# 优先级：DEATH > HIT > ACTION > EMOTE > ALERT > CARRY > MOVE > IDLE。

enum State {
    IDLE,
    MOVE,
    CARRY,
    ALERT,
    EMOTE,
    ACTION,
    HIT,
    DEATH,
    VICTORY,
}

const PRIORITY := {
    State.IDLE: 10,
    State.MOVE: 20,
    State.CARRY: 30,
    State.ALERT: 40,
    State.EMOTE: 50,
    State.ACTION: 60,
    State.HIT: 80,
    State.VICTORY: 90,
    State.DEATH: 100,
}

var sprite: Sprite2D
var actor_kind: StringName = &"animal"
var base_state: int = State.IDLE
var state: int = State.IDLE
var state_remaining := 0.0
var anim_clock := 0.0
var base_scale := Vector2.ONE
var base_rotation := 0.0
var base_offset := Vector2.ZERO
var base_position := Vector2.ZERO
var base_modulate := Color.WHITE

func setup(target_sprite: Sprite2D, kind: StringName) -> void:
    sprite = target_sprite
    actor_kind = kind
    if sprite != null:
        base_scale = sprite.scale
        base_rotation = sprite.rotation
        base_offset = sprite.offset
        base_position = sprite.position
        base_modulate = sprite.modulate

func set_base_modulate(color: Color) -> void:
    base_modulate = color
    if sprite != null and state != State.HIT and state != State.DEATH:
        sprite.modulate = color

func set_base_state(new_state: int) -> void:
    base_state = new_state
    if state_remaining <= 0.0 or PRIORITY.get(new_state, 0) >= PRIORITY.get(state, 0):
        state = new_state
        state_remaining = 0.0

func play(new_state: int, duration: float) -> void:
    if sprite == null:
        return
    var new_priority: int = PRIORITY.get(new_state, 0)
    var current_priority: int = PRIORITY.get(state, 0)
    if state_remaining > 0.0 and new_priority < current_priority:
        return
    state = new_state
    state_remaining = max(0.0, duration)
    anim_clock = 0.0

func _process(delta: float) -> void:
    if sprite == null:
        return
    anim_clock += delta
    if state_remaining > 0.0:
        state_remaining = max(0.0, state_remaining - delta)
        if state_remaining <= 0.0:
            state = base_state
    _apply_transform()

func _apply_transform() -> void:
    var t := anim_clock
    sprite.rotation = base_rotation
    sprite.offset = base_offset
    sprite.position = base_position
    sprite.scale = base_scale

    match state:
        State.MOVE:
            sprite.scale = base_scale * (1.0 + sin(t * 18.0) * 0.012)
        State.CARRY:
            sprite.scale = base_scale * (1.0 + sin(t * 12.0) * 0.018)
            sprite.offset = base_offset + Vector2(0, -1.5)
        State.ALERT:
            sprite.scale = base_scale * (1.0 + sin(t * 14.0) * 0.02)
        State.EMOTE:
            var pulse := 1.0 + sin(min(t, 0.24) / 0.24 * PI) * 0.10
            sprite.scale = base_scale * pulse
            sprite.rotation = sin(t * 24.0) * 0.06
        State.ACTION:
            sprite.scale = base_scale * (1.0 + sin(t * 20.0) * 0.035)
            sprite.rotation = sin(t * 18.0) * 0.045
            if actor_kind == &"character" and sprite.vframes >= 7:
                sprite.frame_coords.y = 4
        State.HIT:
            var shake: float = sin(t * 70.0) * max(0.0, state_remaining + 0.02) * 0.08
            sprite.rotation = shake
            sprite.scale = base_scale * (1.0 - min(t, 0.16) * 0.4)
            if actor_kind == &"character" and sprite.vframes >= 7:
                sprite.frame_coords.y = 6
        State.VICTORY:
            var jump_phase: float = min(t / 0.42, 1.0)
            sprite.position.y = -sin(jump_phase * PI) * 5.0
            sprite.scale = base_scale * (1.0 + sin(jump_phase * PI) * 0.06)
        State.DEATH:
            sprite.rotation = lerp(base_rotation, base_rotation + 0.35, min(t / 0.5, 1.0))
            sprite.scale = base_scale * (1.0 - min(t / 0.8, 0.22))
            sprite.modulate.a = max(0.35, 1.0 - min(t / 1.2, 0.65))
            if actor_kind == &"character" and sprite.vframes >= 7:
                sprite.frame_coords.y = 6
        _:
            pass

    if state == State.HIT:
        var flash_phase: float = clamp(anim_clock / 0.18, 0.0, 1.0)
        var tint: Color = base_modulate
        sprite.modulate = Color(
            lerp(tint.r, 1.0, 0.45),
            lerp(tint.g, 0.55, 0.45 + 0.45 * flash_phase),
            lerp(tint.b, 0.55, 0.45 + 0.45 * flash_phase),
            tint.a
        )
    elif state == State.DEATH:
        sprite.modulate.a = max(0.35, base_modulate.a * (1.0 - min(t / 1.2, 0.65)))
    else:
        sprite.modulate = base_modulate
