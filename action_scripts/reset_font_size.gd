extends ActionScript

func _initialize() -> void:
	Signals.settings_changed.connect(_load_config)
	Settings.define_preset("editor_ui", "font_size", 16)
	_load_config()


func _run_action() -> void:
	Settings.restore_default("editor_ui", "font_size")
	_load_config()


func _load_config() -> void:
	# There is no editor while no document is open, the size applies to the next one.
	var editor := Global.get_editor()
	if not editor:
		return
	editor.add_theme_font_size_override("font_size", Settings.get_setting("editor_ui", "font_size"))
