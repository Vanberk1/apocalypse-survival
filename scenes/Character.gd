extends KinematicBody2D

signal death

const AttackArea = preload("res://scenes/AttackArea.tscn")

export (String, "none", "player 1", "player 2") var player_controller

export var acceleration = 900
export var max_speed = 90
export var friction = 0.25
export var air_friction = 0.02
export var gravity = 250
export var jump_force = 150
var jump_number = 0
var jumpWall = 150
var wallJump = 60

var can_attack = true

var direction = Vector2.RIGHT
var motion = Vector2.ZERO
var x_input

onready var sprite = $AnimatedSprite

func _ready():
	print(player_controller)
	if player_controller == "player 2":
		sprite.modulate = Color(1, 0, 0)

func _physics_process(delta):
	if player_controller == "player 1":
		x_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	else:
		x_input = Input.get_action_strength("right_2") - Input.get_action_strength("left_2")
	
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
		if player_controller == "player 1":
			if Input.is_action_just_pressed("up") and jump_number > 0:
				motion.y = -jump_force
				jump_number -= 1
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
			if Input.is_action_just_pressed("up_2") and jump_number > 0:
				motion.y = -jump_force
				jump_number -= 1
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
		if player_controller == "player 1":
			if Input.is_action_just_released("up") && motion.y < -jump_force / 2:
				motion.y = -jump_force / 2
			if !x_input:
				motion.x = lerp(motion.x, 0, air_friction)
		else:
			if Input.is_action_just_released("up_2") && motion.y < -jump_force / 2:
				motion.y = -jump_force / 2
			if !x_input:
				motion.x = lerp(motion.x, 0, air_friction)
	if player_controller == "player 1":
		if Input.is_action_just_pressed("dash"):
			dash()
		if Input.is_action_just_pressed("attack") && can_attack:
			attack()
	else:
		if Input.is_action_just_pressed("dash_2"):
			dash()
		if Input.is_action_just_pressed("attack_2") && can_attack:
			attack()
	
	motion = move_and_slide(motion, Vector2.UP)

func nextToWall():
	return nextToRightWall() or nextToLeftWall()
	
func nextToRightWall():
	return $RightWall.is_colliding()
	
func nextToLeftWall():
	return $LeftWall.is_colliding()
	
func dash():
	max_speed = 1700
	$Timer.start()

func attack():
	sprite.play("attack")
	var new_attack = AttackArea.instance()
	new_attack.dir = direction
	add_child(new_attack)
	new_attack.global_position = global_position + direction * 14
	can_attack = false
	$AttackTimer.start()
#	print("attack", direction)

func death():
	emit_signal("death", player_controller)
	queue_free()

func _on_Timer_timeout():
	max_speed = 90

func _on_AttackTimer_timeout():
	can_attack = true
