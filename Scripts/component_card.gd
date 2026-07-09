extends PanelContainer

@onready var label_name    = $MarginContainer/HBox/Info/LabelName
@onready var label_company = $MarginContainer/HBox/Info/LabelCompany
@onready var label_type    = $MarginContainer/HBox/TypeBadge/LabelType
@onready var icon_rect     = $MarginContainer/HBox/IconBox

# Cores slot BASE — azul
const COR_BASE_ICON  := Color(0.878, 0.933, 0.984, 1.0)
const COR_BASE_BORDA := Color(0.000, 0.443, 0.890, 0.3)
const COR_BASE_BADGE := Color(0.878, 0.933, 0.984, 1.0)
const COR_BASE_TEXT  := Color(0.094, 0.373, 0.647, 1.0)

# Cores slot SABOR — laranja/ambar
const COR_SABOR_ICON  := Color(0.980, 0.933, 0.855, 1.0)
const COR_SABOR_BORDA := Color(0.855, 0.467, 0.043, 0.3)
const COR_SABOR_BADGE := Color(0.980, 0.933, 0.855, 1.0)
const COR_SABOR_TEXT  := Color(0.522, 0.310, 0.043, 1.0)

# Cores gerais
const COR_BRANCO       := Color(1.0,   1.0,   1.0,   1.0)
const COR_BORDA        := Color(0.878, 0.878, 0.878, 1.0)
const COR_HOVER        := Color(0.945, 0.945, 0.953, 1.0)
const COR_TEXTO_ESCURO := Color(0.114, 0.114, 0.122, 1.0)
const COR_TEXTO_MUTED  := Color(0.431, 0.431, 0.451, 1.0)

var _is_selected := false
var _slot        := "base"


func _ready() -> void:
	_apply_card_style(false)


func setup(data: Dictionary) -> void:
	_slot = data.get("slot", "base")

	label_name.text    = data.get("name",    "")
	label_company.text = data.get("company", "")
	label_type.text    = data.get("type",    "")

	# Label de qualidade como tooltip no type badge
	var quality = data.get("quality", 0)
	var cost    = data.get("base_cost", 0.0)
	label_type.text = "Q%d · R$%.2f" % [quality, cost]

	_apply_slot_style()


func _apply_slot_style() -> void:
	# Cor do ícone e badge conforme slot
	var cor_icon  := COR_BASE_ICON  if _slot == "base" else COR_SABOR_ICON
	var cor_text  := COR_BASE_TEXT  if _slot == "base" else COR_SABOR_TEXT
	var cor_badge := COR_BASE_BADGE if _slot == "base" else COR_SABOR_BADGE

	# Ícone
	if icon_rect:
		var sb := StyleBoxFlat.new()
		sb.bg_color = cor_icon
		sb.corner_radius_top_left     = 8
		sb.corner_radius_top_right    = 8
		sb.corner_radius_bottom_left  = 8
		sb.corner_radius_bottom_right = 8
		icon_rect.add_theme_stylebox_override("panel", sb)

	# Badge de tipo/custo
	if label_type:
		label_type.add_theme_color_override("font_color", cor_text)

	# Aplica estilo normal do card
	_apply_card_style(false)


func set_selected(selected: bool) -> void:
	_is_selected = selected
	_apply_card_style(selected)


func _apply_card_style(selected: bool) -> void:
	var sb := StyleBoxFlat.new()
	sb.corner_radius_top_left     = 10
	sb.corner_radius_top_right    = 10
	sb.corner_radius_bottom_left  = 10
	sb.corner_radius_bottom_right = 10

	if selected:
		# Azul para base selecionado, laranja para sabor selecionado
		if _slot == "base":
			sb.bg_color     = Color(0.922, 0.941, 0.984, 1.0)
			sb.border_color = Color(0.000, 0.443, 0.890, 1.0)
		else:
			sb.bg_color     = Color(0.984, 0.945, 0.902, 1.0)
			sb.border_color = Color(0.855, 0.467, 0.043, 1.0)
		sb.border_width_left   = 2
		sb.border_width_right  = 2
		sb.border_width_top    = 2
		sb.border_width_bottom = 2
	else:
		sb.bg_color     = COR_BRANCO
		sb.border_color = COR_BORDA
		sb.border_width_left   = 1
		sb.border_width_right  = 1
		sb.border_width_top    = 1
		sb.border_width_bottom = 1

	add_theme_stylebox_override("panel", sb)


func _on_mouse_entered() -> void:
	if _is_selected:
		return
	var sb := StyleBoxFlat.new()
	sb.bg_color     = COR_HOVER
	sb.border_color = COR_BORDA
	sb.border_width_left   = 1
	sb.border_width_right  = 1
	sb.border_width_top    = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left     = 10
	sb.corner_radius_top_right    = 10
	sb.corner_radius_bottom_left  = 10
	sb.corner_radius_bottom_right = 10
	add_theme_stylebox_override("panel", sb)


func _on_mouse_exited() -> void:
	_apply_card_style(_is_selected)
