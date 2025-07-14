extends ActionScript

func _initialize() -> void:
	Signals.settings_changed.connect(_load_config)
	Settings.define_preset("editor_ui", "font_size", 16)

func _run_action() -> void:
	Settings.restore_default("editor_ui", "font_size")
	_load_config()

func _load_config() -> void:
	Global.get_editor().add_theme_font_size_override("font_size", Settings.get_setting("editor_ui", "font_size"))
