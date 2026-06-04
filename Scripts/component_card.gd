extends PanelContainer

@onready var label_name    = $MarginContainer/HBox/Info/LabelName
@onready var label_company = $MarginContainer/HBox/Info/LabelCompany
@onready var label_type    = $MarginContainer/HBox/TypeBadge/LabelType
@onready var icon_rect     = $MarginContainer/HBox/IconBox

const COR_BRANCO       := Color(1.0,   1.0,   1.0,   1.0)
const COR_BORDA        := Color(0.878, 0.878, 0.878, 1.0)
const COR_HOVER        := Color(0.945, 0.945, 0.953, 1.0)
const COR_TEXTO_ESCURO := Color(0.114, 0.114, 0.122, 1.0)
const COR_TEXTO_MUTED  := Color(0.431, 0.431, 0.451, 1.0)

const CORES_ICONE := {
	"Bebidas":    { "bg": Color(0.980, 0.933, 0.855, 1.0), "fg": Color(0.522, 0.310, 0.043, 1.0) },
	"Alimentos":  { "bg": Color(0.918, 0.953, 0.871, 1.0), "fg": Color(0.231, 0.427, 0.067, 1.0) },
	"Tecnologia": { "bg": Color(0.902, 0.945, 0.984, 1.0), "fg": Color(0.094, 0.373, 0.647, 1.0) },
	"Moda":       { "bg": Color(0.984, 0.918, 0.941, 1.0), "fg": Color(0.600, 0.204, 0.337, 1.0) },
	"Automotivo": { "bg": Color(0.933, 0.918, 0.984, 1.0), "fg": Color(0.325, 0.290, 0.718, 1.0) },
}
const COR_ICONE_PADRAO := { "bg": Color(0.941, 0.937, 0.933, 1.0), "fg": Color(0.373, 0.369, 0.353, 1.0) }

var _is_selected := false


func _ready() -> void:
	_apply_card_style(false)


func setup(data: Dictionary) -> void:
	label_name.text    = data.get("name",    "")
	label_company.text = data.get("company", "")
	label_type.text    = data.get("type",    "")
	var categoria = data.get("category", "")
	var cores = CORES_ICONE.get(categoria, COR_ICONE_PADRAO)
	_apply_icon_color(cores["bg"])


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
		sb.bg_color = Color(0.922, 0.941, 0.984, 1.0)
		sb.border_color = Color(0.000, 0.443, 0.890, 1.0)
		sb.border_width_left   = 2
		sb.border_width_right  = 2
		sb.border_width_top    = 2
		sb.border_width_bottom = 2
	else:
		sb.bg_color    = COR_BRANCO
		sb.border_color = COR_BORDA
		sb.border_width_left   = 1
		sb.border_width_right  = 1
		sb.border_width_top    = 1
		sb.border_width_bottom = 1
	add_theme_stylebox_override("panel", sb)


func _apply_icon_color(cor_bg: Color) -> void:
	if not icon_rect:
		return
	var sb := StyleBoxFlat.new()
	sb.bg_color = cor_bg
	sb.corner_radius_top_left     = 8
	sb.corner_radius_top_right    = 8
	sb.corner_radius_bottom_left  = 8
	sb.corner_radius_bottom_right = 8
	icon_rect.add_theme_stylebox_override("panel", sb)


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
