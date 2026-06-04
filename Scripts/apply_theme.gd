@tool
extends Control

# ============================================================
# apply_theme.gd — Titan's Legacy
# Como usar:
#   1. Coloca este arquivo em res://Scripts/apply_theme.gd
#   2. Seleciona o nó Main no editor
#   3. No Inspector > Script > troca para apply_theme.gd
#   4. Salva a cena (Ctrl+S) — os estilos são aplicados e gravados
#   5. Volta o script main.gd no nó Main
# ============================================================

const COR_FUNDO        := Color(0.960, 0.960, 0.969, 1.0)
const COR_PANEL_BRANCO := Color(1.0,   1.0,   1.0,   1.0)
const COR_BORDA        := Color(0.878, 0.878, 0.878, 1.0)
const COR_TEXTO_ESCURO := Color(0.114, 0.114, 0.122, 1.0)
const COR_TEXTO_MUTED  := Color(0.431, 0.431, 0.451, 1.0)
const COR_BTN_PRIMARY  := Color(0.114, 0.114, 0.122, 1.0)
const COR_INPUT_FUNDO  := Color(0.980, 0.980, 0.984, 1.0)


func _ready() -> void:
	_style_topbar()
	_style_sidebar_botoes()
	_style_screen_create_product()
	_style_inputs_dropdowns()
	_style_btn_create()
	_style_screen_market()
	_style_screen_components()
	print("[apply_theme] Tema aplicado.")


func _make_sb(cor: Color, raio: int = 0, borda: bool = false) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = cor
	if raio > 0:
		sb.corner_radius_top_left     = raio
		sb.corner_radius_top_right    = raio
		sb.corner_radius_bottom_left  = raio
		sb.corner_radius_bottom_right = raio
	if borda:
		sb.border_width_left   = 1
		sb.border_width_right  = 1
		sb.border_width_top    = 1
		sb.border_width_bottom = 1
		sb.border_color        = COR_BORDA
	return sb


func _style_topbar() -> void:
	var topbar := get_node_or_null("TopBar")
	if not topbar:
		return
	var sb := _make_sb(COR_PANEL_BRANCO)
	sb.border_width_bottom = 1
	sb.border_color        = COR_BORDA
	topbar.add_theme_stylebox_override("panel", sb)

	var banner := topbar.get_node_or_null("BannerLogo")
	if banner:
		banner.add_theme_stylebox_override("panel", _make_sb(COR_PANEL_BRANCO))
		var lbl := banner.get_node_or_null("Label2")
		if lbl:
			lbl.add_theme_color_override("font_color", COR_TEXTO_ESCURO)
			lbl.add_theme_font_size_override("font_size", 13)


func _style_sidebar_botoes() -> void:
	var caminhos := [
		"TopBar/VBoxContainer/Mg_CreateProduct/Btn_CreateProduct",
		"TopBar/VBoxContainer/Mg_Product/Btn_Product",
		"TopBar/VBoxContainer/Mg_Market/Btn_Market",
		"TopBar/VBoxContainer/Mg_Brand/Btn_Brand",
		"TopBar/VBoxContainer/Mg_Production/Btn_Production",
		"TopBar/VBoxContainer/Mg_Marketing/Btn_Marketing",
		"TopBar/VBoxContainer/Mg_Logistic/Btn_Logistic",
		"TopBar/VBoxContainer/Mg_Stock/Btn_Stock",
		"TopBar/VBoxContainer/Mg_Quality/Btn_Quality",
		"TopBar/VBoxContainer/Mg_Research/Btn_Research",
	]
	for caminho in caminhos:
		var btn := get_node_or_null(caminho)
		if not btn:
			continue
		btn.add_theme_stylebox_override("normal",  _make_sb(COR_FUNDO, 10))
		btn.add_theme_stylebox_override("hover",   _make_sb(COR_BORDA, 10))
		btn.add_theme_stylebox_override("pressed", _make_sb(COR_BTN_PRIMARY, 10))
		btn.add_theme_color_override("font_color",         COR_TEXTO_ESCURO)
		btn.add_theme_color_override("font_hover_color",   COR_TEXTO_ESCURO)
		btn.add_theme_color_override("font_pressed_color", COR_PANEL_BRANCO)

		var panel := btn.get_node_or_null("Panel")
		if panel:
			panel.add_theme_stylebox_override("panel", _make_sb(Color(0,0,0,0)))

		var label := btn.get_node_or_null("Panel/Label")
		if label:
			label.add_theme_color_override("font_color", COR_TEXTO_ESCURO)


func _style_screen_create_product() -> void:
	var screen := get_node_or_null("Screen_CreateProduct")
	if not screen:
		return
	screen.add_theme_stylebox_override("panel", _make_sb(COR_FUNDO))

	for nome in ["Label", "Label2", "Label3"]:
		var lbl := screen.get_node_or_null(nome)
		if lbl:
			lbl.add_theme_color_override("font_color", COR_TEXTO_ESCURO)

	for caminho in ["HBComponents/VBoxAvailable/ScrollAvailable", "HBComponents/VBoxSelected/ScrollSelected"]:
		var scroll := screen.get_node_or_null(caminho)
		if scroll:
			scroll.add_theme_stylebox_override("panel", _make_sb(COR_PANEL_BRANCO, 10, true))

	for caminho in ["HBComponents/VBoxAvailable/Lbl_Available", "HBComponents/VBoxSelected/Lbl_Selected"]:
		var lbl := screen.get_node_or_null(caminho)
		if lbl:
			lbl.add_theme_color_override("font_color", COR_TEXTO_MUTED)
			lbl.add_theme_font_size_override("font_size", 11)

	var panel_viz := screen.get_node_or_null("Panel")
	if panel_viz:
		panel_viz.add_theme_stylebox_override("panel", _make_sb(COR_PANEL_BRANCO, 12, true))


func _style_inputs_dropdowns() -> void:
	var base := "Screen_CreateProduct/VBCCriacaoProduto/"
	for nome in ["Inp_ProductName", "Dd_Category", "Dd_Type", "Dd_Package", "Dd_Size"]:
		var no := get_node_or_null(base + nome)
		if not no:
			continue
		var sb := _make_sb(COR_INPUT_FUNDO, 8, true)
		sb.content_margin_left  = 10.0
		sb.content_margin_right = 10.0
		no.add_theme_stylebox_override("normal", sb)
		no.add_theme_color_override("font_color", COR_TEXTO_ESCURO)
		if no is LineEdit:
			no.add_theme_color_override("font_placeholder_color", COR_TEXTO_MUTED)

	var btn_rand := get_node_or_null(base + "Inp_ProductName/Btn_RandomName")
	if btn_rand:
		var sb_transp := _make_sb(Color(0,0,0,0))
		btn_rand.add_theme_stylebox_override("normal",  sb_transp)
		btn_rand.add_theme_stylebox_override("hover",   sb_transp)
		btn_rand.add_theme_stylebox_override("pressed", sb_transp)


func _style_btn_create() -> void:
	var btn := get_node_or_null("Screen_CreateProduct/VBCCriacaoProduto/Btn_Create")
	if not btn:
		return
	var sb_hover := _make_sb(Color(0.2, 0.2, 0.21, 1.0), 8)
	btn.add_theme_stylebox_override("normal",  _make_sb(COR_BTN_PRIMARY, 8))
	btn.add_theme_stylebox_override("hover",   sb_hover)
	btn.add_theme_stylebox_override("pressed", _make_sb(COR_BTN_PRIMARY, 8))
	btn.add_theme_color_override("font_color", COR_PANEL_BRANCO)
	btn.add_theme_font_size_override("font_size", 14)


func _style_screen_market() -> void:
	var screen := get_node_or_null("Screen_Market")
	if not screen:
		return
	screen.add_theme_stylebox_override("panel", _make_sb(COR_FUNDO))

	var lista := screen.get_node_or_null("VBoxContainer/ProductList")
	if lista:
		lista.add_theme_stylebox_override("panel", _make_sb(COR_PANEL_BRANCO, 12, true))
		lista.add_theme_color_override("font_color", COR_TEXTO_ESCURO)


func _style_screen_components() -> void:
	var screen := get_node_or_null("Screen_Components")
	if not screen:
		return
	screen.add_theme_stylebox_override("panel", _make_sb(COR_FUNDO))
