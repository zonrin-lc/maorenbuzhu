class_name CastleEventPoint
extends EventPoint

func _process(delta: float) -> void:
    if resolved_state or level_manager == null or level_manager.level_finished or level_manager.level_failed:
        return
    var cat = level_manager.cat
    var ninja = level_manager.ninja
    if cat == null or ninja == null:
        return
    var near_ninja := global_position.distance_to(ninja.global_position) <= data.trigger_radius
    if near_ninja:
        timer += delta
    else:
        timer = 0.0

    if data.event_type == &"BOSS_CALTROP":
        if level_manager.boss and level_manager.boss.is_in_charge_window() and global_position.distance_to(cat.global_position) <= 60.0:
            if Input.is_action_pressed("interact"):
                resolve(&"CALTROP_DURING_PHASE2")
                return
        queue_redraw()
        return

    if global_position.distance_to(cat.global_position) <= 56.0 and Input.is_action_pressed("interact"):
        resolve(_action_for_type())
        return

    if near_ninja and data.timeout > 0.0 and timer >= data.timeout:
        fail(data.fail_code)
    queue_redraw()

func _action_for_type() -> StringName:
    match data.event_type:
        &"DYNAMITE": return &"PUSH_TO_WATER"
        &"GUARD": return &"MEOW"
        &"POISON": return &"PLACE_ANTIDOTE"
        &"CALTROP": return &"CLEAR_CALTROP"
        &"TRIPWIRE": return &"BITE"
        &"CLIFF": return &"PUSH_CRATE"
        &"BOSS_CRANE": return &"CUT_CRANE"
        &"BOSS_GOURD": return &"DRUG_GOURD"
        _: return &"INTERACT"
