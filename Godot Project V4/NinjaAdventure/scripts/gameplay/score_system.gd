class_name ScoreSystem
extends RefCounted

# 三猫爪公式（GDD §7.4）：阈值与条件池由 ScoreRuleData 数据驱动，不写死
# 普通关条件池 A–F 满足 paw3_required_count 项；Boss 关条件池由 rules.boss_condition_ids 声明
# （L12 = A–E + G，G = boss_mechanics_success >= rules.boss_mechanics_min_for_g，F 仅作附加展示不计入）
func evaluate(mission_complete: bool, ninja_hp: int, max_suspicion: float, elapsed_time: float, high_risk_rescue: int, chain_rescue: int, shortcut_mastery: bool, rules: ScoreRuleData, boss_mechanics_success: int = 0) -> int:
    if rules == null:
        rules = ScoreRuleData.new()
    if not mission_complete:
        return 0
    if ninja_hp < rules.ninja_hp_min_for_paw3:
        return 1  # ninja_hp 低于下限永不可得 3 爪（防止卖血刷高风险救场）
    if max_suspicion >= rules.max_suspicion_for_paw2:
        return 1
    var results := {
        &"A": ninja_hp == 3,
        &"B": max_suspicion < rules.max_suspicion_for_paw3,
        &"C": elapsed_time <= rules.target_time,
        &"D": high_risk_rescue >= 1,
        &"E": chain_rescue >= 1,
        &"F": shortcut_mastery,
        &"G": boss_mechanics_success >= rules.boss_mechanics_min_for_g,
    }
    var pool: Array = [&"A", &"B", &"C", &"D", &"E", &"F"]
    var required := rules.paw3_required_count
    if rules.is_boss_ruleset():
        pool = []
        for id in rules.boss_condition_ids:
            pool.append(StringName(id))
        required = rules.paw3_boss_required_count
    var checks := 0
    for id in pool:
        if results.get(id, false):
            checks += 1
    return 3 if checks >= required else 2
