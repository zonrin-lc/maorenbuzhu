class_name RouteData
extends Resource

@export var route_id: StringName
@export var actor_id: StringName
@export var waypoints: Array[Vector2] = []
@export var loop: bool = false
@export var move_speed: float = 60.0
@export var stop_points: Array[StringName] = []
