class_name EditorAPI
extends Control
## Editor API and Mode Manager.
##
## This node is first child of [Editor] and designed to manage modes. Access way: [code]Global.get_editor_api()[/code]

## List of all loaded modes.
var modes: Array = []
## Selected mode index.
var selected_mode_index: int
## Currently in use mode.
var current_mode: Dictionary

func _ready() -> void:
	# Defines comment delimiter
	# TODO: Handle this with modes.
	Global.get_editor().add_comment_delimiter("#", "", true)

	Settings.define_preset("edit", "indent_with_space", false)
	Settings.define_preset("edit", "indent_size", 4)

	Signals.mode_selected.connect(func(index): selected_mode_index = index - 1)
	Signals.settings_changed.connect(_load_configs)

	_load_modes()
	_load_configs()


## Will send auto format command to correct mode. Pushs error if there is no compatible mode, uses
## current mode if is compatible, otherwise creates [PopupMenu] to choose correct mode.
func auto_format() -> void:
	var path = Global.get_file_path()
	if path == "Unsaved":
		Global.send_notification(Global.Notification.ERROR, "Please save file before auto formatting.", "File extension for auto format is required.")
		return

	var available_modes := _get_available_modes(path.get_extension())
	if available_modes.size() == 0:
		Global.send_notification(Global.Notification.ERROR, "Can't find any mode for auto format this file!", "You can find more modes in Help > Mode Library")
		current_mode = {}
		return

	# format with current mode if mode is compatible
	if current_mode in available_modes:
		_auto_format(current_mode.script)

	# format with available mode when there is just one complatible
	elif available_modes.size() == 1:
		_auto_format(available_modes[0].script)

	# select mode
	else:
		var select_menu := PopupMenu.new()
		select_menu.add_separator("Select a mode to auto format")
		for mode in available_modes:
			select_menu.add_item(mode.name)
		select_menu.index_pressed.connect(func(index): Signals.mode_selected.emit(index))
		add_child(select_menu)
		select_menu.size = Vector2(400, 0)
		select_menu.popup_centered()
		await Signals.mode_selected

		select_menu.queue_free()
		_auto_format(available_modes[selected_mode_index].script)


## Will send save command to correct mode. Pushs error if there is no compatible mode, uses
## current mode if is compatible, otherwise creates [PopupMenu] to choose correct mode.
func save_file(path: String) -> void:
	var available_modes := _get_available_modes(path.get_extension())
	if available_modes.size() == 0:
		Global.send_notification(Global.Notification.WARNING, "Can't find any mode to save this file", "save file using UTF-8...")
		current_mode = {}
		var file = FileAccess.open(path, FileAccess.WRITE)
		file.store_string(Global.get_editor_text())
		file.close()
		return

	# save with current mode if mode is compatible
	if current_mode in available_modes:
		_save_file(current_mode.script, path)

	# save with available mode when there is just one complatible
	elif available_modes.size() == 1:
		_save_file(available_modes[0].script, path)

	# select mode
	else:
		var select_menu := PopupMenu.new()
		select_menu.add_separator("Select a mode to save file")
		for mode in available_modes:
			select_menu.add_item(mode.name)
		select_menu.index_pressed.connect(func(index): Signals.mode_selected.emit(index))
		add_child(select_menu)
		select_menu.size = Vector2(400, 0)
		select_menu.popup_centered()
		await Signals.mode_selected

		select_menu.queue_free()
		_save_file(available_modes[selected_mode_index].script, path)


## Will send load command to correct mode and activates highlighter. Pushs error if there is no
## compatible mode, uses current mode if is compatible, otherwise creates [PopupMenu] to choose
## correct mode.
func load_file(path: String) -> void:
	var available_modes := _get_available_modes(path.get_extension())
	if available_modes.size() == 0:
		Global.send_notification(Global.Notification.WARNING, "Can't find any mode to open this file", "loading file using UTF-8...")
		current_mode = {}
		var file = FileAccess.open(path, FileAccess.READ)
		Global.set_editor_disabled(false)
		Global.set_editor_text(file.get_as_text())
		file.close()
		# clear syntax highlighter
		get_parent().syntax_highlighter = SyntaxHighlighter.new()
		return

	if available_modes.size() > 1:
		var select_menu := PopupMenu.new()
		select_menu.add_separator("Select a mode to open file")
		for mode in available_modes:
			select_menu.add_item(mode.name)
		select_menu.index_pressed.connect(func(index): Signals.mode_selected.emit(index))
		add_child(select_menu)
		select_menu.size = Vector2(400, 0)
		select_menu.popup_centered()
		await Signals.mode_selected
		select_menu.queue_free()
	else:
		selected_mode_index = 0

	current_mode = available_modes[selected_mode_index]
	_load_highlighter(current_mode.highlighter)
	_load_file(current_mode.script, path)


func _load_configs() -> void:
	Global.get_editor().indent_use_spaces = Settings.get_setting("edit", "indent_with_space")
	Global.get_editor().indent_size = Settings.get_setting("edit", "indent_size")


func _auto_format(script: GDScript) -> void:
	script.new().auto_format()


func _save_file(saver: GDScript, path: String) -> void:
	saver.new().save_file(path)
	Signals.check_options.emit()


func _load_file(loader: GDScript, path: String) -> void:
	Global.set_editor_text(loader.new().load_file(path))
	Global.set_editor_disabled(false)
	Signals.check_options.emit()


func _load_highlighter(source: Dictionary) -> void:
	var code_highlighter = CodeHighlighter.new()
	code_highlighter.number_color = source.number_color
	code_highlighter.symbol_color = source.symbol_color
	code_highlighter.function_color = source.function_color
	code_highlighter.member_variable_color = source.member_variable_color
	for color in source.keyword_colors:
		for keyword in source.keyword_colors[color]:
			code_highlighter.add_keyword_color(keyword, color)
	for color in source.member_keyword_colors:
		for keyword in source.member_keyword_colors[color]:
			code_highlighter.add_member_keyword_color(keyword, color)
	for color in source.code_regions:
		code_highlighter.add_color_region(source.code_regions[color][0], source.code_regions[color][1], color, true if source.code_regions[color][2] == "y" else false)
	get_parent().syntax_highlighter = code_highlighter


func _get_available_modes(extension: String) -> Array[Dictionary]:
	var available_modes: Array[Dictionary] = []
	for mode in modes:
		if extension in mode.extensions:
			available_modes.append(mode)
	return available_modes


func _load_modes() -> void:
	var mode_folders = DirAccess.get_directories_at(FileDatabase.FOLDER_MODES)
	for mode_dir in mode_folders:
		if not FileAccess.file_exists(FileDatabase.FOLDER_MODES.path_join(mode_dir).path_join("mode.cfg")): continue
		var mode: Dictionary = {}
		var config = ConfigFile.new()
		config.load(FileDatabase.FOLDER_MODES.path_join(mode_dir).path_join("mode.cfg"))
		mode.name = config.get_value("mode", "name")
		mode.description = config.get_value("mode", "description")
		mode.author = config.get_value("mode", "author")
		mode.version = config.get_value("mode", "version")
		mode.extensions = config.get_value("mode", "extensions")
		mode.highlighter = {}
		for key in config.get_section_keys("highlighter"):
			mode.highlighter[key] = config.get_value("highlighter", key)
		mode.script = load(FileDatabase.FOLDER_MODES.path_join(mode_dir).path_join("mode.gd"))
		modes.append(mode)


## Reloads modes, it's useful for mode managers to avoid restart.
func reload_modes() -> void:
	modes = []
	_load_modes()
