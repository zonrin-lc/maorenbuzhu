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
    var boast := str(payload.get("boast", "今天的任务顺利得出奇。"))
    paw_label.text = "🐾".repeat(paws)
    stats_label.text = "时间 %.1fs   怀疑峰值 %.0f   %s" % [elapsed, max_suspicion, risk_style]
    boast_label.text = boast
    visible = true
