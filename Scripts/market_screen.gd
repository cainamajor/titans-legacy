extends Panel

@onready var product_list = $VBoxContainer/ProductList

func refresh_list():
	product_list.clear()
	for product in GameData.products:
		product_list.add_item(
			product["name"] + " | " +
			product["type"] + " | " +
			product["package"] + " | " +
			product["size"]
		)
