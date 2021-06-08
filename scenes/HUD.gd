extends CanvasLayer

onready var scores = $Scores

var score_1 = 0
var score_2 = 0

func player_1_point():
	score_1 += 1
	scores.text = str(score_1) + " - " + str(score_2)

func player_2_point():
	score_2 += 1
	scores.text = str(score_1) + " - " + str(score_2)
