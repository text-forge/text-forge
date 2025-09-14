class_name EditorAPI
extends Control
## Editor API and Mode Manager.
##
## This node is first child of [Editor] and designed to manage modes. Access way: [code]Global.get_editor_api()[/code]

## Emits when a mode selected from available modes, this is a delay system and restore choice when
## there is more than one mode for current file.
signal mode_selected(index: int)

## Keeps list of all modes informations without damaged modes.
var mode_list: Array[Dictionary] = []
## Keeps information of current mode from [member mode_list].
var current_mode: Dictionary = {}
## Keeps panel of currently in use mode.
var mode_panel: TextForgePanel
# Keeps temprory index of selected mode.
var _temp_mode_index: int = 0

func _ready() -> void:
	child_order_changed.connect(func(): Signals.module_profiler_refresh.emit())
	mode_selected.connect(func(index): _temp_mode_index = index - 1)
	Global.get_editor().type_timer_timeout.connect(_update_preview)
	Global.get_editor().type_timer_timeout.connect(_update_outline)
	Global.get_editor().type_timer_timeout.connect(_lint_content)

	_load_mode_list()


## Loads [member mode_list], will fill [member GlobalAccess.damaged_modes] with failed modes.
## This function have file existence check, [ConfigFile] error handling, config section and key
## validation, and script class check. This function will add modes folder name to mode information
## dictionary and [code]"id"[/code].
func _load_mode_list() -> void:
	var damaged_modes: Dictionary[String, String] = {}

	for mode_folder: String in DirAccess.get_directories_at(FileDatabase.FOLDER_MODES):
		if not (FileAccess.file_exists(SLib.globalize_path(FileDatabase.TEMPLATE_MODE_INFO.format([mode_folder])))
		and FileAccess.file_exists(SLib.globalize_path(FileDatabase.TEMPLATE_MODE_SCRIPT.format([mode_folder])))
		and FileAccess.file_exists(SLib.globalize_path(FileDatabase.TEMPLATE_MODE_ICON.format([mode_folder])))):
			damaged_modes[mode_folder] = "Missing files"
			continue

		var config = ConfigFile.new()
		var err := config.load(SLib.globalize_path(FileDatabase.TEMPLATE_MODE_INFO.format([mode_folder])))

		if err:
			damaged_modes[mode_folder] = "Load config failed"
			continue
		if Array(config.get_sections()) != ["mode"]:
			damaged_modes[mode_folder] = "Invalid sections"
			continue
		if Array(config.get_section_keys("mode")) != ["name", "description", "author", "version", "extensions"]:
			damaged_modes[mode_folder] = "Invalid keys"
			continue
		if not is_instance_of(Global.load_resource(FileDatabase.TEMPLATE_MODE_SCRIPT.format([mode_folder])).new(), TextForgeMode):
			damaged_modes[mode_folder] = "Invalid script"
			continue

		var mode: Dictionary[String, Variant] = {"id": mode_folder}
		for key: String in config.get_section_keys("mode"):
			mode[key] = config.get_value("mode", key)

		mode_list.append(mode)

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
		Global.send_notification(Global.Notification.ERROR, "Failed to load some modes!", damaged_modes_string)


## Reload all modes with [method _load_mode_list].
func reload_modes() -> void:
	mode_list = []
	_load_mode_list()


## Handle file saving from mode selection to correct mode encode system and then to targe file.
## Will use current mode if is compatible (based on [method _is_mode_compatible]), otherwise will
## use [method _is_mode_compatible] to filter modes and select one of them. Three situation can heppend:[br]
## - [b]There is no compatible mode:[/b] Will [method _unload_current_mode] and use
## [method FileAccess.store_string].[br]
## - [b]There is one compatible mode:[/b] Will [method _change_mode_to] and use
## [method _handle_save_file] and [method _load_mode_features].[br]
## - [b]There is more than one compatible mode:[/b] Will show popup menu for select mode then use
## [method _change_mode_to] and [method _handle_save_file] and [method _load_mode_features].[br][br]
## If there is any error in [method _change_mode_to] (see [method TextForgeMode._initialize_mode])
## will fail with [i]Failed to initialize mode for save[/i].
func save_file(file_path: String) -> void:
	var mode := current_mode

	if not _is_mode_compatible(current_mode, file_path):
		var compatible_modes := mode_list.filter(func(m): return _is_mode_compatible(m, file_path))

		match compatible_modes.size():
			0:
				Global.send_notification(Global.Notification.WARNING, "Can't find any mode to save this file.", "Save file using UTF-8...")
				_unload_current_mode()

				var file = FileAccess.open(file_path, FileAccess.WRITE)
				if FileAccess.get_open_error():
					Global.send_notification(Global.Notification.ERROR, "Failed to open file!", "Save in {0} failed with error code {1}".format([file_path, FileAccess.get_open_error()]))
					return
				file.store_string(Global.get_editor_text())
				Global.get_core().append_to_recent_files(file_path)
				file.close()

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
		Global.send_notification(Global.Notification.ERROR, "Failed to initialize mode {0} for save!".format([mode["name"]]))


## Handle file loading from mode selection to targe file and then to correct mode decode system and editor.
## This method have same logic as [method save_file].
func load_file(file_path: String) -> void:
	if file_path.get_extension().to_lower() == "tfproj":
		Project.load_project(file_path)
		return
	var mode := current_mode

	if not _is_mode_compatible(current_mode, file_path):
		var compatible_modes := mode_list.filter(func(m): return _is_mode_compatible(m, file_path))

		match compatible_modes.size():
			0:
				Global.send_notification(Global.Notification.WARNING, "Can't find any mode to open this file.", "Load file using UTF-8...")
				_unload_current_mode()

				Global.set_editor_text(FileAccess.get_file_as_string(file_path))
				Global.get_core().append_to_recent_files(file_path)
				Global.set_editor_disabled(false)
				if FileAccess.get_open_error():
					Global.send_notification(Global.Notification.ERROR, "Error in opening file!", "Load from {0} completed with error code {1}".format([file_path, FileAccess.get_open_error()]))

				Signals.check_options.emit()
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
		Global.send_notification(Global.Notification.ERROR, "Failed to initialize mode {0} for load!".format([mode["name"]]))


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
	_handle_lsp()
	_load_syntax_highlighter()
	_load_delimiters()
	_load_mode_panel()
	_update_preview()
	_lint_content()
	_update_outline()


func _handle_lsp() -> void:
	LSP.shutdown()
	var mode_script := _get_mode_script()
	if not mode_script:
		return
	if mode_script.get_property_list().any(func(p): return p["name"] == "lsp_host") and mode_script.get_property_list().any(func(p): return p["name"] == "lsp_port"):
		LSP.connect_to_server(mode_script.lsp_host as String, mode_script.lsp_port as int)


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
		Global.get_panel_manager().add_panel(PanelManager.Panels.LEFT, mode_script.panel,
				ImageTexture.create_from_image(Image.load_from_file(SLib.globalize_path(FileDatabase.TEMPLATE_MODE_ICON.format([current_mode["id"]]))))
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

	var new_mode_script: TextForgeMode = Global.load_resource(FileDatabase.TEMPLATE_MODE_SCRIPT.format([mode["id"]])).new() as TextForgeMode
	if not new_mode_script:
		return ERR_INVALID_DATA

	# Catch current mode script for fallback
	if get_child_count():
		var current_mode_script: TextForgeMode = get_child(0)
		self.remove_child(current_mode_script)
		Global.add_child(current_mode_script)
		Global.temprory_children["current_mode_script"] = current_mode_script

	add_child(new_mode_script)
	new_mode_script.name = mode["id"]
	var initialize_error := new_mode_script._initialize_mode()

	if initialize_error:
		self.remove_child(new_mode_script)

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
		Global.send_notification(Global.Notification.ERROR, "Can't find mode script!", "Saving failed.")
		return

	DirAccess.make_dir_recursive_absolute(SLib.globalize_path(file_path.get_base_dir()))
	var file := FileAccess.open(file_path, FileAccess.WRITE)

	if FileAccess.get_open_error():
		Global.send_notification(Global.Notification.ERROR, "Failed to open file!", "Save in {0} failed with error code {1}".format([file_path, FileAccess.get_open_error()]))
		return

	file.store_buffer(mode_script._string_to_buffer(Global.get_editor_text()))
	Global.get_core().append_to_recent_files(file_path)
	file.close()
	Signals.check_options.emit()


## Handles load file with current mode. Makes base directory recursive.
func _handle_load_file(file_path: String) -> void:
	var mode_script := _get_mode_script()
	if not mode_script:
		push_error("Load error")
		Global.send_notification(Global.Notification.ERROR, "Can't find mode script!", "Loading failed.")
		return

	DirAccess.make_dir_recursive_absolute(SLib.globalize_path(file_path.get_base_dir()))
	var buffer := FileAccess.get_file_as_bytes(file_path)

	if FileAccess.get_open_error():
		Global.send_notification(Global.Notification.ERROR, "Failed to open file!", "Load from {0} failed with error code {1}".format([file_path, FileAccess.get_open_error()]))
		return

	Global.set_editor_text(mode_script._buffer_to_string(buffer))
	Global.get_core().append_to_recent_files(file_path)
	Global.set_editor_disabled(false)
	Signals.check_options.emit()


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
