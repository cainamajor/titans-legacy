extends Panel

@onready var inp_product_name = $VBCCriacaoProduto/Inp_ProductName
@onready var dd_category = $VBCCriacaoProduto/Dd_Category
@onready var dd_type = $VBCCriacaoProduto/Dd_Type
@onready var dd_package = $VBCCriacaoProduto/Dd_Package
@onready var dd_size = $VBCCriacaoProduto/Dd_Size
@onready var item_available = $HBComponents/VBoxAvailable/ItemList_Available
@onready var item_selected = $HBComponents/VBoxSelected/ItemList_Selected

var components_data = []
var product_data = {}
var brands_data = {}
var main_names_data = {}


func _on_btn_create_pressed():
	
	var selected_components = []

	for i in range(item_selected.item_count):
		selected_components.append(item_selected.get_item_text(i)
	)
	
	var product_name = inp_product_name.text
	var product_category = dd_category.get_item_text(dd_category.selected)
	var product_type = dd_type.get_item_text(dd_type.selected)
	var package_type = dd_package.get_item_text(dd_package.selected)
	var size = dd_size.get_item_text(dd_size.selected)

	var new_product = {
	"name": product_name,
	"type": product_type,
	"package": package_type,
	"size": size,
	"components": selected_components
}

	GameData.products.append(new_product)
	GameData.save_game()
	print(GameData.products)


func fill_components():

	item_available.clear()

	for component in components_data:

		item_available.add_item(
			component["name"]
		)

func load_components():

	var file = FileAccess.open(
		"res://Data/components_v1.json",
		FileAccess.READ
	)

	if file == null:
		print("Erro ao abrir components")
		return

	var json = JSON.new()

	var result = json.parse(file.get_as_text())

	file.close()

	if result != OK:
		print("Erro JSON")
		return

	components_data = json.data

	fill_components()
	print("Components carregados:", components_data.size())
	print(components_data)

func _on_dd_category_item_selected(index: int) -> void:

	var categoria = dd_category.get_item_text(index)

	dd_type.clear()
	dd_package.clear()
	dd_size.clear()

	for item in product_data[categoria]["types"]:
		dd_type.add_item(item)

	for item in product_data[categoria]["packages"]:
		dd_package.add_item(item)

	for item in product_data[categoria]["sizes"]:
		dd_size.add_item(item)
		
				
func _ready():

	load_components()
	load_product_data()
	load_brands()
	load_main_names()

	dd_category.clear()

	for categoria in product_data.keys():
		dd_category.add_item(categoria)

	if dd_category.item_count > 0:
		dd_category.select(0)
		_on_dd_category_item_selected(0)

func load_product_data():

	
	var file = FileAccess.open(
		"res://Data/product_categories.json",
		FileAccess.READ
	)

	if file == null:
		print("Erro ao abrir JSON")
		return

	var json_text = file.get_as_text()

	file.close()

	var json = JSON.new()

	var result = json.parse(json_text)

	if result != OK:
		print("Erro ao ler JSON")
		return

	product_data = json.data
	print(product_data)

func load_brands():

	var file = FileAccess.open(
		"res://Data/titans_legacy_brands_v1.json",
		FileAccess.READ
	)

	if file == null:
		return

	var json = JSON.new()

	json.parse(file.get_as_text())

	file.close()

	brands_data = json.data

func load_main_names():

	var file = FileAccess.open(
		"res://Data/titans_legacy_main_names_v1.json",
		FileAccess.READ
	)

	if file == null:
		return

	var json = JSON.new()

	json.parse(file.get_as_text())

	file.close()

	main_names_data = json.data


func _on_btn_random_name_pressed() -> void:

	if dd_type.selected == -1:
		return

	var marca = brands_data["brands"].pick_random()
	var nome_principal = main_names_data["main_names"].pick_random()
	var tipo = dd_type.get_item_text(dd_type.selected)
	
	inp_product_name.text = marca + " " + nome_principal + " " + tipo


func _on_btn_add_pressed() -> void:
	var selected = item_available.get_selected_items()

	if selected.is_empty():
		return

	var idx = selected[0]

	var text = item_available.get_item_text(idx)

	item_selected.add_item(text)


func _on_btn_remove_pressed() -> void:
	var selected = item_selected.get_selected_items()

	if selected.is_empty():
		return

	item_selected.remove_item(selected[0])
