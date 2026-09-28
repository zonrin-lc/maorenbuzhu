class_name ResultPanel
extends Control

@onready var paw_label: Label = %PawLabel
@onready var stats_label: Label = %StatsLabel
@onready var boast_label: Label = %BoastLabel

func show_result(payload: Dictionary) -> void:
    var paws := int(payload.get("paws", 1))
    var elapsed := float(payload.get("elapsed_time", 0.0))
    var max_suspicion := float(payload.get("max_suspicion", 0.0))
    var risk_style := str(payload.get("risk_style", "BALANCED"))
    var target_time := float(payload.get("target_time", 0.0))
    var time_status := "三星线内" if target_time <= 0.0 or elapsed <= target_time else "超过三星线"
    var boast := str(payload.get("boast", "今天的任务顺利得出奇。"))
    paw_label.text = "🐾".repeat(paws)
    stats_label.text = "时间 %.1fs   三星 %.0fs（%s）   怀疑峰值 %.0f   %s" % [elapsed, target_time, time_status, max_suspicion, risk_style]
    boast_label.text = boast
    visible = true
    var card := get_node_or_null("ResultCard") as Control
    if card != null:
        card.modulate = Color(1, 1, 1, 0)
        card.position.y += 18.0
        var tw := create_tween()
        tw.tween_property(card, "modulate:a", 1.0, 0.18)
        tw.parallel().tween_property(card, "position:y", card.position.y - 18.0, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    paw_label.scale = Vector2(0.8, 0.8)
    var paw_tween := create_tween()
    paw_tween.tween_interval(0.15)
    paw_tween.tween_property(paw_label, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    GlobalAudioManager.play_event_sfx("success")
