class_name ScoreRuleData
extends Resource

@export var target_time: float = 60.0
@export var ninja_hp_min_for_paw3: int = 2
@export var max_suspicion_for_paw2: float = 80.0
@export var max_suspicion_for_paw3: float = 50.0
# 三猫爪 Paw3 所需满足的条件数（普通关 A–F 中满足 4 项，GDD §7.4）
@export var paw3_required_count: int = 4
# Boss 关开关：非空即声明本关为 Boss 规则集，条件池 = 此列表（GDD §7.4：A–E + G，F 不计入）
@export var boss_condition_ids: Array[String] = []
@export var paw3_boss_required_count: int = 4
# G 条件阈值：boss_mechanics_success >= 此值记为达成
@export var boss_mechanics_min_for_g: int = 2

func is_boss_ruleset() -> bool:
    return not boss_condition_ids.is_empty()
