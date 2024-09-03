extends Node

func _ready() -> void:
	var level = load("res://levels/TestLevel.tscn")
	add_child(level.instantiate())
