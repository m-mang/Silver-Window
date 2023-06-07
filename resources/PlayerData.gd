extends Resource
class_name PlayerData

@export var game_script_index = 0
@export var text_line_height = 0

func change_index(value : int):
	game_script_index = value


func change_line_height(value : float):
	text_line_height = value

