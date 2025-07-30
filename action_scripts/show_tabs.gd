extends CheckableActionScript

func _setup() -> void:
	settings_section = "editor_ui"
	settings_key = "show_tabs"
	default = true

func _set_value(to: bool) -> void:
	Global.get_editor().draw_tabs = to

func _get_value() -> bool:
	return Global.get_editor().draw_tabs
