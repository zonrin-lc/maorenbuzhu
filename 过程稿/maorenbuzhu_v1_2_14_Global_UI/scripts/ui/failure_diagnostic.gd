class_name FailureDiagnostic
extends Control

const MESSAGES := {
    "FAIL_TOO_LATE": ["来晚了", "下一次可以更早赶到事件点。"],
    "FAIL_WRONG_ORDER": ["顺序变了", "前一个事件改变了后续路线状态。"],
    "FAIL_SUSPICION": ["被发现了", "这次操作落进了忍者的视线。"],
    "FAIL_NINJA_DEATH": ["没赶上", "忍者在事件发生前没有得到保护。"],
    "FAIL_BOSS_FINISHER": ["终结动作发生了", "Boss 的最后一击没有被化解。"],
    "FAIL_ROUTE_BLOCKED": ["路被堵了", "关键路线状态还没有打开。"],
    "FAIL_TIMEOUT": ["时间到了", "这一轮没有在时间窗口内完成。"],
}

@onready var title_label: Label = %FailureTitle
@onready var body_label: Label = %FailureBody

func show_failure(fail_code: String) -> void:
    var pair: Array = MESSAGES.get(fail_code, ["任务失败", "下一次换一种处理顺序试试。"])
    title_label.text = str(pair[0])
    body_label.text = str(pair[1])
    visible = true
