class_name EditorAPI
extends Control
## Editor API and Mode Manager.
##
## This node is first child of [Editor] and designed to manage modes. Access way: [code]Global.get_editor_api()[/code][br][br]
## This module manages a lot of important features and functionalities, including:[br][br]
## - Modes validating, loading, management, handling internal modes[br]
## - File saving and loading[br]
## - Mode panel[br]
## - Mode-based indentation settings[br]
## - File preview[br]
## - File outline[br]
## - File linting[br]
## - Installing modes from [code].tfmode[/code] files[br]
## - Auto format and auto indent[br]
## - Code completion[br]
## - Smart file editing[br]
## - Syntax highlighter[br]
## - Bookmarks[br]

## Emits when a mode selected from available modes, this is a delay system and restore choice when
## there is more than one mode for current file. (See [method load_file] and [method save_file] for usages)
signal mode_selected(index: int)
## Shares any change in indentation settings.
signal indentation_settings_updated(use_space: bool, indent_size: int)

## Keeps availabe hooks to connect.
enum Hooks {
	## A hook that will be called before save.[br][br]
	## [b]Note:[/b] [Callable]s connected to this hook must edit [Editor]'s text with [method GlobalAccess.set_editor_text], because other methods will mark file as unsaved after save (signal emission delay).
	BEFORE_SAVE
}

## Keeps list of all modes informations without damaged modes.
var mode_list: Array[Dictionary] = []
## Keeps information of current mode from [member mode_list].
var current_mode: Dictionary = {}
## Keeps panel of currently in use mode.
var mode_panel: TextForgePanel
## Keeps customized configuration for indentation settings for each mode.
var custom_mode_indentations := {}
## Keeps connected [Callable]s for each hook in [enum Hooks].
var hooks: Dictionary[Hooks, Array]
# Keeps temprory index of selected mode.
var _temp_mode_index: int = 0

func _ready() -> void:
	Notif.register_notification(
		"load_modes_failed",
		Notif.Type.ERR,
		"Failed to load some modes!"
	)
	Notif.register_notification(
		"import_mode_completed",
		Notif.Type.INFO,
		"Import mode / mode kit completed."
	)
	Notif.register_notification(
		"save_without_mode",
		Notif.Type.WARN,
		"Can't find any mode to save this file.",
		"File will be saved with UTF-8 (The result may be wrong)"
	)
	Notif.register_notification(
		"load_without_mode",
		Notif.Type.WARN,
		"Can't find any mode to open this file.",
		"File will be loaded with UTF-8 (The result may be wrong)"
	)
	Notif.register_notification(
		"mode_initialize_failed",
		Notif.Type.ERR,
		"Failed to initialize mode {0} for {1}!"
	)
	Notif.register_notification(
		"mode_script_not_found",
		Notif.Type.ERR,
		"Mode script not found!"
	)
	Notif.register_notification(
		"invalid_indent_size",
		Notif.Type.ERR,
		"Invalid indent size!",
		"Indent size must be at least 1."
	)
	child_order_changed.connect(Signals.refresh_module_profiler)
	mode_selected.connect(func(index): _temp_mode_index = index - 1)
	Global.get_editor().type_timer_timeout.connect(_update_preview)
	Global.get_editor().type_timer_timeout.connect(_update_outline)
	Global.get_editor().type_timer_timeout.connect(_lint_content)
	# Install internal modes
	if not DirAccess.dir_exists_absolute(S.globalize_path(S.FOLDER_MODES.path_join("plain_text"))):
		import_mode(S.globalize_path(S.DEFAULT_MODES))
	else:
		_load_mode_list()


## Loads [member mode_list], will fill [member GlobalAccess.damaged_modes] with failed modes.
## This function have file existence check, [ConfigFile] error handling, config section and key
## validation, and script class check. This function will add modes folder name to mode information
## dictionary as [code]"id"[/code].
func _load_mode_list() -> void:
	if not mode_list.is_empty():
		mode_list.clear()
	var damaged_modes: Dictionary[String, String] = {}
	# Validate each mode
	for mode_folder: String in DirAccess.get_directories_at(S.FOLDER_MODES):
		if not (
			FileAccess.file_exists(S.globalize_path(S.TEMPLATE_MODE_INFO.format([mode_folder])))
			and FileAccess.file_exists(S.globalize_path(S.TEMPLATE_MODE_SCRIPT.format([mode_folder])))
			and FileAccess.file_exists(S.globalize_path(S.TEMPLATE_MODE_ICON.format([mode_folder])))
		):
			damaged_modes[mode_folder] = "Missing files"
			continue
		var config = ConfigFile.new()
		var err := config.load(S.globalize_path(S.TEMPLATE_MODE_INFO.format([mode_folder])))
		if err:
			damaged_modes[mode_folder] = "Load config failed"
			continue
		if Array(config.get_sections()) != ["mode"]:
			damaged_modes[mode_folder] = "Invalid sections"
			continue
		if Array(config.get_section_keys("mode")) != ["name", "description", "author", "version", "extensions"]:
			damaged_modes[mode_folder] = "Invalid keys"
			continue
		var mode: Dictionary[String, Variant] = {"id": mode_folder}
		for key: String in config.get_section_keys("mode"):
			mode[key] = config.get_value("mode", key)
		mode_list.append(mode)
	custom_mode_indentations = Settings.read_data("mode_settings", "indentations", {})
	Global.damaged_modes = damaged_modes
	if damaged_modes:
		var damaged_modes_grouped: Dictionary[String, Array] = {}
		for mode in damaged_modes:
			if not damaged_modes_grouped.has(damaged_modes[mode]):
				damaged_modes_grouped[damaged_modes[mode]] = []
			damaged_modes_grouped[damaged_modes[mode]].append(mode)
		var damaged_modes_string: String = ""
		for problem in damaged_modes_grouped:
			if damaged_modes_string != "":
				damaged_modes_string += "\n\t"
			damaged_modes_string += "{0}: {1}".format([problem, ", ".join(damaged_modes_grouped[problem])])
		Notif.notif("load_modes_failed", {"text": damaged_modes_string})


## Reloads all modes with [method _load_mode_list].
func reload_modes() -> void:
	_load_mode_list()


## Imports one or more mode from a [code].tfmode[/code] file.
func import_mode(path: String) -> void:
	if path.get_extension().to_lower() != "tfmode":
		Notif.notif(
			"invalid_file_extension",
			{"format_text": ["tfmode", path.get_extension()]}
		)
		return
	var reader = ZIPReader.new()
	var err := reader.open(path)
	if err:
		Notif.notif(
			"open_file_failed",
			{"format_title": [path], "text_append": error_string(err)}
		)
		return
	if not DirAccess.dir_exists_absolute(S.globalize_path("user://modes")):
		DirAccess.make_dir_absolute(S.globalize_path("user://modes"))
	var root_dir = DirAccess.open("user://")
	# Extract file
	var files = reader.get_files()
	for file_path: String in files:
		# Reject entries not under modes/
		file_path = file_path.simplify_path()
		if not file_path.begins_with("modes/"):
			Notif.notif(
				"security_alert",
				{"text": path + " file contains a file outside modes folder: " + file_path + "\nThis file extraction was skipped!"}
			)
			continue
		if file_path.ends_with("/"):
			root_dir.make_dir_recursive(file_path)
			continue
		root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
		var file = FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
		var buffer = reader.read_file(file_path)
		file.store_buffer(buffer)
	reload_modes()
	Notif.notif("import_mode_completed")


## Handle file saving from mode selection to correct mode encode system and then to targe file.
## See [url=https://text-forge.github.io/docs/setup#open-a-file]Open A File[/url] guide for possible
## situations in mode selection.
func save_file(file_path: String) -> void:
	var mode := current_mode
	_run_hook(Hooks.BEFORE_SAVE)
	if not _is_mode_compatible(current_mode, file_path):
		var compatible_modes := mode_list.filter(func(m): return _is_mode_compatible(m, file_path))
		match compatible_modes.size():
			0:
				Notif.notif("save_without_mode")
				_unload_current_mode()
				# Save with UTF-8
				var file = FileAccess.open(file_path, FileAccess.WRITE)
				if not file:
					Notif.notif(
						"save_file_failed",
						{"format_title": ["this file"], "text_append": error_string(FileAccess.get_open_error())}
					)
					return
				file.store_string(Global.get_editor_text())
				file.close()
				# ---
				Global.get_core().append_to_recent_files(file_path)
				_save_bookmarks()
				Signals.check_options.emit()
				return
			1:
				mode = compatible_modes[0]
			_:
				var select_menu := PopupMenu.new()
				select_menu.add_separator("Select a mode to save file")
				for m in compatible_modes:
					select_menu.add_item(m["name"])
				select_menu.index_pressed.connect(func(index): mode_selected.emit(index))
				select_menu.size = Vector2(400, 0)
				add_child(select_menu)
				select_menu.popup_centered()
				await mode_selected
				remove_child(select_menu)
				select_menu.queue_free()
				mode = compatible_modes[_temp_mode_index]
				_temp_mode_index = 0
	if _change_mode_to(mode) == OK:
		_handle_save_file(file_path)
	else:
		Notif.notif(
			"mode_initialize_failed",
			{"format_title": [mode["name"], "save"]}
		)


## Handle file loading from mode selection to targe file and then to correct mode's decode system
## and editor. See [url=https://text-forge.github.io/docs/setup#open-a-file]Open A File[/url] guide
## for possible situations in mode selection.
func load_file(file_path: String) -> void:
	file_path = file_path.simplify_path()
	if file_path.get_extension().to_lower() == "tfproj":
		Project.load_project(file_path)
		return
	var mode := current_mode

	if not _is_mode_compatible(current_mode, file_path):
		var compatible_modes := mode_list.filter(func(m): return _is_mode_compatible(m, file_path))

		match compatible_modes.size():
			0:
				Notif.notif("load_without_mode")
				_unload_current_mode()
				# Load with UTF-8
				var content := FileAccess.get_file_as_string(file_path)
				if FileAccess.get_open_error():
					Notif.notif(
						"open_file_failed",
						{"format_title": [file_path], "text_append": error_string(FileAccess.get_open_error())}
					)
					return
				Global.set_editor_text(content)
				Global.get_core().append_to_recent_files(file_path)
				Global.set_editor_disabled(false)
				# ---
				Signals.check_options.emit()
				update_indentation_settings(false)
				_load_bookmarks()
				Global.get_editor().type_timer_timeout.emit()
				return
			1:
				mode = compatible_modes[0]
			_:
				var select_menu := PopupMenu.new()
				select_menu.add_separator("Select a mode to open file")
				for m in compatible_modes:
					select_menu.add_item(m["name"])
				select_menu.index_pressed.connect(func(index): mode_selected.emit(index))
				select_menu.size = Vector2(400, 0)
				add_child(select_menu)
				select_menu.popup_centered()
				await mode_selected
				remove_child(select_menu)
				select_menu.queue_free()
				mode = compatible_modes[_temp_mode_index]
				_temp_mode_index = 0
	if _change_mode_to(mode) == OK:
		_handle_load_file(file_path)
	else:
		Notif.notif(
			"mode_initialize_failed",
			{"format_title": [mode["name"], "load"]}
		)


## Handle auto format request to mode and then back result to editor.
func auto_format() -> void:
	var mode_script := _get_mode_script()
	if not mode_script:
		return
	if not mode_script.features["auto_format"]:
		return
	Global.set_editor_text(mode_script._auto_format(Global.get_editor_text()))


## Handle auto indent request to mode and then back result to editor.
func auto_indent() -> void:
	var mode_script := _get_mode_script()
	if not mode_script:
		return
	if not mode_script.features["auto_indent"]:
		return
	Global.set_editor_text(mode_script._auto_indent(Global.get_editor_text()))


## Returns [code]true[/code] if current mode supports auto format.
func is_auto_format_available() -> bool:
	var mode_script := _get_mode_script()
	if not mode_script:
		return false
	return mode_script.features["auto_format"]


## Returns [code]true[/code] if current mode supports auto indent.
func is_auto_indent_available() -> bool:
	var mode_script := _get_mode_script()
	if not mode_script:
		return false
	return mode_script.features["auto_indent"]


## Connects a [param callable] to given [param hook].
func connect_to_hook(hook: Hooks, callable: Callable) -> void:
	if not hooks.has(hook):
		hooks[hook] = Array([], TYPE_CALLABLE, "", null)
	# Check if this exact callable (same object/method + same bound args) already exists
	for existing: Callable in hooks[hook]:
		if existing == callable and existing.get_bound_arguments() == callable.get_bound_arguments():
			return
	hooks[hook].append(callable)


## Disconnects given [callable] from connected [param hook] with [method connect_to_hook].
func disconnect_from_hook(hook: Hooks, callable: Callable) -> void:
	if not hooks.has(hook):
		return
	hooks[hook].erase(callable)


## Runs given hook and disconnects invalid callables.
func _run_hook(hook: Hooks) -> void:
	if not hooks.has(hook):
		return
	if hooks[hook].is_empty():
		return
	for c: Callable in hooks[hook]:
		if c.is_valid():
			c.call()
		else:
			disconnect_from_hook.call_deferred(hook, c)


## Connected to editor's [code]code_completion_requested[/code] signal and will uandle code completion.
func _on_editor_code_completion_requested() -> void:
	var mode_script := _get_mode_script()
	if not mode_script:
		return
	mode_script._update_code_completion_options(Global.get_editor().get_text_for_code_completion())
	Global.get_editor().update_code_completion_options(false)


## Loads mode features, including:[br]
## • Syntax highlighter[br]
## • Comment delimiters[br]
## • String delimiters[br]
## • Mode panel[br]
## • Preview[br]
## • Linting[br]
## • Outline
func _load_mode_features() -> void:
	_load_syntax_highlighter()
	_load_delimiters()
	_load_mode_panel()
	_update_preview()
	_lint_content()
	_update_outline()


## Updates file outline. Result will send to [signal SignalBus.outline_updated].
func _update_outline() -> void:
	await get_tree().process_frame
	var mode_script := _get_mode_script()
	if not mode_script:
		Signals.outline_updated.emit(Array())
		return
	Signals.outline_updated.emit(mode_script._generate_outline(Global.get_editor_text()))


## Updates problem list. Result will send to [signal SignalBus.problems_updated].
func _lint_content() -> void:
	await get_tree().process_frame
	var mode_script := _get_mode_script()
	if not mode_script:
		Signals.problems_updated.emit(Array([], TYPE_DICTIONARY, "", null))
		return
	Signals.problems_updated.emit(mode_script._lint_file(Global.get_editor_text()))


## Updates preview. Result will send to [signal SignalBus.preview_updated].
func _update_preview() -> void:
	await get_tree().process_frame
	var mode_script := _get_mode_script()
	if not mode_script:
		Signals.preview_updated.emit("")
		return
	Signals.preview_updated.emit(mode_script._generate_preview(Global.get_editor_text()))


## Unloads old mode panel and loads new panel.
func _load_mode_panel() -> void:
	if mode_panel:
		Global.get_panel_manager().remove_panel(PanelManager.Panels.LEFT, mode_panel.index)
	var mode_script := _get_mode_script()
	if not mode_script:
		return
	if mode_script.panel:
		mode_panel = mode_script.panel
		Global.get_panel_manager().add_panel(
			mode_script.panel,
			ImageTexture.create_from_image(Image.load_from_file(S.globalize_path(
				S.TEMPLATE_MODE_ICON.format([current_mode["id"]])
			)))
		)


## Loads string and comment delimiters. Uses [member TextForgeMode.comment_delimiters] and
## [member TextForgeMode.string_delimiters] and will skip items with invalid pattern.
func _load_delimiters() -> void:
	var mode_script := _get_mode_script()
	if not mode_script:
		Global.get_editor().syntax_highlighter = null
		return
	Global.get_editor().clear_comment_delimiters()
	Global.get_editor().clear_string_delimiters()
	for d in mode_script.comment_delimiters:
		if d.keys() != ["start_key", "end_key", "line_only"]:
			continue
		Global.get_editor().add_comment_delimiter(d["start_key"], d["end_key"], d["line_only"])
	for d in mode_script.string_delimiters:
		if d.keys() != ["start_key", "end_key", "line_only"]:
			continue
		Global.get_editor().add_string_delimiter(d["start_key"], d["end_key"], d["line_only"])


## Loads syntax highlighter to editor, will NOT duplicate it.
func _load_syntax_highlighter() -> void:
	var mode_script := _get_mode_script()
	if not mode_script:
		Global.get_editor().syntax_highlighter = null
		return
	Global.get_editor().syntax_highlighter = mode_script.syntax_highlighter


## Unloads current mode script, panel, highlighter, linting, preview, outline, and delimiters.
func _unload_current_mode() -> void:
	if current_mode == {}:
		return
	var current_mode_script := _get_mode_script()
	if current_mode_script:
		current_mode_script.queue_free()
	if mode_panel:
		Global.get_panel_manager().remove_panel(mode_panel.place, mode_panel.index)
		mode_panel = null
	Global.get_editor().syntax_highlighter = null
	Signals.problems_updated.emit(Array([], TYPE_DICTIONARY, "", null))
	Signals.outline_updated.emit([])
	Signals.preview_updated.emit("")
	Global.get_editor().clear_comment_delimiters()
	Global.get_editor().clear_string_delimiters()
	current_mode = {}


## Changes mode to given [param mode]. Will load script, catchs current script, try to initialize
## new script and handle errors.
func _change_mode_to(mode: Dictionary) -> Error:
	if mode == current_mode:
		return OK
	var new_mode_script := U.load_resource(S.TEMPLATE_MODE_SCRIPT.format([mode["id"]])).new() as TextForgeMode
	if not new_mode_script:
		return ERR_INVALID_DATA
	# Cache current mode script for fallback
	if get_child_count():
		var current_mode_script := _get_mode_script()
		self.remove_child(current_mode_script)
		Global.add_child(current_mode_script)
		Global.temprory_children["current_mode_script"] = current_mode_script
	add_child(new_mode_script)
	new_mode_script.name = mode["id"]
	var initialize_error := new_mode_script._initialize_mode()
	if initialize_error:
		self.remove_child(new_mode_script)
		new_mode_script.queue_free()
	if Global.temprory_children.has("current_mode_script"):
		# Remove catched mode script
		if initialize_error == OK:
			Global.temprory_children["current_mode_script"].queue_free()
		# Restore catched mode script
		else:
			var current_mode_script: TextForgeMode = Global.temprory_children["current_mode_script"]
			Global.remove_child(current_mode_script)
			self.add_child(current_mode_script)
		Global.temprory_children.erase("current_mode_script")
	if initialize_error == OK:
		current_mode = mode
		_load_mode_features()
		Signals.mode_changed.emit(current_mode)
	return initialize_error


## Handles save file with current mode. Makes base directory recursive.
func _handle_save_file(file_path: String) -> void:
	var mode_script := _get_mode_script()
	if not mode_script:
		Notif.notif(
			"mode_script_not_found",
			{"text": "No instructions to save, Saving failed."}
		)
		return
	DirAccess.make_dir_recursive_absolute(S.globalize_path(file_path.get_base_dir()))
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		Notif.notif(
			"save_file_failed",
			{"format_title": ["this file"], "text_append": error_string(FileAccess.get_open_error())}
		)
		return
	file.store_buffer(mode_script._string_to_buffer(Global.get_editor_text()))
	Global.get_core().append_to_recent_files(file_path)
	file.close()
	_save_bookmarks()
	Signals.check_options.emit()


## Saves bookmarks based on file path in editor data or project file.
func _save_bookmarks() -> void:
	var bookmarks := Global.get_editor().get_bookmarked_lines()
	var data: Dictionary[String, PackedInt32Array]
	if Project.has_project():
		data = Project.current_project.get_value(
			"files",
			"bookmarks",
			Dictionary({}, TYPE_STRING, "", null, TYPE_PACKED_INT32_ARRAY, "", null)
		)
	else:
		data = Settings.read_data(
			"files",
			"bookmarks",
			Dictionary({}, TYPE_STRING, "", null, TYPE_PACKED_INT32_ARRAY, "", null)
		)
	data[Global.get_file_path()] = bookmarks
	if Project.has_project():
		Project.current_project.set_value("files", "bookmarks", data)
		Project.current_project.save(Project.get_current_project_path())
	else:
		Settings.write_data("files", "bookmarks", data)


## Handles load file with current mode. Makes base directory recursive.
func _handle_load_file(file_path: String) -> void:
	var mode_script := _get_mode_script()
	if not mode_script:
		Notif.notif(
			"mode_script_not_found",
			{"text": "No instructions to load, Loading failed."}
		)
		return
	DirAccess.make_dir_recursive_absolute(S.globalize_path(file_path.get_base_dir()))
	var buffer := FileAccess.get_file_as_bytes(file_path)
	if FileAccess.get_open_error():
		Notif.notif(
			"open_file_failed",
			{"format_title": [file_path], "text_append": error_string(FileAccess.get_open_error())}
		)
		return
	Global.set_editor_text(mode_script._buffer_to_string(buffer))
	Global.get_core().append_to_recent_files(file_path)
	Global.set_editor_disabled(false)
	_load_bookmarks()
	Signals.check_options.emit()
	Global.get_editor().type_timer_timeout.emit()
	update_indentation_settings()


## Loads bookmarks based on file path from project file or editor data.
func _load_bookmarks() -> void:
	var data: Dictionary[String, PackedInt32Array]
	if Project.has_project():
		data = Project.current_project.get_value(
			"files",
			"bookmarks",
			Dictionary({}, TYPE_STRING, "", null, TYPE_PACKED_INT32_ARRAY, "", null)
		)
	else:
		data = Settings.read_data(
			"files",
			"bookmarks",
			Dictionary({}, TYPE_STRING, "", null, TYPE_PACKED_INT32_ARRAY, "", null)
		)
	Global.get_editor().clear_bookmarked_lines()
	for i in data.get(Global.get_file_path(), []):
		Global.get_editor().set_line_as_bookmarked(i, true)


## Returns [code]true[/code] if [param file_path] extension is in [param mode] extensions.
func _is_mode_compatible(mode: Dictionary, file_path: String) -> bool:
	if mode == {}:
		return false
	return file_path.get_extension() in mode["extensions"]


## Returns current loaded mode script or [code]null[/code].
func _get_mode_script() -> TextForgeMode:
	var mode_script: TextForgeMode
	if get_child_count() == 0:
		mode_script = null
	else:
		mode_script = get_child(0) as TextForgeMode
	return mode_script


## Updates indentation settings. When [param use_mode] is [code]true[/code] uses overriden
## configuration based on [member custom_mode_indentations] or original settings in mode script.
## Otherwise uses editor settings.
func update_indentation_settings(use_mode := true) -> void:
	if Settings.get_setting("edit", "lock_indentation_settings", false):
		return
	var use_spaces: bool
	var indent_size: int
	if not use_mode:
		use_spaces = Settings.get_setting("edit", "indent_with_space")
		indent_size = Settings.get_setting("edit", "indent_size")
	else:
		if current_mode.has("id") and custom_mode_indentations.has(current_mode.id):
			use_spaces = custom_mode_indentations[current_mode.id]["use_spaces"]
			indent_size = custom_mode_indentations[current_mode.id]["indent_size"]
		else:
			var mode_script := _get_mode_script()
			if not mode_script:
				Notif.notif(
					"mode_script_not_found",
					{"text": "No information to use, Updating indentation settings failed."}
				)
				return
			if mode_script.indent_type == TextForgeMode.INDENT_TYPE.DISABLE:
				use_spaces = Settings.get_setting("edit", "indent_with_space")
			else:
				use_spaces = mode_script.indent_type == TextForgeMode.INDENT_TYPE.SPACE
			if mode_script.indent_size < 1:
				indent_size = Settings.get_setting("edit", "indent_size")
			else:
				indent_size = mode_script.indent_size
	Global.get_editor().indent_use_spaces = use_spaces
	Global.get_editor().indent_size = indent_size
	indentation_settings_updated.emit(use_spaces, indent_size)


## Removes overriden settings for current mode.
func reset_to_mode_indentation_settings() -> void:
	if not current_mode.has("id"):
		return
	if custom_mode_indentations.has(current_mode.id):
		custom_mode_indentations.erase(current_mode.id)
		Settings.write_data("mode_settings", "indentations", custom_mode_indentations)
		update_indentation_settings()


## Changes indentation type between spaces and tabs based on current editor state. When there is a
## loaded mode will add overriden settings for current mode. Otherwise, will change editor settings.
func change_indentation_type(use_spaces: bool) -> void:
	if not current_mode.has("id"):
		Settings.set_setting("edit", "indent_with_space", use_spaces)
		update_indentation_settings(false)
		return
	if custom_mode_indentations.has(current_mode.id):
		custom_mode_indentations[current_mode.id]["use_spaces"] = use_spaces
	else:
		var mode_script := _get_mode_script()
		if not mode_script:
			Notif.notif(
				"mode_script_not_found",
				{"text": "No information to use, Changing indentation type failed."}
			)
			return
		custom_mode_indentations[current_mode.id] = {
			"use_spaces": use_spaces,
			"indent_size": (
				mode_script.indent_size
				if mode_script.indent_size > 0
				else Settings.get_setting("edit", "indent_size")
			)
		}
	Settings.write_data("mode_settings", "indentations", custom_mode_indentations)
	update_indentation_settings()


## Changes indentation size (number of spaces or width of each tab) based on current editor state.
## When there is a loaded mode will add overriden settings for current mode. Otherwise, will change
## editor settings.
func change_indent_size(indent_size: int) -> void:
	if indent_size < 1:
		Notif.notif("invalid_indent_size")
		return
	if not current_mode.has("id"):
		Settings.set_setting("edit", "indent_size", indent_size)
		update_indentation_settings(false)
		return
	if custom_mode_indentations.has(current_mode.id):
		custom_mode_indentations[current_mode.id]["indent_size"] = indent_size
	else:
		var mode_script := _get_mode_script()
		if not mode_script:
			Notif.notif(
				"mode_script_not_found",
				{"text": "No information to use, Changing indent size failed."}
			)
			return
		var use_spaces_value: bool
		if mode_script.indent_type == TextForgeMode.INDENT_TYPE.DISABLE:
			use_spaces_value = Settings.get_setting("edit", "indent_with_space")
		else:
			use_spaces_value = mode_script.indent_type == TextForgeMode.INDENT_TYPE.SPACE
		custom_mode_indentations[current_mode.id] = {
			"use_spaces": use_spaces_value,
			"indent_size": indent_size
		}
	Settings.write_data("mode_settings", "indentations", custom_mode_indentations)
	update_indentation_settings()
