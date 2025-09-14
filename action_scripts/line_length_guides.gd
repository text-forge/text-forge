extends ActionScript

var popup: Window

func _initialize() -> void:
	Settings.define_preset("editor_ui", "line_length_guides", [100, 80])
	Signals.settings_changed.connect(_load_config)
	_load_config()

func _run_action() -> void:
	popup = Global.load_resource("res://action_scripts/scenes/line_length_guides.tscn").instantiate()
	popup.close_requested.connect(_save_config)
	popup.input.text = ", ".join(Settings.get_setting("editor_ui", "line_length_guides").map(func(line): return str(line)))
	add_child(popup)

func _save_config() -> void:
	Settings.set_setting("editor_ui", "line_length_guides", Array(popup.input.text.split(",")).map(func(line): return int(line)).filter(func(line): return line != 0))
	if popup: popup.queue_free()
	_load_config()

func _load_config() -> void:
	Global.get_editor().line_length_guidelines = Settings.get_setting("editor_ui", "line_length_guides").map(func(item): return int(item))
