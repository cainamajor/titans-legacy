extends Node

var products = []

const SAVE_PATH = "user://save_game.json"


func save_game():

	var save_data = {
		"products": products
	}

	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	file.store_string(JSON.stringify(save_data))

	file.close()

	print("JOGO SALVO")


func load_game():

	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)

	var content = file.get_as_text()

	file.close()

	var data = JSON.parse_string(content)

	if data != null:
		products = data["products"]

	print("JOGO CARREGADO")
