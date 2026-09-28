class_name LevelData
extends Resource

@export var level_id: StringName
@export var chapter_id: StringName
@export var display_name: String
@export_file("*.tscn") var scene_path: String
@export_file("*.tscn") var next_scene_path: String
@export var intro_time: float = 10.0
@export var target_time: float = 60.0
@export var ninja_route: RouteData
@export var events: Array[EventPointData] = []
@export var score_rules: ScoreRuleData
@export var variant: VariantData
