extends Panel

@onready var inp_product_name = $VBCCriacaoProduto/Inp_ProductName
@onready var dd_category      = $VBCCriacaoProduto/Dd_Category
@onready var dd_type          = $VBCCriacaoProduto/Dd_Type
@onready var dd_package       = $VBCCriacaoProduto/Dd_Package
@onready var dd_size          = $VBCCriacaoProduto/Dd_Size

@onready var grid_available = $VBoxComponents/VBoxAvailable/ScrollAvailable/GridAvailable
@onready var grid_selected  = $VBoxComponents/VBoxSelected/ScrollSelected/GridSelected

# Preview
@onready var preview_name       = $VBCCriacaoProduto/VBoxPreview/MarginContainer/VBoxContainer/LblPreviewName
@onready var preview_category   = $VBCCriacaoProduto/VBoxPreview/MarginContainer/VBoxContainer/BadgeRow/LblCategory
@onready var preview_type       = $VBCCriacaoProduto/VBoxPreview/MarginContainer/VBoxContainer/BadgeRow/LblType
@onready var preview_package    = $VBCCriacaoProduto/VBoxPreview/MarginContainer/VBoxContainer/BadgeRow/LblPackage
@onready var preview_size       = $VBCCriacaoProduto/VBoxPreview/MarginContainer/VBoxContainer/BadgeRow/LblSize
@onready var preview_components = $VBCCriacaoProduto/VBoxPreview/MarginContainer/VBoxContainer/LblComponents
@onready var preview_cost       = $VBCCriacaoProduto/VBoxPreview/MarginContainer/VBoxContainer/RowCost/LblCostValue
@onready var preview_quality    = $VBCCriacaoProduto/VBoxPreview/MarginContainer/VBoxContainer/RowQuality/LblQualityValue
@onready var preview_empty      = $VBCCriacaoProduto/VBoxPreview/MarginContainer/VBoxContainer/LblEmpty

# Slider de preço — adiciona estes nós dentro do VBoxContainer do preview:
# HSlider  (nome: SliderPrice)
# Label    (nome: LblPriceValue)
# Label    (nome: LblMargemValue)
# Label    (nome: LblVendaEstimada)
@onready var slider_price       = $VBCCriacaoProduto/VBoxPreview/MarginContainer/VBoxContainer/SliderPrice
@onready var lbl_price_value    = $VBCCriacaoProduto/VBoxPreview/MarginContainer/VBoxContainer/LblPriceValue
@onready var lbl_margem         = $VBCCriacaoProduto/VBoxPreview/MarginContainer/VBoxContainer/LblMargemValue
@onready var lbl_venda          = $VBCCriacaoProduto/VBoxPreview/MarginContainer/VBoxContainer/LblVendaEstimada

const CARD_SCENE = preload("res://Scenes/component_card.tscn")

var components_data      = []
var product_data         = {}
var types_packages_data  = {}
var brands_data          = {}
var main_names_data      = {}
var price_reference_data = {}

var selected_base:  Dictionary = {}
var selected_sabor: Dictionary = {}

# Preço atual definido pelo slider
var preco_venda: float = 0.0

const COR_TEXTO_ESCURO := Color(0.114, 0.114, 0.122, 1.0)
const COR_MUTED        := Color(0.431, 0.431, 0.451, 1.0)
const COR_VERDE        := Color(0.118, 0.620, 0.459, 1.0)
const COR_AMARELO      := Color(0.855, 0.647, 0.125, 1.0)
const COR_VERMELHO     := Color(0.820, 0.188, 0.188, 1.0)


func _ready():
	load_components()
	load_product_data()
	load_types_packages()
	load_brands()
	load_main_names()
	load_price_reference()

	dd_category.clear()
	for categoria in product_data.keys():
		dd_category.add_item(categoria)
	if dd_category.item_count > 0:
		dd_category.select(0)
		_on_dd_category_item_selected(0)

	inp_product_name.text_changed.connect(_on_name_changed)

	await get_tree().process_frame

	# Conecta o slider se existir
	if slider_price:
		slider_price.value_changed.connect(_on_slider_price_changed)

	_update_preview()


# --- CARREGAMENTO ---

func load_components():
	var file = FileAccess.open("res://Data/components_v1.json", FileAccess.READ)
	if file == null:
		return
	var json = JSON.new()
	json.parse(file.get_as_text())
	file.close()
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

func load_price_reference():
	var file = FileAccess.open("res://Data/price_reference.json", FileAccess.READ)
	if file == null:
		return
	var json = JSON.new()
	json.parse(file.get_as_text())
	file.close()
	price_reference_data = json.data


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
	selected_base  = {}
	selected_sabor = {}
	fill_components_by_type(tipo)
	_update_price_slider()
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

func fill_components_by_type(tipo: String) -> void:
	selected_base  = {}
	selected_sabor = {}
	var bases   = components_data.filter(func(c): return c["slot"] == "base"  and tipo in c["product_types"])
	var sabores = components_data.filter(func(c): return c["slot"] == "sabor" and tipo in c["product_types"])
	_populate_grids(bases, sabores)

func _populate_grids(bases: Array, sabores: Array) -> void:
	for child in grid_available.get_children():
		child.queue_free()
	for child in grid_selected.get_children():
		child.queue_free()

	for comp in bases:
		if selected_base.get("id","") == comp["id"]:
			continue
		var card = CARD_SCENE.instantiate()
		grid_available.add_child(card)
		card.setup(comp)
		card.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_select(comp, "base")
		)

	for comp in sabores:
		if selected_sabor.get("id","") == comp["id"]:
			continue
		var card = CARD_SCENE.instantiate()
		grid_available.add_child(card)
		card.setup(comp)
		card.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_select(comp, "sabor")
		)

	if not selected_base.is_empty():
		var card = CARD_SCENE.instantiate()
		grid_selected.add_child(card)
		card.setup(selected_base)
		card.set_selected(true)
		card.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_deselect("base")
		)

	if not selected_sabor.is_empty():
		var card = CARD_SCENE.instantiate()
		grid_selected.add_child(card)
		card.setup(selected_sabor)
		card.set_selected(true)
		card.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_deselect("sabor")
		)

func _select(comp: Dictionary, slot: String) -> void:
	if slot == "base":
		selected_base = comp
	else:
		selected_sabor = comp
	_refresh_grids()
	_update_price_slider()
	_update_preview()

func _deselect(slot: String) -> void:
	if slot == "base":
		selected_base = {}
	else:
		selected_sabor = {}
	_refresh_grids()
	_update_price_slider()
	_update_preview()

func _refresh_grids() -> void:
	var tipo    = dd_type.get_item_text(dd_type.selected)
	var bases   = components_data.filter(func(c): return c["slot"] == "base"  and tipo in c["product_types"])
	var sabores = components_data.filter(func(c): return c["slot"] == "sabor" and tipo in c["product_types"])
	_populate_grids(bases, sabores)

func _find_component_by_id(comp_id: String) -> Dictionary:
	for c in components_data:
		if c["id"] == comp_id:
			return c
	return {}


# --- SLIDER DE PREÇO ---

func _get_custo_total() -> float:
	return selected_base.get("base_cost", 0.0) + selected_sabor.get("base_cost", 0.0)

func _get_qualidade_media() -> float:
	if selected_base.is_empty():
		return 50.0
	var q_base  = float(selected_base.get("quality", 50))
	var q_sabor = float(selected_sabor.get("quality", 50)) if not selected_sabor.is_empty() else q_base
	return (q_base + q_sabor) / (2.0 if not selected_sabor.is_empty() else 1.0)

func _get_preco_ideal() -> float:
	# Preço ideal = referência da categoria ajustado pela qualidade
	# Qualidade 100 = teto_qualidade, qualidade 50 = preco_atacado_ref
	var tipo = dd_type.get_item_text(dd_type.selected) if dd_type.selected >= 0 else ""
	if not price_reference_data.has(tipo):
		return _get_custo_total() * 2.0
	var ref     = price_reference_data[tipo]
	var base    = float(ref["preco_atacado_ref"])
	var teto    = float(ref["teto_qualidade"])
	var quality = _get_qualidade_media() / 100.0
	# Interpola entre base e teto conforme qualidade
	return base + (teto - base) * quality

func _update_price_slider() -> void:
	if not slider_price:
		return
	var custo = _get_custo_total()
	var ideal = _get_preco_ideal()
	var teto  = ideal * 2.0  # teto do slider = 2x o preço ideal

	slider_price.min_value = custo
	slider_price.max_value = max(teto, custo * 3.0)
	slider_price.step      = 0.05

	# Posiciona o slider no preço ideal por padrão
	slider_price.value = ideal
	preco_venda = ideal

func _on_slider_price_changed(value: float) -> void:
	preco_venda = value
	_update_price_feedback()

func _update_price_feedback() -> void:
	var custo = _get_custo_total()
	var ideal = _get_preco_ideal()

	if lbl_price_value:
		lbl_price_value.text = "R$ %.2f" % preco_venda

	# Margem %
	var margem_pct := 0.0
	if custo > 0:
		margem_pct = ((preco_venda - custo) / custo) * 100.0

	if lbl_margem:
		lbl_margem.text = "Margem: %.0f%%" % margem_pct
		if preco_venda <= ideal:
			lbl_margem.add_theme_color_override("font_color", COR_VERDE)
		elif preco_venda <= ideal * 1.3:
			lbl_margem.add_theme_color_override("font_color", COR_AMARELO)
		else:
			lbl_margem.add_theme_color_override("font_color", COR_VERMELHO)

	# Estimativa de venda
	if lbl_venda:
		var visibilidade := 0.1  # começa baixa, cresce com marketing futuro
		var fator_preco: float = clamp(ideal / max(preco_venda, 0.01), 0.1, 1.0)		
		var fator_qual   := _get_qualidade_media() / 100.0
		var vendas_est   := int(100 * fator_preco * fator_qual * (1.0 + visibilidade))

		var texto_venda := ""
		var cor_venda   := COR_VERDE
		if vendas_est >= 70:
			texto_venda = "Venda estimada: Alta (%d un/dia)" % vendas_est
			cor_venda   = COR_VERDE
		elif vendas_est >= 30:
			texto_venda = "Venda estimada: Média (%d un/dia)" % vendas_est
			cor_venda   = COR_AMARELO
		else:
			texto_venda = "Venda estimada: Baixa (%d un/dia)" % vendas_est
			cor_venda   = COR_VERMELHO

		lbl_venda.text = texto_venda
		lbl_venda.add_theme_color_override("font_color", cor_venda)


# --- PREVIEW ---

func _on_name_changed(_text: String) -> void:
	_update_preview()

func _update_preview() -> void:
	if not preview_name:
		return

	var nome      = inp_product_name.text.strip_edges() if inp_product_name else ""
	var categoria = dd_category.get_item_text(dd_category.selected) if dd_category.selected >= 0 else ""
	var tipo      = dd_type.get_item_text(dd_type.selected) if dd_type.selected >= 0 else ""
	var embalagem = dd_package.get_item_text(dd_package.selected) if dd_package.selected >= 0 else ""
	var tamanho   = dd_size.get_item_text(dd_size.selected) if dd_size.selected >= 0 else ""
	var tem_dados = nome != "" or not selected_base.is_empty()

	if preview_empty:
		preview_empty.visible = not tem_dados

	preview_name.text = nome if nome != "" else "Sem nome"
	preview_name.autowrap_mode = TextServer.AUTOWRAP_WORD
	preview_name.add_theme_color_override("font_color", COR_TEXTO_ESCURO if nome != "" else COR_MUTED)

	if preview_category: preview_category.text = categoria
	if preview_type:     preview_type.text     = tipo
	if preview_package:  preview_package.text  = embalagem
	if preview_size:     preview_size.text     = tamanho

	if preview_components:
		var linhas = []
		if not selected_base.is_empty():
			linhas.append("Base: " + selected_base.get("name","") + " — " + selected_base.get("company",""))
		if not selected_sabor.is_empty():
			linhas.append("Sabor: " + selected_sabor.get("name","") + " — " + selected_sabor.get("company",""))
		if linhas.is_empty():
			preview_components.text = "Nenhum componente selecionado"
			preview_components.add_theme_color_override("font_color", COR_MUTED)
		else:
			preview_components.text = "\n".join(linhas)
			preview_components.add_theme_color_override("font_color", COR_TEXTO_ESCURO)

	if preview_cost:
		var custo = _get_custo_total()
		preview_cost.text = "R$ %.2f" % custo

	if preview_quality:
		if selected_base.is_empty():
			preview_quality.text = "—"
		else:
			preview_quality.text = "%d / 100" % int(_get_qualidade_media())

	_update_price_feedback()


# --- CRIAÇÃO ---

func _on_btn_create_pressed():
	var product_name = inp_product_name.text.strip_edges()
	if product_name == "":
		print("Nome vazio")
		return
	if selected_base.is_empty():
		print("Selecione um componente base")
		return

	var new_product = {
		"name":          product_name,
		"category":      dd_category.get_item_text(dd_category.selected),
		"type":          dd_type.get_item_text(dd_type.selected),
		"package":       dd_package.get_item_text(dd_package.selected),
		"size":          dd_size.get_item_text(dd_size.selected),
		"base":          selected_base.get("name",""),
		"base_company":  selected_base.get("company",""),
		"sabor":         selected_sabor.get("name",""),
		"sabor_company": selected_sabor.get("company",""),
		"cost":          _get_custo_total(),
		"quality":       int(_get_qualidade_media()),
		"price":         preco_venda
	}

	GameData.products.append(new_product)
	GameData.save_game()

	var market = get_node_or_null("/root/Main/Screen_Market")
	if market:
		market.refresh_list()

	inp_product_name.text = ""
	selected_base  = {}
	selected_sabor = {}
	var tipo_atual = dd_type.get_item_text(dd_type.selected)
	fill_components_by_type(tipo_atual)
	_update_preview()
	print("Produto criado: ", new_product["name"])

func _on_btn_add_pressed() -> void:
	pass

func _on_btn_remove_pressed() -> void:
	pass

func _on_btn_random_name_pressed() -> void:
	if dd_type.selected == -1:
		return
	var marca          = brands_data["brands"].pick_random()
	var nome_principal = main_names_data["main_names"].pick_random()
	var tipo           = dd_type.get_item_text(dd_type.selected)
	inp_product_name.text = marca + " " + nome_principal + " " + tipo
	_update_preview()
