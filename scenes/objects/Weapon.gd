extends Area2D

export(String, "none", "punch", "knife", "pipe") var weapon_type

func _on_Weapon_body_entered(body):
	print(body)
	if body.is_in_group("character") || body.is_in_group("enemy"):
		body.set_weapon(weapon_type)
		queue_free()
