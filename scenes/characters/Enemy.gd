extends KinematicBody2D

signal death

const AttackArea = preload("res://scenes/attacks/AttackArea.tscn")

export (String, "none", "enemy 1", "enemy 2") var player_controller

export var acceleration = 900
export var max_speed = 50
export var friction = 0.25
export var air_friction = 0.02
export var gravity = 500
export var jump_force = 200
var jump_number = 0
var jumpWall = 150
var wallJump = 60

var can_attack = true
var dashing = false

var direction = Vector2.RIGHT
var motion = Vector2.ZERO
var x_input = 0

var attack_range = 16
var vision_rad = 150
var reaction_time = 300
var next_dir = 0
var next_dir_time = 0

onready var sprite = $AnimatedSprite
onready var wall_detector = $WallDetector
onready var floor_detector = $FloorDetector

func _ready():
	sprite.modulate = Color(0, 1, 0)

func _physics_process(delta):
	var target = get_target()
	if target:
		var dis_to_target = distance_to_target(target.global_position)
		if dis_to_target <= vision_rad:
			if target.global_position.x > global_position.x + attack_range:
				x_input = 1
				wall_detector.cast_to = Vector2(0, -16)
				floor_detector.position.x = 10
			elif target.global_position.x < global_position.x - attack_range:
				x_input = -1
				wall_detector.cast_to = Vector2(0, 16)
				floor_detector.position.x = -10
			else:
				x_input = 0
	else:
		x_input = 0
		
	if x_input < 0:
		sprite.flip_h = true
		direction = Vector2.LEFT
	elif x_input > 0:
		sprite.flip_h = false
		direction = Vector2.RIGHT
		
	if x_input:
		motion.x += x_input * acceleration * delta
		motion.x = clamp(motion.x, -max_speed, max_speed)
		sprite.play("run")
	else:
		sprite.play("idle")
		
	motion.y += gravity * delta
	
	
	if is_on_floor() or nextToWall():
		jump_number = 2
		if target:
			var dis_to_target = distance_to_target(target.global_position)
			if dis_to_target <= vision_rad:
				if target.global_position.y < global_position.y - 16 and jump_number > 0:
					if wall_detector.is_colliding() || !floor_detector.is_colliding():
						motion.y = -jump_force
						jump_number -= 1
						print("on floor ", motion)
					if not is_on_floor() and nextToRightWall():
						motion.x -= wallJump * delta
						motion.y -= jumpWall * delta
					if not is_on_floor() and nextToLeftWall():
						motion.x += wallJump * delta 
						motion.y -= jumpWall * delta
				if nextToWall() and motion.y > 30:
					motion.y = 30 * delta
					if nextToRightWall():
						sprite.flip_h = true
		#				sprite.play("slideWall")
					elif nextToLeftWall():
						sprite.flip_h = false
		#				sprite.play("slideWall")
		if !x_input:
			motion.x = lerp(motion.x, 0, friction)
	else:
#		if target:
#			if target.global_position.y > global_position.y + 16 && motion.y < -jump_force / 2:
#				motion.y = -jump_force / 2
		if !x_input:
			motion.x = lerp(motion.x, 0, air_friction)
#	if Input.is_action_just_pressed("dash"):
#		dash()
	if target:
		var dis_to_target = distance_to_target(target.global_position)
		if dis_to_target <= attack_range && can_attack:
			attack()
		
	motion = move_and_slide(motion, Vector2.UP)

func distance_to_target(target_pos: Vector2):
	return target_pos.distance_to(global_position)

func get_target():
	var characters = get_parent().get_children()
	var targets = []
	var near_target = null
	for charc in characters:
		if charc.player_controller != player_controller:
			targets.append(charc)
	if targets.size() > 0:
		near_target = targets[0]
		for i in range(1, targets.size()):
			if distance_to_target(targets[i].global_position) <= distance_to_target(near_target.global_position):
				near_target = targets[i]
	return near_target

func nextToWall():
	return nextToRightWall() or nextToLeftWall()
	
func nextToRightWall():
	return $RightWall.is_colliding()
	
func nextToLeftWall():
	return $LeftWall.is_colliding()
	
func dash():
	max_speed = 1700
	dashing = true
	$DashTimer.start()

func attack():
	sprite.play("attack")
	var new_attack = AttackArea.instance()
	new_attack.dir = direction
	new_attack.character_controller = player_controller
	add_child(new_attack)
	new_attack.global_position = global_position + direction * 14
	can_attack = false
	$AttackTimer.start()
#	print("attack", direction)

func death(killer_controller):
	if !dashing:
		emit_signal("death", player_controller, killer_controller)
		queue_free()

func _on_DashTimer_timeout():
	max_speed = 90
	dashing = false

func _on_AttackTimer_timeout():
	can_attack = true
