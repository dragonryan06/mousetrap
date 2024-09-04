extends CharacterBody2D

enum MODE {
	PATROLLING, # walks back and forth, looking for player
	AGGRESSIVE # pursues player
}

@export var movement_speed = 100.0
@export var jump_speed = 500.0
@export var mode = MODE.PATROLLING
@export var patrol_points : Array[Vector2]
var patrol_idx = 0 :
	set(new):
		if new >= len(patrol_points):
			new = 0
		patrol_idx = new
@export var aggro_range = 64
@export var aggro_timeout = 2
var direction = Vector2(0,0)

var last_jump_x = INF
var player = null

func _ready():
	$AggroTimeout.wait_time = aggro_timeout
	$AggroTimeout.timeout.connect(set.bind("mode",MODE.PATROLLING))

func _physics_process(delta) -> void:
	
	if is_instance_valid(player):
		$Eyes.target_position = player.global_position-$Eyes.global_position
		if $Eyes.get_collider() == player:
			mode = MODE.AGGRESSIVE
	else:
		$Eyes.target_position = $Eyes.position
	
	match mode:
		MODE.PATROLLING when len(patrol_points)>0:
			$DebugModeLabel.text = "MODE.PATROLLING"
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
				if is_on_floor() and ($WallScanLeft.is_colliding() and direction.x<0) or ($WallScanRight.is_colliding() and direction.x>0):
					if last_jump_x != position.x:
						velocity.y = -jump_speed
						last_jump_x = position.x
					else:
						patrol_idx += 1
				velocity.x = (direction.x * movement_speed)
		MODE.AGGRESSIVE:
			$DebugModeLabel.text = "MODE.AGGRESSIVE"
			# if the player is out of sight, start a callback to resume patrolling, if we catch sight again during our wait, keep chasing!
			if (not is_instance_valid(player) or $Eyes.get_collider() != player) and $AggroTimeout.is_stopped():
				$AggroTimeout.start()
			elif (is_instance_valid(player) and $Eyes.get_collider() == player):
				if not $AggroTimeout.is_stopped():
					$AggroTimeout.stop()
					$AggroTimeout.wait_time = aggro_timeout
				velocity = global_position.direction_to(get_parent().get_node("Player").position) * movement_speed
		_:
			$DebugModeLabel.text = "???"
	velocity.y += get_gravity().y*delta
	move_and_slide()

func _on_aggro_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body

func _on_aggro_area_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player = null
