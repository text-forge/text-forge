class_name GlobalAccess
extends Node
## Global access way to all parts of Text Forge.
##
## You can access to this class using [code]Global[/code] autoload.

## @deprecated: Please use [enum NotificationManager.Type] instead.
## Type of [b]Editor Notification[/b]s, see also [method send_notification] and
## [signal SignalBus.editor_notification].
enum Notification {
	INFO, ## Regular notification with "Information" type.
	WARNING, ## Warning notification, for exceptions without silent handling (but with handling).
	ERROR, ## Error notification, for unhandled exceptions.
}

## Main window manager with restore window state. See [WindowManager] for more information.
var window_manager := WindowManager.new()
## Keeps list of damaged mode IDs and reasons.
var damaged_modes: Dictionary[String, String] = {}
## Keeps map to shortcuts for action scripts.
var shortcut_map: ShortcutMap
## Dictionary of all commands. example item:
## [codeblock]
## # Command Name (String): [Shortcut as Text (String), Command Action (Callable)]
## "Close": ["Ctrl+W", close_action_script._run_action]
## [/codeblock]
## See [method define_command] for more information.
var commands: Dictionary[String, Array] = {}:
	get = get_command_list
## Keeps temprory nodes for catch or transfer.
var temprory_children: Dictionary[String, Node] = {}
var _core: Core
var _editor: Editor
var _file_label: Label

# Initializing function
func _ready() -> void:
	shortcut_map = U.load_resource("res://data/shortcuts.tres") as ShortcutMap
	window_manager._window = get_window()
	window_manager._ready()
	if has_node("/root/Main"):
		_core = get_node("/root/Main") as Core
		_editor = _core.editor
		_file_label = _core.file_label
	else:
		print_rich("[color=webgray]--- Global is in test mode ---[/color]")
		_core = load("res://core/main.tscn").instantiate()
		_editor = _core.editor
		_file_label = _core.file_label


## Returns last window mode but [constant Window.MODE_FULLSCREEN] excluded.[br][br]
## [b]Note:[/b] [WindowManager] will exclude [constant Window.MODE_MINIMIZED] itself; See
## [WindowManager] for more information.
func get_window_mode_before_fullscreen() -> Window.Mode:
	return window_manager.last_mode_except_fullscreen


## Returns currently opened file path, this is tooltip of [member Core.file_label] that user can see
## it with hover on file name in editor.
func get_file_path() -> String:
	return _file_label.tooltip_text


## Returns currently opened file name, this is text of [member Core.file_label].
func get_file_name() -> String:
	return _file_label.text


## Sets [param path] as path of opened file with set it as tooltip of [member Core.file_label].[br][br]
## [b]Note:[/b] This action isn't loading!
func set_file_path(path: String) -> void:
	_file_label.tooltip_text = path


## Sets [param file_name] as name of opened file with set it as text of [member Core.file_label].[br][br]
## [b]Note:[/b] There is no connection between this function and [method set_file_path].
func set_file_name(file_name: String) -> void:
	_file_label.text = file_name


## Returns [code]true[/code] when there is an opened file.
func has_file() -> bool:
	return get_file_path().is_absolute_path()


## Returns editor node, it's accessable with [member Core.editor] too.
func get_editor() -> Editor:
	return _editor


## Returns current text in editor with get [method TextEdit.get_text].
func get_editor_text() -> String:
	return _editor.get_text()


## Sets [param text] as text of [Editor] [CodeEdit]. If [param keep_carets] is [code]false[/code],
## this actiona will move caret to start of text. If [code]true[/code] all carets and selection
## origins will restore automatically. (This action is based on line and column, so if your change
## containes line/column changing (for example line merging) you can set it to [code]false[/code]
## and do caret restoring yourself.
func set_editor_text(text: String, keep_carets: bool = true) -> void:
	var carets: Array[Rect2i] = []
	var scroll: Vector2
	if keep_carets:
		for index in _editor.get_caret_count():
			var selection := Rect2i()
			selection.position = Vector2i(_editor.get_selection_origin_line(index), _editor.get_selection_origin_column(index))
			selection.size = Vector2i(_editor.get_caret_line(index), _editor.get_caret_column(index))
			carets.append(selection)
		scroll = Vector2(_editor.scroll_horizontal, _editor.scroll_vertical)
	_editor.text = text
	if keep_carets:
		for idx: int in carets.size():
			var selection := carets[idx] as Rect2i
			if idx >= _editor.get_caret_count():
				_editor.add_caret(0, 0)
			_editor.select(selection.position.x, selection.position.y, selection.size.x, selection.size.y, idx)
		_editor.scroll_horizontal = scroll.x
		_editor.scroll_vertical = scroll.y


## Will disable the editor if [param disabled] is [code]true[/code].
func set_editor_disabled(disabled: bool) -> void:
	_editor.editable = not disabled


## Returns [code]true[/code] if editor is disabled.
func is_editor_disabled() -> bool:
	return not _editor.editable


## Returns [Core] node, this is root of main scene in main window. See [Core] for more information.
func get_core() -> Core:
	return _core


## Returs node in [Core] that keep action scripts, it's useful when you need find an action script
## without its [code]id[/code].
func get_scripts_node() -> Node:
	return _core.scripts


## Returns [EditorAPI] node, this is first child of [Editor] node after internal childs. See
## [EditorAPI] for more information.
func get_editor_api() -> EditorAPI:
	return _editor.get_child(0) as EditorAPI


## Return [PanelManager] node, this is a container with all panels, tabs, and [Editor]. See
## [PanelManager] for more information.
func get_panel_manager() -> PanelManager:
	return _core.panel_manager


## @deprecated: Please use [method NotificationManager.notif] instead.
## Sends an [b]Editor Notification[/b] using emit [signal SignalBus.editor_notification].
func send_notification(type: Notification, title: String, text: String = "") -> void:
	U.deprecated()
	const map = {
		Notification.INFO: Notif.Type.INFO,
		Notification.WARNING: Notif.Type.WARN,
		Notification.ERROR: Notif.Type.ERR,
	}
	Signals.editor_notification.emit(map[type], title, text)


## Defines new command and updates [member _commands]. Commands shoud have a unique
## [param command_name] (otherwise this would be an overwrite of this command), you can generate
## [param key_string] with [method InputEventKey.as_text_keycode]. Command managers (like command
## pallete) will run [param callable] if user select this command. see [meber _commands] for
## commands saving structure.
func define_command(command_name: String, key_string: String, callable: Callable) -> void:
	commands[command_name] = [key_string, callable]


## Returns all commands saved in [member _commands].
func get_command_list() -> Dictionary:
	return commands


## Returns [code]true[/code] if there is unsaved change, when opened file have unsaved change a star
## ([code]*[/code]) will append to its name. (See also [method get_file_name])
func has_unsaved_change() -> bool:
	return get_file_name().ends_with("*")


## Returns last stored file path in [constant S.RECENT_FILES_DATA] or [code]""[/code].
func get_last_file_path() -> String:
	if not FileAccess.file_exists(S.globalize_path(S.RECENT_FILES_DATA)):
		return ""
	var file_access = FileAccess.open(S.RECENT_FILES_DATA, FileAccess.READ)
	var recent_files_list := file_access.get_as_text().split("\n", false)
	file_access.close()

	if recent_files_list:
		return recent_files_list[0]

	return ""


## @deprecated: Use [method Utils.load_resource] instead.
func load_resource(path: String) -> Resource:
	U.deprecated()
	return U.load_resource(path)


## Appends [code]*[/code] to file name to show it's changed.
func mark_file_as_unsaved() -> void:
	if not (Global.has_unsaved_change() or Global.is_editor_disabled()):
		_file_label.text += "*"


## Emits [signal SignalBus.save_request] when there is any unsaved change and returns [code]true[/code],
## otherwise just returns [code]false[/code].
func emit_save_request(from_id: int) -> bool:
	if Global.has_unsaved_change():
		Signals.save_request.emit(from_id)
		return true
	return false


class WindowManager:
	## Window manager to restore window position, size, and mode.
	##
	## This is base class for instance in [member GlobalAccess.window_manager]. It can save and load
	## last position, size and mode. inspired by:
	## [url=https://gist.github.com/danijmn/75f83973315dd38fc2b288cf2ff582ea]this gist[/url].

	## The section within the ConfigFile where the window settings will be saved.
	const WINDOW_SECTION_ID = "window"

	## Holds last mode except [constant Window.MODE_FULLSCREEN]. This will be used for back from
	## fullscreen mode.
	var last_mode_except_fullscreen: Window.Mode
	## Holds last mode except [constant Window.MODE_MINIMIZED]. This will be used for restore mode.
	var _last_mode_except_minimized: Window.Mode

	## Main window root node.
	var _window: Window

	func _ready() -> void:
		if Engine.is_embedded_in_editor():
			return
		_window.close_requested.connect(_save_window_settings)
		_load_window_settings()
		if _window.mode != Window.MODE_MINIMIZED:
			_last_mode_except_minimized = _window.mode
			if _window.mode != Window.MODE_FULLSCREEN:
				last_mode_except_fullscreen = _window.mode


	func _process(_delta: float) -> void:
		if Engine.is_embedded_in_editor():
			return
		if _window.mode != Window.MODE_MINIMIZED:
			_last_mode_except_minimized = _window.mode
			if _window.mode != Window.MODE_FULLSCREEN:
				last_mode_except_fullscreen = _window.mode


	func _load_window_settings() -> void:
		if Engine.is_embedded_in_editor():
			return
		if not Settings.data.has_section(WINDOW_SECTION_ID):
			return
		var screen = Settings.read_data(WINDOW_SECTION_ID, "screen", "N/A")
		if screen is int and screen >= 0 and screen < DisplayServer.get_screen_count():
			_window.current_screen = screen
		var mode = Settings.read_data(WINDOW_SECTION_ID, "mode", "N/A")
		if mode is Window.Mode:
			match mode:
				Window.MODE_MAXIMIZED, Window.MODE_FULLSCREEN, Window.MODE_EXCLUSIVE_FULLSCREEN:
					_window.mode = mode
				Window.MODE_WINDOWED:
					var usable_rect: Rect2i = DisplayServer.screen_get_usable_rect(_window.current_screen)
					var size = Settings.read_data(WINDOW_SECTION_ID, "size", "N/A")
					if size is not Vector2i or size.x < _window.min_size.x or size.y < _window.min_size.y:
						_window.mode = Window.MODE_WINDOWED
					elif size.x > usable_rect.size.x and size.y > usable_rect.size.y:
						_window.mode = Window.MODE_MAXIMIZED
					else:
						_window.mode = Window.MODE_WINDOWED
						var position = Settings.read_data(WINDOW_SECTION_ID, "position", "N/A")
						if position is Vector2i:
							var safe_end: Vector2i = usable_rect.end.min(position + size)
							var safe_position: Vector2i = usable_rect.position.max(safe_end - size)
							var safe_size: Vector2i = _window.min_size.max(safe_end - safe_position)
							_window.position = safe_position
							_window.size = safe_size


	func _save_window_settings() -> void:
		if Engine.is_embedded_in_editor():
			return
		Settings.write_data(WINDOW_SECTION_ID, "screen", _window.current_screen)
		if _window.mode != Window.MODE_MINIMIZED:
			Settings.write_data(WINDOW_SECTION_ID, "mode", _window.mode)
		else:
			Settings.write_data(WINDOW_SECTION_ID, "mode", _last_mode_except_minimized)
		Settings.write_data(WINDOW_SECTION_ID, "size", _window.size)
		Settings.write_data(WINDOW_SECTION_ID, "position", _window.position)
