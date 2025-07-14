extends ActionScript

func _run_action() -> void:
	Global.get_editor().add_theme_font_size_override("font_size", Global.get_editor().get_theme_font_size("font_size") - 2)
	Settings.set_setting("editor_ui", "font_size", Global.get_editor().get_theme_font_size("font_size"))
