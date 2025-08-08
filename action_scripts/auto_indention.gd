extends CheckableActionScript

func _setup() -> void:
	settings_section = "edit"
	settings_key = "auto_indention"
	default = true

func _set_value(to: bool) -> void:
	Global.get_editor().indent_automatic = to

func _get_value() -> bool:
	return Global.get_editor().indent_automatic
