class_name ScoreSystem
extends RefCounted

# 三猫爪公式（GDD §7.4）：阈值由 ScoreRuleData 数据驱动，不写死
func evaluate(mission_complete: bool, ninja_hp: int, max_suspicion: float, elapsed_time: float, high_risk_rescue: int, chain_rescue: int, shortcut_mastery: bool, rules: ScoreRuleData) -> int:
    if rules == null:
        rules = ScoreRuleData.new()
    if not mission_complete:
        return 0
    if ninja_hp < 2:
        return 1  # ninja_hp < 2 永不可得 3 爪（防止卖血刷高风险救场）
    if max_suspicion >= rules.max_suspicion_for_paw2:
        return 1
    var checks := 0
    if ninja_hp == 3:                                    # A
        checks += 1
    if max_suspicion < rules.max_suspicion_for_paw3:     # B
        checks += 1
    if elapsed_time <= rules.target_time:                # C
        checks += 1
    if high_risk_rescue >= 1:                            # D
        checks += 1
    if chain_rescue >= 1:                                # E
        checks += 1
    if shortcut_mastery:                                 # F
        checks += 1
    return 3 if checks >= 4 else 2
