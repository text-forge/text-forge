class_name WindowManager
extends Node
## Window manager to restore window position, size, and mode.
##
## This is base class for instance in [member GlobalAccess.window_manager]. It can save and load
## last position, size and mode. inspired by:
## [url=https://gist.github.com/danijmn/75f83973315dd38fc2b288cf2ff582ea]this gist[/url].

## The section within the ConfigFile where the window settings will be saved.
const WINDOW_SECTION_ID: String = "window"

## Holds last mode except [constant Window.MODE_MINIMIZED]. This will be used for restore mode.
var _last_mode_except_minimized: Window.Mode
## Holds last mode except [constant Window.MODE_FULLSCREEN]. This will be used for back from
## fullscreen mode.
var last_mode_except_fullscreen: Window.Mode

## Main window root node.
@onready var _window: Window = get_window()

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

	var config = ConfigFile.new()
	if config.load(FileDatabase.DATA_FILE) != OK:
		return
	if not config.has_section(WINDOW_SECTION_ID):
		return

	var screen = config.get_value(WINDOW_SECTION_ID, "screen", "N/A")
	if screen is int and screen >= 0 and screen < DisplayServer.get_screen_count():
		_window.current_screen = screen

	var mode = config.get_value(WINDOW_SECTION_ID, "mode", "N/A")
	if mode is Window.Mode:
		match mode:
			Window.MODE_MAXIMIZED, Window.MODE_FULLSCREEN, Window.MODE_EXCLUSIVE_FULLSCREEN:
				_window.mode = mode
			Window.MODE_WINDOWED:
				var usable_rect: Rect2i = DisplayServer.screen_get_usable_rect(_window.current_screen)
				var size = config.get_value(WINDOW_SECTION_ID, "size", "N/A")
				if size is not Vector2i or size.x < _window.min_size.x or size.y < _window.min_size.y:
					_window.mode = Window.MODE_WINDOWED
				elif size.x > usable_rect.size.x and size.y > usable_rect.size.y:
					_window.mode = Window.MODE_MAXIMIZED
				else:
					_window.mode = Window.MODE_WINDOWED
					var position = config.get_value(WINDOW_SECTION_ID, "position", "N/A")
					if position is Vector2i:
						var safe_end: Vector2i = usable_rect.end.min(position + size)
						var safe_position: Vector2i = usable_rect.position.max(safe_end - size)
						var safe_size: Vector2i = _window.min_size.max(safe_end - safe_position)
						_window.position = safe_position
						_window.size = safe_size


func _save_window_settings() -> void:
	if Engine.is_embedded_in_editor():
		return

	var config = ConfigFile.new()
	config.set_value(WINDOW_SECTION_ID, "screen", _window.current_screen)
	if _window.mode != Window.MODE_MINIMIZED:
		config.set_value(WINDOW_SECTION_ID, "mode", _window.mode)
	else:
		config.set_value(WINDOW_SECTION_ID, "mode", _last_mode_except_minimized)
	config.set_value(WINDOW_SECTION_ID, "size", _window.size)
	config.set_value(WINDOW_SECTION_ID, "position", _window.position)
	config.save(FileDatabase.DATA_FILE)
