extends Node
class_name Level

@onready var Player = preload("res://characters/Player.tscn")

func _ready() -> void:
	var p = Player.instantiate()
	add_child(p)
	p.position = $PlayerSpawnPoint.position
