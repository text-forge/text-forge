extends CheckableActionScript

func _setup() -> void:
	settings_section = "editor_ui"
	settings_key = "highlight_all_occurrences"
	default = true

func _set_value(to: bool) -> void:
	Global.get_editor().highlight_all_occurrences = to

func _get_value() -> bool:
	return Global.get_editor().highlight_all_occurrences
