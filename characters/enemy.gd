extends CharacterBody2D

enum MODE {
	PATROLLING, # walks back and forth, looking for player
	AGGRESSIVE # pursues player
}

@export var movement_speed = 100.0
@export var mode = MODE.PATROLLING
@export var patrol_points : Array[Vector2]
var patrol_idx = 0
@export var aggro_range = 64

func _physics_process(delta) -> void:
	match mode:
		MODE.PATROLLING when len(patrol_points)>0:
			if global_position.x<patrol_points[patrol_idx].x+5 and global_position.x>patrol_points[patrol_idx].x-5:
				patrol_idx+=1
				if patrol_idx >= len(patrol_points):
					patrol_idx = 0
			velocity = global_position.direction_to(patrol_points[patrol_idx]) * movement_speed
		MODE.AGGRESSIVE:
			velocity = global_position.direction_to(get_parent().get_node("Player").position) * movement_speed
	move_and_slide()
