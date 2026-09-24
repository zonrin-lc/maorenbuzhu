class_name BoastGenerator
extends RefCounted

## Data-driven settlement line selection.
## EventLog remains the source of truth; this class only derives presentation.

func build_tags(event_log: Array[Dictionary]) -> Dictionary:
    var tags: Dictionary = {}
    for event in event_log:
        if not event.get("success", false):
            continue
        var event_type := String(event.get("event_type", ""))
        match event_type:
            "TRIPWIRE": tags["TRIPWIRE"] = true
            "GUARD": tags["GUARD"] = true
            "DOG": tags["DOG"] = true
            "POISON": tags["POISON"] = true
            "BRIDGE": tags["BRIDGE"] = true
            "CALTROP": tags["CALTROP"] = true
            "DYNAMITE": tags["DYNAMITE"] = true
            "BOSS_CRANE": tags["BOSS_CRANE"] = true
            "BOSS_GOURD": tags["BOSS_GOURD"] = true
            "BOSS_CALTROP": tags["BOSS_CALTROP"] = true
        if event.get("emergency_window", false):
            tags["EMERGENCY"] = true
        if event.get("ninja_hp_after", 3) <= 1:
            tags["NEAR_DEATH"] = true
        if event.get("high_risk", false):
            tags["HIGH_RISK"] = true
        if event.get("shortcut_used", false):
            tags["SHORTCUT"] = true
        if event.get("route_change", false):
            tags["ROUTE_CHANGE"] = true
    return tags

func classify_importance(tags: Dictionary) -> String:
    if tags.get("EMERGENCY", false): return "EMERGENCY"
    if tags.get("NEAR_DEATH", false): return "NEAR_DEATH"
    if tags.get("BOSS_CALTROP", false) or tags.get("BOSS_CRANE", false) or tags.get("BOSS_GOURD", false): return "BOSS"
    if tags.get("CHAIN", false): return "CHAIN"
    if tags.get("ROUTE_CHANGE", false): return "ROUTE_CHANGE"
    return "STANDARD_SUCCESS"
