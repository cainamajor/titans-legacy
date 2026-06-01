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
var types_packages_data = {}
var brands_data = {}
var main_names_data = {}


func _ready():
	load_components()
	load_product_data()
	load_types_packages()
	load_brands()
	load_main_names()

	dd_category.clear()
	for categoria in product_data.keys():
		dd_category.add_item(categoria)

	if dd_category.item_count > 0:
		dd_category.select(0)
		_on_dd_category_item_selected(0)


# --- CARREGAMENTO DE JSONs ---

func load_components():
	var file = FileAccess.open("res://Data/components_v1.json", FileAccess.READ)
	if file == null:
		print("Erro ao abrir components_v1.json")
		return
	var json = JSON.new()
	var result = json.parse(file.get_as_text())
	file.close()
	if result != OK:
		print("Erro ao parsear components_v1.json")
		return
	components_data = json.data
	print("Components carregados: ", components_data.size())


func load_product_data():
	var file = FileAccess.open("res://Data/product_categories.json", FileAccess.READ)
	if file == null:
		print("Erro ao abrir product_categories.json")
		return
	var json = JSON.new()
	var result = json.parse(file.get_as_text())
	file.close()
	if result != OK:
		print("Erro ao parsear product_categories.json")
		return
	product_data = json.data


func load_types_packages():
	var file = FileAccess.open("res://Data/product_types_packages.json", FileAccess.READ)
	if file == null:
		print("Erro ao abrir product_types_packages.json")
		return
	var json = JSON.new()
	var result = json.parse(file.get_as_text())
	file.close()
	if result != OK:
		print("Erro ao parsear product_types_packages.json")
		return
	types_packages_data = json.data
	print("Types/Packages carregados: ", types_packages_data.keys().size())


func load_brands():
	var file = FileAccess.open("res://Data/titans_legacy_brands_v1.json", FileAccess.READ)
	if file == null:
		return
	var json = JSON.new()
	json.parse(file.get_as_text())
	file.close()
	brands_data = json.data


func load_main_names():
	var file = FileAccess.open("res://Data/titans_legacy_main_names_v1.json", FileAccess.READ)
	if file == null:
		return
	var json = JSON.new()
	json.parse(file.get_as_text())
	file.close()
	main_names_data = json.data


# --- DROPDOWNS ---

func _on_dd_category_item_selected(index: int) -> void:
	var categoria = dd_category.get_item_text(index)

	dd_type.clear()
	dd_package.clear()
	dd_size.clear()

	if not product_data.has(categoria):
		return

	for item in product_data[categoria]["types"]:
		dd_type.add_item(item)

	if dd_type.item_count > 0:
		dd_type.select(0)
		_on_dd_type_item_selected(0)

	fill_components(categoria)


func _on_dd_type_item_selected(index: int) -> void:
	var tipo = dd_type.get_item_text(index)

	dd_package.clear()
	dd_size.clear()

	if not types_packages_data.has(tipo):
		return

	var packages = types_packages_data[tipo]["packages"]

	for pkg in packages.keys():
		dd_package.add_item(pkg)

	if dd_package.item_count > 0:
		dd_package.select(0)
		_on_dd_package_item_selected(0)

	fill_components_by_type(tipo)


func _on_dd_package_item_selected(index: int) -> void:
	var tipo = dd_type.get_item_text(dd_type.selected)
	var package = dd_package.get_item_text(index)

	dd_size.clear()

	if not types_packages_data.has(tipo):
		return

	var packages = types_packages_data[tipo]["packages"]

	if not packages.has(package):
		return

	for size in packages[package]:
		dd_size.add_item(size)

	if dd_size.item_count > 0:
		dd_size.select(0)


# --- COMPONENTES ---

func fill_components(categoria: String) -> void:
	item_available.clear()
	item_selected.clear()

	for component in components_data:
		if categoria in component["product_categories"]:
			item_available.add_item(component["name"])


func fill_components_by_type(tipo: String) -> void:
	item_available.clear()
	item_selected.clear()

	for component in components_data:
		if tipo in component["compatible_types"]:
			item_available.add_item(component["name"])


func _on_btn_add_pressed() -> void:
	var selected = item_available.get_selected_items()
	if selected.is_empty():
		return

	var text = item_available.get_item_text(selected[0])

	# Bloqueia duplicado
	for i in range(item_selected.item_count):
		if item_selected.get_item_text(i) == text:
			return

	item_selected.add_item(text)


func _on_btn_remove_pressed() -> void:
	var selected = item_selected.get_selected_items()
	if selected.is_empty():
		return
	item_selected.remove_item(selected[0])


# --- CRIAÇÃO ---

func _on_btn_create_pressed():
	var product_name = inp_product_name.text.strip_edges()

	if product_name == "":
		print("Nome do produto vazio")
		return

	var selected_components = []
	for i in range(item_selected.item_count):
		selected_components.append(item_selected.get_item_text(i))

	var new_product = {
		"name": product_name,
		"category": dd_category.get_item_text(dd_category.selected),
		"type": dd_type.get_item_text(dd_type.selected),
		"package": dd_package.get_item_text(dd_package.selected),
		"size": dd_size.get_item_text(dd_size.selected),
		"components": selected_components
	}

	GameData.products.append(new_product)
	GameData.save_game()

	# Atualiza mercado
	var market = get_node_or_null("/root/Main/Screen_Market")
	if market:
		market.refresh_list()

	# Limpa formulário
	inp_product_name.text = ""
	item_selected.clear()
	var tipo_atual = dd_type.get_item_text(dd_type.selected)
	fill_components_by_type(tipo_atual)

	print("Produto criado: ", new_product["name"])


# --- NOME ALEATÓRIO ---

func _on_btn_random_name_pressed() -> void:
	if dd_type.selected == -1:
		return
	var marca = brands_data["brands"].pick_random()
	var nome_principal = main_names_data["main_names"].pick_random()
	var tipo = dd_type.get_item_text(dd_type.selected)
	inp_product_name.text = marca + " " + nome_principal + " " + tipo
