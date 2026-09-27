extends Node

func _ready() -> void:
    var app := AppFlow.new()
    add_child(app)
    await app.ready
