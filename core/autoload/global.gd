class_name GlobalAccess
extends Node
## Global access way to all parts of Text Forge.
##
## You can access to this class using [code]Global[/code] autoload.

## Type of [b]Editor Notification[/b]s, see also [method send_notification] and
## [signal SignalBus.editor_notification].
enum Notification {
	INFO, ## Regular notification with "Information" type.
	WARNING, ## Warning notification, for exceptions without silent handling (but with handling).
	ERROR, ## Error notification, for unhandled exceptions.
}

## Main window manager with restore window state. See [WindowManager] for more information.
var window_manager := WindowManager.new()
## Dictionary of all commands. example item:
## [codeblock]
## # Command Name (String): [Shortcut as Text (String), Command Action (Callable)]
## "Close": ["Ctrl+W", close_action_script._run_action]
## [/codeblock]
## See [method define_command] for more information.
var _commands: Dictionary[String, Array] = {}:
	get = get_command_list


# Initializing function
func _ready() -> void:
	add_child(window_manager)


## Returns last window mode but [constant Window.MODE_FULLSCREEN] excluded.[br][br]
## [b]Note:[/b] [WindowManager] will exclude [constant Window.MODE_MINIMIZED] itself; See
## [WindowManager] for more information.
func get_window_mode_before_fullscreen() -> Window.Mode:
	return window_manager.last_mode_except_fullscreen


## Returns currently opened file path, this is tooltip of [member Core.file_label] that user can see
## it with hover on file name in editor.
func get_file_path() -> String:
	return get_core().file_label.tooltip_text


## Returns currently opened file name, this is text of [member Core.file_label].
func get_file_name() -> String:
	return get_core().file_label.text


## Sets [param path] as path of opened file with set it as tooltip of [member Core.file_label].[br][br]
## [b]Note:[/b] This action isn't loading!
func set_file_path(path: String) -> void:
	get_core().file_label.tooltip_text = path


## Sets [param file_name] as name of opened file with set it as text of [member Core.file_label].[br][br]
## [b]Note:[/b] There is no connection between this function and [method set_file_path].
func set_file_name(file_name: String) -> void:
	get_core().file_label.text = file_name


## Returns editor node, it's accessable with [member Core.editor] too.
func get_editor() -> Editor:
	return get_core().editor


## Returns current text in editor with get [method TextEdit.get_text].
func get_editor_text() -> String:
	return get_editor().get_text()


## Sets [param text] as text of [Editor] [CodeEdit]. If [param keep_carets] is [code]false[/code],
## this actiona will move caret to start of text. If [code]true[/code] all carets and selection
## origins will restore automatically. (This action is based on line and column, so if your change
## containes line/column changing (for example line merging) you can set it to [code]false[/code]
## and do caret restoring yourself.
func set_editor_text(text: String, keep_carets: bool = true) -> void:
	var carets: Array[Array] = []
	if keep_carets:
		for index in get_editor().get_caret_count():
			var origin := Vector2i(get_editor().get_selection_origin_line(index), get_editor().get_selection_origin_column(index))
			var caret := Vector2i(get_editor().get_caret_line(index), get_editor().get_caret_column(index))
			carets.append([origin, caret])
	get_editor().text = text
	if keep_carets:
		for idx in carets.size():
			var selection: Array = carets[idx]
			if idx >= get_editor().get_caret_count():
				get_editor().add_caret(0, 0)
			get_editor().select(selection[0].x, selection[0].y, selection[1].x, selection[1].y, idx)


## Will disable the editor if [param disabled] is [code]true[/code].
func set_editor_disabled(disabled: bool) -> void:
	get_editor().editable = not disabled


## Returns [code]true[/code] if editor is disabled.
func is_editor_disabled() -> bool:
	return not get_editor().editable


## Returns [Core] node, this is root of main scene in main window. See [Core] for more information.
func get_core() -> Core:
	if not is_inside_tree():
		return
	return get_node("/root/Main")


## Returs node in [Core] that keep action scripts, it's useful when you need find an action script
## without its [code]id[/code].
func get_scripts_node() -> Control:
	return get_core().scripts


## Returns [EditorAPI] node, this is first child of [Editor] node after internal childs. See
## [EditorAPI] for more information.
func get_editor_api() -> EditorAPI:
	return get_editor().get_child(0)


## Return [PanelManager] node, this is a container with all panels, tabs, and [Editor]. See
## [PanelManager] for more information.
func get_panel_manager() -> PanelManager:
	return get_core().panel_manager


## Sends an [b]Editor Notification[/b] using emit [signal SignalBus.editor_notification].
func send_notification(type := Notification.INFO, title: String = "", text: String = "") -> void:
	Signals.editor_notification.emit(type, title, text)


## Defines new command and updates [member _commands]. Commands shoud have a unique
## [param command_name] (otherwise this would be an overwrite of this command), you can generate
## [param key_string] with [method InputEventKey.as_text_keycode]. Command managers (like command
## pallete) will run [param callable] if user select this command. see [meber _commands] for
## commands saving structure.
func define_command(command_name: String, key_string: String, callable: Callable) -> void:
	_commands[command_name] = [key_string, callable]


## Returns all commands saved in [member _commands].
func get_command_list() -> Dictionary:
	return _commands


## Returns [code]true[/code] if there is unsaved change, when opened file have unsaved change a star
## ([code]*[/code]) will append to its name. (See also [method get_file_name])
func has_unsaved_change() -> bool:
	return get_file_name().ends_with("*")


## Returns last stored file path in [constant FileDatabase.RECENT_FILES_DATA] or [code]""[/code].
func get_last_file_path() -> String:
	var path := ""

	if FileAccess.file_exists(FileDatabase.RECENT_FILES_DATA):
		var file_access = FileAccess.open(FileDatabase.RECENT_FILES_DATA, FileAccess.READ)
		var recent_files_list = file_access.get_as_text().split("\n", false)
		file_access.close()

		if recent_files_list:
			path = recent_files_list[0]

	return path
