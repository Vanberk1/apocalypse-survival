extends Area2D

var dir = Vector2.RIGHT

onready var sprite = $AttackAnimation

func _ready():
	if dir == Vector2.LEFT:
		sprite.flip_h = true
	sprite.play()

func _on_AttackAnimation_animation_finished():
	queue_free()

func _on_AttackArea_body_entered(body):
	print(body.name)
	if body.is_in_group("character"):
		body.death()
