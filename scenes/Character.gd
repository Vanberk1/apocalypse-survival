extends KinematicBody2D

export var acceleration = 900
export var max_speed = 90
export var friction = 0.25
export var air_friction = 0.02
export var gravity = 250
export var jump_force = 150

var motion = Vector2.ZERO

onready var sprite = $AnimatedSprite

func _physics_process(delta):
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if x_input < 0:
		sprite.flip_h = true
	elif x_input > 0:
		sprite.flip_h = false
	
	if x_input:
		motion.x += x_input * acceleration * delta
		motion.x = clamp(motion.x, -max_speed, max_speed)
		sprite.play("run")
	else:
		sprite.play("idle")
	
	motion.y += gravity * delta
	
	if is_on_floor():
		if Input.is_action_just_pressed("ui_up"):
			motion.y = -jump_force
		if !x_input:
			motion.x = lerp(motion.x, 0, friction)
	else:
		if Input.is_action_just_released("ui_up") && motion.y < -jump_force / 2:
			motion.y = -jump_force / 2
		if !x_input:
			motion.x = lerp(motion.x, 0, air_friction)
	motion = move_and_slide(motion, Vector2.UP)
