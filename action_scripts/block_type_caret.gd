extends CheckableActionScript

func _setup() -> void:
	settings_section = "editor_ui"
	settings_key = "block_type_caret"
	default = false

func _set_value(to: bool) -> void:
	if to:
		Global.get_editor().caret_type = TextEdit.CARET_TYPE_BLOCK
	else:
		Global.get_editor().caret_type = TextEdit.CARET_TYPE_LINE

func _get_value() -> bool:
	return Global.get_editor().caret_type == TextEdit.CARET_TYPE_BLOCK
