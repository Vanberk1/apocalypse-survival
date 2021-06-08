extends Node2D

const Character = preload("res://scenes/Character.tscn")

onready var characters = $Characters
onready var spawn_point = $SpawnPoint

func _ready():
	for charc in characters.get_children():
		charc.connect("death", self, "_on_character_death")

func _on_character_death(controller):
	print(controller)
	if controller == "player 1":
		$RespawnTimer1.start()
		$HUD.player_2_point()
	else:
		$RespawnTimer2.start()
		$HUD.player_1_point()

func _on_RespawnTimer_timeout():
	var new_char = Character.instance()
	new_char.player_controller = "player 1"
	new_char.global_position = spawn_point.global_position
	new_char.connect("death", self, "_on_character_death")
	characters.add_child(new_char)

func _on_RespawnTimer2_timeout():
	var new_char = Character.instance()
	new_char.player_controller = "player 2"
	new_char.global_position = spawn_point.global_position
	new_char.connect("death", self, "_on_character_death")
	characters.add_child(new_char)
