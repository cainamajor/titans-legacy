extends Panel

# --- Referências existentes ---
@onready var inp_product_name = $VBCCriacaoProduto/Inp_ProductName
@onready var dd_category      = $VBCCriacaoProduto/Dd_Category
@onready var dd_type          = $VBCCriacaoProduto/Dd_Type
@onready var dd_package       = $VBCCriacaoProduto/Dd_Package
@onready var dd_size          = $VBCCriacaoProduto/Dd_Size

@onready var grid_available = $HBComponents/VBoxAvailable/ScrollAvailable/GridAvailable
@onready var grid_selected  = $HBComponents/VBoxSelected/ScrollSelected/GridSelected

# --- Referências do painel de preview ---
# Estes nós devem existir dentro do Panel "Visualização conteúdo do produto"
# Veja o guia de nós abaixo para criar no editor
@onready var preview_panel        = $Panel
@onready var preview_name       = $Panel/MarginContainer/VBoxContainer/LblPreviewName
@onready var preview_category   = $Panel/MarginContainer/VBoxContainer/BadgeRow/LblCategory
@onready var preview_type       = $Panel/MarginContainer/VBoxContainer/BadgeRow/LblType
@onready var preview_package    = $Panel/MarginContainer/VBoxContainer/BadgeRow/LblPackage
@onready var preview_size       = $Panel/MarginContainer/VBoxContainer/BadgeRow/LblSize
@onready var preview_components = $Panel/MarginContainer/VBoxContainer/LblComponents
@onready var preview_cost       = $Panel/MarginContainer/VBoxContainer/RowCost/LblCostValue
@onready var preview_quality    = $Panel/MarginContainer/VBoxContainer/RowQuality/LblQualityValue
@onready var preview_empty      = $Panel/MarginContainer/VBoxContainer/LblEmpty

const CARD_SCENE = preload("res://Scenes/component_card.tscn")

var components_data    = []
var product_data       = {}
var types_packages_data = {}
var brands_data        = {}
var main_names_data    = {}
var selected_ids: Array = []

# Cores para badges
const COR_BADGE_BG   := Color(0.918, 0.953, 0.871, 1.0)
const COR_BADGE_TEXT := Color(0.231, 0.427, 0.067, 1.0)
const COR_CUSTO_TEXT := Color(0.114, 0.114, 0.122, 1.0)
const COR_MUTED      := Color(0.431, 0.431, 0.451, 1.0)


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

	# Conecta o campo de nome para atualizar preview ao digitar
	inp_product_name.text_changed.connect(_on_name_changed)

	_update_preview()
	print("preview_name: ", preview_name)
	print("preview_cost: ", preview_cost)
	print("preview_empty: ", preview_empty)
	print("Filhos de Screen_CreateProduct:")
	for child in get_children():
		print("  ", child.name, " (", child.get_class(), ")")
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
	_update_preview()

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
	_update_preview()

func _on_dd_package_item_selected(index: int) -> void:
	var tipo    = dd_type.get_item_text(dd_type.selected)
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
	_update_preview()


# --- COMPONENTES ---

func _populate_grid_available(filtered: Array) -> void:
	for child in grid_available.get_children():
		child.queue_free()
	for component in filtered:
		if component["id"] in selected_ids:
			continue
		var card = CARD_SCENE.instantiate()
		grid_available.add_child(card)
		card.setup(component)
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
		card.set_selected(true)
		card.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_deselect_component(sel_id)
		)

func _select_component(component: Dictionary) -> void:
	if component["id"] in selected_ids:
		return
	selected_ids.append(component["id"])
	_refresh_both_grids()
	_update_preview()

func _deselect_component(comp_id: String) -> void:
	selected_ids.erase(comp_id)
	_refresh_both_grids()
	_update_preview()

func _refresh_both_grids() -> void:
	var tipo_atual = dd_type.get_item_text(dd_type.selected)
	var filtered   = components_data.filter(func(c): return tipo_atual in c["compatible_types"])
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


# --- PREVIEW DO PRODUTO ---
# Atualiza o painel de visualização em tempo real

func _on_name_changed(_new_text: String) -> void:
	_update_preview()

func _update_preview() -> void:
	# Verifica se os nós do preview existem
	if not preview_name:
		return

	var nome      = inp_product_name.text.strip_edges() if inp_product_name else ""
	var categoria = dd_category.get_item_text(dd_category.selected) if dd_category.selected >= 0 else ""
	var tipo      = dd_type.get_item_text(dd_type.selected) if dd_type.selected >= 0 else ""
	var embalagem = dd_package.get_item_text(dd_package.selected) if dd_package.selected >= 0 else ""
	var tamanho   = dd_size.get_item_text(dd_size.selected) if dd_size.selected >= 0 else ""

	var tem_dados = nome != "" or selected_ids.size() > 0

	# Mostra/esconde estado vazio
	if preview_empty:
		preview_empty.visible = not tem_dados

	# Nome do produto
	preview_name.text = nome if nome != "" else "Sem nome"
	preview_name.add_theme_color_override("font_color",
		COR_CUSTO_TEXT if nome != "" else COR_MUTED)

	# Badges de categoria/tipo/embalagem/tamanho
	if preview_category:
		preview_category.text = categoria
	if preview_type:
		preview_type.text = tipo
	if preview_package:
		preview_package.text = embalagem
	if preview_size:
		preview_size.text = tamanho

	# Lista de componentes selecionados
	if preview_components:
		if selected_ids.is_empty():
			preview_components.text = "Nenhum componente selecionado"
			preview_components.add_theme_color_override("font_color", COR_MUTED)
		else:
			var linhas = []
			for sel_id in selected_ids:
				var comp = _find_component_by_id(sel_id)
				if not comp.is_empty():
					linhas.append("• " + comp["name"])
			preview_components.text = "\n".join(linhas)
			preview_components.add_theme_color_override("font_color", COR_CUSTO_TEXT)

	# Custo estimado (soma de base_cost dos selecionados)
	if preview_cost:
		var custo_total := 0.0
		for sel_id in selected_ids:
			var comp = _find_component_by_id(sel_id)
			if not comp.is_empty():
				custo_total += float(comp.get("base_cost", 0.0))
		preview_cost.text = "R$ %.2f" % custo_total

	# Qualidade média dos componentes selecionados
	if preview_quality:
		if selected_ids.is_empty():
			preview_quality.text = "—"
		else:
			var soma_qualidade := 0.0
			for sel_id in selected_ids:
				var comp = _find_component_by_id(sel_id)
				if not comp.is_empty():
					soma_qualidade += float(comp.get("quality", 50.0))
			var media = soma_qualidade / selected_ids.size()
			preview_quality.text = "%d / 100" % int(media)


# --- BOTÕES ---

func _on_btn_add_pressed() -> void:
	pass

func _on_btn_remove_pressed() -> void:
	pass

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
		"name":       product_name,
		"category":   dd_category.get_item_text(dd_category.selected),
		"type":       dd_type.get_item_text(dd_type.selected),
		"package":    dd_package.get_item_text(dd_package.selected),
		"size":       dd_size.get_item_text(dd_size.selected),
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
	_update_preview()

	print("Produto criado: ", new_product["name"])

func _on_btn_random_name_pressed() -> void:
	if dd_type.selected == -1:
		return
	var marca          = brands_data["brands"].pick_random()
	var nome_principal = main_names_data["main_names"].pick_random()
	var tipo           = dd_type.get_item_text(dd_type.selected)
	inp_product_name.text = marca + " " + nome_principal + " " + tipo
	_update_preview()
