extends Panel

@onready var product_list = $VBoxContainer/ProductList


func _process(delta):

	if product_list == null:
		return

	product_list.clear()

	for product in GameData.products:

		product_list.add_item(
			product["name"] + " | " +
			product["type"] + " | " +
			product["package"] + " | " +
			product["size"]
		)
