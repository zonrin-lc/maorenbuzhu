class_name LevelModifier
extends Resource

## Hard Mode 修饰（GDD Hard Mode 参数）：只应用在关卡数据的运行时副本上，
## 默认值全部为“不改变”。

@export var ninja_speed_mult: float = 1.0
@export var hesitation_delta: float = 0.0
@export var suspicion_gain_mult: float = 1.0
@export var event_timeout_mult: float = 1.0
@export var boss_prepare_delta: float = 0.0
