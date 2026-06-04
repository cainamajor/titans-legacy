extends Panel

# --- Referências existentes ---
@onready var inp_product_name = $VBCCriacaoProduto/Inp_ProductName
@onready var dd_category = $VBCCriacaoProduto/Dd_Category
@onready var dd_type = $VBCCriacaoProduto/Dd_Type
@onready var dd_package = $VBCCriacaoProduto/Dd_Package
@onready var dd_size = $VBCCriacaoProduto/Dd_Size

# NOVO: referências para os grids de cards
@onready var grid_available = $HBComponents/VBoxAvailable/ScrollAvailable/GridAvailable
@onready var grid_selected = $HBComponents/VBoxSelected/ScrollSelected/GridSelected

# Cena do card
const CARD_SCENE = preload("res://Scenes/component_card.tscn")

var components_data = []
var product_data = {}
var types_packages_data = {}
var brands_data = {}
var main_names_data = {}

# Rastreia quais componentes foram selecionados (por id)
var selected_ids: Array = []


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


# --- CARREGAMENTO DE JSONs (idêntico ao original) ---

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
		return
	var json = JSON.new()
	json.parse(file.get_as_text())
	file.close()
	product_data = json.data


func load_types_packages():
	var file = FileAccess.open("res://Data/product_types_packages.json", FileAccess.READ)
	if file == null:
		return
	var json = JSON.new()
	json.parse(file.get_as_text())
	file.close()
	types_packages_data = json.data


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


# --- DROPDOWNS (idêntico ao original) ---

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


# --- COMPONENTES: nova lógica com cards ---

# Limpa e reconstrói o grid de disponíveis com base em um array filtrado
func _populate_grid_available(filtered: Array) -> void:
	for child in grid_available.get_children():
		child.queue_free()

	for component in filtered:
		# Não mostra o que já foi selecionado
		if component["id"] in selected_ids:
			continue

		var card = CARD_SCENE.instantiate()
		grid_available.add_child(card)
		card.setup(component)

		# Clique no card: move para selecionados
		card.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_select_component(component)
		)


func _populate_grid_selected() -> void:
	for child in grid_selected.get_children():
		child.queue_free()

	for sel_id in selected_ids:
		var component = _find_component_by_id(sel_id)
		if component.is_empty():
			continue

		var card = CARD_SCENE.instantiate()
		grid_selected.add_child(card)
		card.setup(component)

		# Clique no card selecionado: remove da seleção
		card.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_deselect_component(sel_id)
		)


func _select_component(component: Dictionary) -> void:
	if component["id"] in selected_ids:
		return
	selected_ids.append(component["id"])
	_refresh_both_grids()


func _deselect_component(comp_id: String) -> void:
	selected_ids.erase(comp_id)
	_refresh_both_grids()


func _refresh_both_grids() -> void:
	# Repopula disponíveis com o filtro ativo atual
	var tipo_atual = dd_type.get_item_text(dd_type.selected)
	var filtered = components_data.filter(func(c): return tipo_atual in c["compatible_types"])
	_populate_grid_available(filtered)
	_populate_grid_selected()


func _find_component_by_id(comp_id: String) -> Dictionary:
	for c in components_data:
		if c["id"] == comp_id:
			return c
	return {}


func fill_components(categoria: String) -> void:
	selected_ids.clear()
	var filtered = components_data.filter(func(c): return categoria in c["product_categories"])
	_populate_grid_available(filtered)
	_populate_grid_selected()


func fill_components_by_type(tipo: String) -> void:
	selected_ids.clear()
	var filtered = components_data.filter(func(c): return tipo in c["compatible_types"])
	_populate_grid_available(filtered)
	_populate_grid_selected()


# --- BOTÕES ADD/REMOVE (mantidos por compatibilidade, mas o clique no card já faz isso) ---

func _on_btn_add_pressed() -> void:
	pass  # Substituído pelo clique no card


func _on_btn_remove_pressed() -> void:
	pass  # Substituído pelo clique no card


# --- CRIAÇÃO (idêntico ao original, adaptado para selected_ids) ---

func _on_btn_create_pressed():
	var product_name = inp_product_name.text.strip_edges()
	if product_name == "":
		print("Nome do produto vazio")
		return

	var selected_components = []
	for sel_id in selected_ids:
		var comp = _find_component_by_id(sel_id)
		if not comp.is_empty():
			selected_components.append(comp["name"])

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

	var market = get_node_or_null("/root/Main/Screen_Market")
	if market:
		market.refresh_list()

	inp_product_name.text = ""
	selected_ids.clear()
	var tipo_atual = dd_type.get_item_text(dd_type.selected)
	fill_components_by_type(tipo_atual)
	print("Produto criado: ", new_product["name"])


# --- NOME ALEATÓRIO

func _on_btn_random_name_pressed() -> void:
	if dd_type.selected == -1:
		return
	var marca = brands_data["brands"].pick_random()
	var nome_principal = main_names_data["main_names"].pick_random()
	var tipo = dd_type.get_item_text(dd_type.selected)
	inp_product_name.text = marca + " " + nome_principal + " " + tipo
