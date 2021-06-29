extends CanvasLayer

onready var scores_label = $ScoresLabel

var characters_scores = {}

func set_characters(characters):
	if characters.size() > 0:
		for charc in characters:
			characters_scores[charc.player_controller] = 0
		update_scores()

func character_point(controller):
	characters_scores[controller] += 1
	update_scores()

func update_scores():
	var score_text = ""
	var scores = characters_scores.keys()
	for c in scores:
		score_text += c + " - " + str(characters_scores[c]) + "  "
	scores_label.text = score_text
