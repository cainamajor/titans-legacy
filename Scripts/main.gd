extends Control

@onready var screen_create_product = $Screen_CreateProduct
@onready var screen_market = $Screen_Market


func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	GameData.load_game()
	show_create_product()

func show_create_product():
	screen_create_product.visible = true
	screen_market.visible = false


func show_market():
	screen_create_product.visible = false
	screen_market.visible = true
