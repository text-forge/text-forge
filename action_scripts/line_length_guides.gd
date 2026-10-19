extends ActionScript

var popup: Window

func _initialize() -> void:
	Settings.define_preset("editor_ui", "line_length_guides", [100, 80])
	Signals.settings_changed.connect(_load_config)
	_load_config()


func _run_action() -> void:
	var popup_scene := U.load_resource("res://action_scripts/scenes/line_length_guides.tscn")
	if not popup_scene:
		return
	popup = popup_scene.instantiate()
	popup.close_requested.connect(_save_config)
	popup.input.text = ", ".join(Settings.get_setting("editor_ui", "line_length_guides").map(func(line): return str(line)))
	add_child(popup)


func _save_config() -> void:
	Settings.set_setting(
		"editor_ui",
		"line_length_guides",
		S.map_array_to_int(Array(popup.input.text.split(","))).filter(func(line): return line != 0)
	)
	if popup: popup.queue_free()
	_load_config()


func _load_config() -> void:
	Global.get_editor().line_length_guidelines = S.map_array_to_int(Settings.get_setting("editor_ui","line_length_guides"))
