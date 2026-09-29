class_name SpriteAnimator
extends RefCounted

# Ninja Adventure 素材规范：
# - 角色表（忍者/武士）：16×16 单元格，列=方向（DOWN=0, UP=1, LEFT=2, RIGHT=3），行 0–3 走路循环，行 4=攻击，5=跳，6=倒地
# - 动物表（猫/狗）：2 帧横向排列，无方向帧，用 flip_h 表达左右
# - Boss（GiantBlueSamurai）：48×48 单元格，12 帧单方向，用 flip_h 表达左右

const CHAR_FPS := 6.0
const ANIMAL_FPS := 6.0
const BOSS_FPS := 8.0
# 方向 -> 列索引：RIGHT=3, DOWN=0, LEFT=2, UP=1（见 FrameDirection 枚举）
const DIR_COLUMNS := [3, 0, 2, 1]

static func attach_character(host: Node2D, texture: Texture2D, sprite_scale := 2.0) -> Sprite2D:
    var sprite := Sprite2D.new()
    sprite.name = "Sprite"
    sprite.texture = texture
    sprite.hframes = 4
    sprite.vframes = 7
    sprite.scale = Vector2(sprite_scale, sprite_scale)
    sprite.offset = Vector2(0, -3)
    host.add_child(sprite)
    return sprite

static func attach_animal(host: Node2D, texture: Texture2D, sprite_scale := 2.0) -> Sprite2D:
    var sprite := Sprite2D.new()
    sprite.name = "Sprite"
    sprite.texture = texture
    sprite.hframes = 2
    sprite.scale = Vector2(sprite_scale, sprite_scale)
    sprite.offset = Vector2(0, -2)
    host.add_child(sprite)
    return sprite

static func attach_boss(host: Node2D, texture: Texture2D, sprite_scale := 1.0) -> Sprite2D:
    var sprite := Sprite2D.new()
    sprite.name = "Sprite"
    sprite.texture = texture
    sprite.hframes = 12
    sprite.scale = Vector2(sprite_scale, sprite_scale)
    host.add_child(sprite)
    return sprite

static func update_character(sprite: Sprite2D, facing: Vector2, moving: bool, anim_time: float) -> void:
    var angle_int := wrapi(int(round(rad_to_deg(facing.angle()) / 90.0)), 0, 4)
    sprite.frame_coords.x = DIR_COLUMNS[angle_int]
    sprite.frame_coords.y = int(anim_time * CHAR_FPS) % 4 if moving else 0

static func update_animal(sprite: Sprite2D, facing: Vector2, moving: bool, anim_time: float) -> void:
    if facing.x != 0.0:
        sprite.flip_h = facing.x < 0.0
    sprite.frame_coords.x = int(anim_time * ANIMAL_FPS) % 2 if moving else 0

static func update_boss(sprite: Sprite2D, anim_time: float) -> void:
    sprite.frame_coords.x = int(anim_time * BOSS_FPS) % 12
