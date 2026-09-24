class_name ScoreSystem
extends RefCounted

func evaluate(mission_complete: bool, ninja_hp: int, max_suspicion: float, elapsed_time: float, high_risk_rescue: int, chain_rescue: int, shortcut_mastery: bool, target_time: float) -> int:
    if not mission_complete:
        return 0
    if ninja_hp < 2:
        return 1
    if max_suspicion >= 80.0:
        return 1
    var checks := 0
    if ninja_hp == 3:
        checks += 1
    if max_suspicion < 50.0:
        checks += 1
    if elapsed_time <= target_time:
        checks += 1
    if high_risk_rescue >= 1:
        checks += 1
    if chain_rescue >= 1:
        checks += 1
    if shortcut_mastery:
        checks += 1
    return 3 if checks >= 4 else 2
