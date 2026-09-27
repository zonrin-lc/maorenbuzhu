extends CanvasLayer

@onready var console: DebugConsole = get_node("/root/DebugConsole")
@onready var state_label: Label = %StateLabel
@onready var log_label: RichTextLabel = %LogLabel
@onready var command_edit: LineEdit = %CommandEdit
@onready var command_button: Button = %CommandButton

func _ready() -> void:
    console.command_executed.connect(_on_command)
    command_button.pressed.connect(_submit)
    command_edit.text_submitted.connect(func(_text): _submit())
    _refresh()

func _submit() -> void:
    var result := console.execute(command_edit.text)
    command_edit.clear()
    _refresh()

func _on_command(_command: String, _args: PackedStringArray, _result: String) -> void:
    _refresh()

func _refresh() -> void:
    state_label.text = "LEVEL %s  | HP %d  | SUSP %d  | BOSS %s" % [console.current_level_id, console.ninja_hp, console.suspicion, console.boss_phase]
    log_label.text = "\n".join(console.history.slice(maxi(0, console.history.size() - 14)))
