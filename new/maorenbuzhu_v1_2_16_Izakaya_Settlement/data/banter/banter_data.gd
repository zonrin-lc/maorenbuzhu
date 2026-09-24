class_name BanterData
extends Resource

@export var banter_id: String
@export var priority: String
@export var required_tags: Array[String] = []
@export var forbidden_tags: Array[String] = []
@export var level_scope: Array[String] = []
@export var difficulty_scope: Array[String] = ["NORMAL", "HARD", "HARD+"]
@export_multiline var text_template: String
@export_multiline var cat_response: String
@export var voice_id: String = ""
@export var weight: float = 1.0
