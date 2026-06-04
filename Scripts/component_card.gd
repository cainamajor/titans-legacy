extends PanelContainer

@onready var label_name = $VBox/Name
@onready var label_company = $VBox/Company
@onready var label_type = $VBox/Type

func setup(data: Dictionary) -> void:
	label_name.text = data.get("name", "")
	label_company.text = data.get("company", "")
	label_type.text = data.get("type", "")
