extends Node2D

const Character = preload("res://scenes/characters/Character.tscn")
const Enemy = preload("res://scenes/characters/Enemy.tscn")

var rng = RandomNumberGenerator.new()

var characters_scores = {}

onready var characters = $Characters
onready var spawn_points = $SpawnPoints.get_children()

func _ready():
	rng.randomize()
	for charc in characters.get_children():
		characters_scores[charc.player_controller] = 0
		var spawn_index = rng.randi_range(0, spawn_points.size() - 1)
		charc.global_position = spawn_points[spawn_index].global_position
		charc.connect("death", self, "_on_character_death")
	$HUD.set_characters(characters.get_children())

func respawn_character(controller):
	yield(get_tree().create_timer(2.0), "timeout")
	var new_char
	if controller == "player 1" || controller == "player 2":
		new_char = Character.instance()
	elif controller == "enemy 1" || controller == "enemy 2":
		new_char = Enemy.instance()
	new_char.player_controller = controller
	var spawn_index = rng.randi_range(0, spawn_points.size() - 1)
	new_char.global_position = spawn_points[spawn_index].global_position
	new_char.connect("death", self, "_on_character_death")
	characters.add_child(new_char)

func _on_character_death(controller, killer_controller):
	print(killer_controller, " kills ", controller)
	respawn_character(controller)
	$HUD.character_point(killer_controller)
