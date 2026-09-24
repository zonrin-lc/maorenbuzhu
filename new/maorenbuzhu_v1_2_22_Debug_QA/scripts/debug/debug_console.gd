extends Node
class_name DebugConsole

signal command_executed(command: String, args: PackedStringArray, result: String)
signal state_changed

var enabled := true
var history: Array[String] = []
var suspended := false
var current_level_id := "L01"
var boss_phase := "NONE"
var ninja_hp := 3
var suspicion := 0
var world_state: Dictionary = {}

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _register_defaults()

func _register_defaults() -> void:
    world_state = {
        "guard_a_departed": false,
        "guard_b_active": true,
        "dog_fed": false,
        "bridge_open": false,
        "poison_route_safe": false,
        "boss_crane_ready": false,
        "boss_caltrop_ready": false,
        "boss_gourd_ready": false,
        "boss_phase": "NONE",
        "boss_retreat": false,
    }

func execute(line: String) -> String:
    line = line.strip_edges()
    if line.is_empty():
        return ""
    var tokens := line.split(" ", false)
    var command := tokens[0].to_lower()
    var args := PackedStringArray()
    for i in range(1, tokens.size()):
        args.append(tokens[i])

    var result := _execute_command(command, args)
    history.append("> " + line)
    history.append(result)
    command_executed.emit(command, args, result)
    state_changed.emit()
    return result

func _execute_command(command: String, args: PackedStringArray) -> String:
    match command:
        "help":
            return "commands: help | level <L01-L12> | win | fail <FAIL_CODE> | hp <0-3> | suspicion <0-100> | world <flag> <0|1> | boss <NONE|PREPARE|PHASE_1|PHASE_2|PHASE_3|DEFEAT> | event <event_id> | validate | pause_sim | resume_sim | reset"
        "level":
            if args.size() != 1 or not _valid_level(args[0]):
                return "ERR level expects L01-L12"
            current_level_id = args[0].to_upper()
            return "OK level=" + current_level_id
        "win":
            return "OK simulated mission_complete=true"
        "fail":
            if args.size() != 1:
                return "ERR fail expects FAIL_CODE"
            return "OK simulated failure=" + args[0].to_upper()
        "hp":
            if args.size() != 1:
                return "ERR hp expects 0-3"
            ninja_hp = clampi(int(args[0]), 0, 3)
            return "OK ninja_hp=" + str(ninja_hp)
        "suspicion":
            if args.size() != 1:
                return "ERR suspicion expects 0-100"
            suspicion = clampi(int(args[0]), 0, 100)
            return "OK suspicion=" + str(suspicion)
        "world":
            if args.size() != 2 or not world_state.has(args[0]):
                return "ERR world <known_flag> <0|1>"
            world_state[args[0]] = args[1] == "1"
            return "OK " + args[0] + "=" + str(world_state[args[0]])
        "boss":
            if args.size() != 1:
                return "ERR boss expects phase"
            boss_phase = args[0].to_upper()
            world_state["boss_phase"] = boss_phase
            return "OK boss_phase=" + boss_phase
        "event":
            if args.size() != 1:
                return "ERR event expects event_id"
            return "OK simulated event_trigger=" + args[0]
        "validate":
            if has_node("/root/QATestRunner"):
                var runner = get_node("/root/QATestRunner")
                return runner.run_quick_validation(current_level_id)
            return "WARN QATestRunner unavailable"
        "pause_sim":
            suspended = true
            get_tree().paused = true
            return "OK simulation_paused=true"
        "resume_sim":
            suspended = false
            get_tree().paused = false
            return "OK simulation_paused=false"
        "reset":
            ninja_hp = 3
            suspicion = 0
            boss_phase = "NONE"
            _register_defaults()
            return "OK debug_state_reset"
        _:
            return "ERR unknown command: " + command

func _valid_level(value: String) -> bool:
    var id := value.to_upper()
    return id.length() == 3 and id.begins_with("L") and int(id.substr(1, 2)) >= 1 and int(id.substr(1, 2)) <= 12
