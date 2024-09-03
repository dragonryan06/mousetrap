extends CharacterBody2D

enum MODE {
	PATROLLING, # walks back and forth, looking for player
	AGGRESSIVE # pursues player
}

@export var movement_speed = 100.0
@export var mode = MODE.PATROLLING
@export var patrol_points : Array[Vector2]
var patrol_idx = 0 :
	set(new):
		if new >= len(patrol_points):
			new = 0
		patrol_idx = new
@export var aggro_range = 64
var direction = Vector2(0,0)

func _physics_process(delta) -> void:
	match mode:
		MODE.PATROLLING when len(patrol_points)>0:
			if global_position.x<patrol_points[patrol_idx].x+5 and global_position.x>patrol_points[patrol_idx].x-5:
				patrol_idx+=1
			direction = global_position.direction_to(patrol_points[patrol_idx])
			if !$CliffScanRight.is_colliding() and direction.x>0 and is_on_floor():
				velocity.x = 0
				patrol_idx+=1
			elif !$CliffScanLeft.is_colliding() and direction.x<0 and is_on_floor():
				velocity.x = 0
				patrol_idx+=1
			else:
				if ($WallScanLeft.is_colliding() and direction.x<0) or ($WallScanRight.is_colliding() and direction.x>0):
					velocity.y-=100;
				velocity.x = (direction.x * movement_speed)
		MODE.AGGRESSIVE:
			velocity = global_position.direction_to(get_parent().get_node("Player").position) * movement_speed
	velocity.y += get_gravity().y*delta
	move_and_slide()
