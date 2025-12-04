class_name Core
extends Control
# official repo: https://github.com/text-forge/text-forge
## Root node of main window.

## Available option types in menus.
enum OptionTypes {
	SEPARATOR = -1,
	REGULAR,
	SUBMENU,
	CHECKBOX,
	RADIO_CHECKBOX,
}

## Default window title.
const WINDOW_TITLE = "Text Forge"
## Section for menu data in config file.
const DATA_SECTION = "main_menu"
## Suffix for menu keys.
const MENU_SUFFIX = "_menu"
## Suffix for submenu keys.
const SUBMENU_SUFFIX = "_submenu"
## Prefix for menu names in translation file.
const MENU_TRANSLATION_PREFIX = "menu."

## [MenuBar] that will keep menu buttons. Menu buttons will be [PopupMenu]s (See [MenuBar] for more
## information).
@export var menu_container: MenuBar
## This [Label] will be placed between [member menu_container] and [member editor], its [param text]
## will be file name and its [param tooltip] will be file path.[br][br]
## - Setters: [method GlobalAccess.set_file_name], [method GlobalAccess.set_file_path][br]
## - Getters: [method GlobalAccess.get_file_name], [method GlobalAccess.get_file_path]
@export var file_label: Label
## Editor node, you can find more options in [Editor] class.
@export var editor: Editor
## Scripts Node, will keep action scripts separated from other nodes.
@export var scripts: Node
## [PanelManager] node, see class for more information.
@export var panel_manager: PanelManager
## About window.
@export var about: Window
## Module Profiler.
@export var module_profiler: MenuButton
## [ReplacePopup] for template completion.
@export var replace_popup: ReplacePopup
## Overlay to apply shader filter.
@export var overlay_shader: ColorRect

## Recent files [PopupMenu], see also [method _reload_recent_files].
var recent_files_submenu: PopupMenu
## Templates [PopupMenu], see also [method reload_templates].
var templates_submenu: PopupMenu
## Configurations loaded from [constant S.MAIN_UI_DATA].
var main_menu_data: Dictionary
## Protects [method _handle_settings] from multiple runs at same time.
var _is_reloading_settings := false
## Cached translation data with [method TextForgeTranslator.cache_source].
var _translation_data: Dictionary[String, Dictionary]

# This is start point of Text Forge
func _ready() -> void:
	# Change window name based on project name
	Project.project_opened.connect(func(): get_window().title = "%s - %s" % [Project.get_project_name(), WINDOW_TITLE])
	Project.project_closed.connect(func(): get_window().title = WINDOW_TITLE)
	# Connect module profiler signal
	scripts.child_order_changed.connect(Signals.refresh_module_profiler)
	# Open file with drag and drop feature
	get_window().files_dropped.connect(func(files: PackedStringArray): Signals.open_file.emit(files[0]))
	# Cache translation data
	_translation_data = TFT.cache_source(S.TRANSLATION_FILE)
	# Connect reload_recent_files request signal
	Signals.reload_recent_files.connect(_reload_recent_files)
	# Handle settings
	_initialize_themes() # Updating themes before loading settings
	_define_presets()
	_handle_settings()

	# Load action scripts
	# 1. Load menu structure data and then items
	_load_main_menu_data()
	_load_main_menu()
	# 3. Add post-initialize hook
	Signals.check_options.connect(_post_initialize, CONNECT_ONE_SHOT)
	# 4. Load action scripts
	_load_scripts()


## Updates theme folder with internal themes. Skips existing themes.
func _initialize_themes() -> void:
	# Make directory
	if not DirAccess.dir_exists_absolute(S.globalize_path(S.FOLDER_THEMES)):
		DirAccess.make_dir_recursive_absolute(S.globalize_path(S.FOLDER_THEMES))
	# Check each internal theme
	for t in DirAccess.get_files_at(S.FOLDER_INTERNAL_THEMES):
		if t.get_extension().to_lower() != "tres" or FileAccess.file_exists(S.FOLDER_THEMES.path_join(t)):
			continue
		# Copy theme
		var file := FileAccess.open(S.FOLDER_THEMES.path_join(t), FileAccess.WRITE)
		if not file:
			Global.send_notification(
				Global.Notification.ERROR,
				"Failed to create theme file at %s" % S.FOLDER_THEMES.path_join(t)
			)
			continue
		file.store_buffer(FileAccess.get_file_as_bytes(S.FOLDER_INTERNAL_THEMES.path_join(t)))
		file.close()


## Defines core-related presets.
func _define_presets() -> void:
	# Define presets
	# 1. Load last file at start
	Settings.define_preset("files", "load_last_file_at_start", true)
	Settings.define_preset("files", "ask_before_load_last_file_at_start", false)
	Settings.define_preset("notifications", "automatic_load_last_file_at_start", true)
	# 2. Indentation
	Settings.define_preset("edit", "indent_with_space", false)
	Settings.define_preset("edit", "indent_size", 4)
	# 3. Theme
	Settings.define_preset("editor_ui", "theme_name", "dark")
	# 4. UI Filter
	Settings.define_preset("editor_ui", "filter_hue_shift", 0.0)
	Settings.define_preset("editor_ui", "filter_saturation", 1.0)
	Settings.define_preset("editor_ui", "filter_brightness", 1.0)


## Loads core-related settings. This function supports dynamic reload for mode, theme, and indentation.
func _handle_settings() -> void:
	if _is_reloading_settings:
		return
	_is_reloading_settings = true
	# Connect dynamic reload
	if not Signals.settings_changed.is_connected(_handle_settings):
		Signals.settings_changed.connect(_handle_settings)
	# Load settings
	# 1. Indentation
	Global.get_editor_api().update_indentation_settings(false)
	# 2. Theme
	if not FileAccess.file_exists(S.TEMPLATE_THEME.format([Settings.get_setting("editor_ui", "theme_name")])):
		Settings.restore_default("editor_ui", "theme_name")
	get_window().set_theme(U.load_resource(S.TEMPLATE_THEME.format([Settings.get_setting("editor_ui", "theme_name")])))
	# 3. Mode reload
	var current_mode := Global.get_editor_api().current_mode
	if current_mode:
		Global.get_editor_api()._unload_current_mode()
		await U.wait()
		Global.get_editor_api()._change_mode_to(current_mode)
	_is_reloading_settings = false
	# 4. UI Filter
	overlay_shader.material.set_shader_parameter("hue_shift", Settings.get_setting("editor_ui", "filter_hue_shift"))
	overlay_shader.material.set_shader_parameter("saturation", Settings.get_setting("editor_ui", "filter_saturation"))
	overlay_shader.material.set_shader_parameter("brightness", Settings.get_setting("editor_ui", "filter_brightness"))


## Loads data in [member main_menu_data], uses [constant S.MAIN_UI_DATA] and [constant DATA_SECTION].
func _load_main_menu_data() -> void:
	var config := ConfigFile.new()
	config.load(S.globalize_path(S.MAIN_UI_DATA))
	for menu_section: String in config.get_section_keys(DATA_SECTION):
		main_menu_data[menu_section] = config.get_value(DATA_SECTION, menu_section) as Array


## This function will load data from UI source and generate buttons.
func _load_main_menu() -> void:
	# For each menu
	for menu_item: String in main_menu_data:
		# Skip next steps for submenu items
		if menu_item.ends_with(SUBMENU_SUFFIX):
			continue
		# Items of current menu
		var current_menu: Array = main_menu_data.get(menu_item)
		# Create new menu button
		var new_menu_button := PopupMenu.new()
		# English menu name, remove menu suffix and capitalize it
		var menu_name: String = menu_item.trim_suffix(MENU_SUFFIX)
		menu_name = menu_name.capitalize()
		# Translate name
		new_menu_button.name = TFT.get_text_from_cache(
			MENU_TRANSLATION_PREFIX + menu_name.to_snake_case(),
			_translation_data,
		)
		# For each option in current menu
		for item: Dictionary in current_menu:
			# Set item "popup", see _load_scripts for use case
			main_menu_data[menu_item][current_menu.find(item)]["popup"] = new_menu_button
			# Translate text
			var item_text := TFT.get_text_from_cache(item.get("key", ""), _translation_data)
			# Add item
			match item.get("type", OptionTypes.REGULAR):
				OptionTypes.REGULAR:
					new_menu_button.add_item(item_text, item.get("code", -1))
				OptionTypes.SUBMENU:
					_create_submenu(new_menu_button, item)
				OptionTypes.SEPARATOR:
					new_menu_button.add_separator(item_text)
				OptionTypes.CHECKBOX:
					new_menu_button.add_check_item(item_text, item.get("code", -1))
				OptionTypes.RADIO_CHECKBOX:
					new_menu_button.add_radio_check_item(item_text, item.get("code", -1))
		# Connect menu to handle state function
		new_menu_button.id_pressed.connect(_handle_menu_option_state.bind(new_menu_button))
		# Add menu to menus
		menu_container.add_child(new_menu_button)
	get_window().min_size.x = menu_container.get_combined_minimum_size().x + 10


## This function will load action script for each item in menu, if script doesn't exists will
## disable the item. Emits [signal SignalBus.check_option] after load.
func _load_scripts() -> void:
	var paths := PackedStringArray()
	var low_priority_paths := PackedStringArray()
	for menu: String in main_menu_data:
		for item: Dictionary in main_menu_data[menu]:
			# Ignore separators
			if item.get("type", OptionTypes.REGULAR) == OptionTypes.SEPARATOR:
				continue
			# Create script path
			var script_path := _get_script_path_for_item(item)
			# Disable items without script (except submenu roots)
			if not FileAccess.file_exists(S.globalize_path(script_path)):
				if item.has("popup") and item.get("type", OptionTypes.REGULAR) != OptionTypes.SUBMENU:
					item.get("popup").set_item_disabled(item.get("popup").get_item_index(item.get("code", 0)), true)
				continue
			# Add items in file menu to high priority list and other in low priority list
			if menu == "file_menu":
				paths.append(script_path)
			else:
				low_priority_paths.append(script_path)
	# Start loading
	U.load_resources_threaded(paths, _connect_script, Signals.check_options.emit)
	U.load_resources_threaded(low_priority_paths, _connect_script, Signals.check_options.emit)


## Creates a submenu in [param root_menu] based on [param root_option] data.
func _create_submenu(root_menu: PopupMenu, root_option: Dictionary) -> void:
	var submenu := PopupMenu.new()
	match root_option.get("text", ""):
		# Needs special action
		"Recent Files":
			recent_files_submenu = submenu
			_reload_recent_files()
		# Needs special action
		"New With Template":
			templates_submenu = submenu
			reload_templates()
		# Needs special action
		"By Extensions":
			Extensions.menu = submenu
			submenu.id_pressed.connect(Extensions._menu_id_pressed)
			Extensions.setup_extensions()
		_: # Just load items to popup menu for other submenus
			for submenu_item: Dictionary in main_menu_data[root_option.get("text", "").to_snake_case() + SUBMENU_SUFFIX]:
				var submenu_name: String = root_option.get("text", "").to_snake_case() + SUBMENU_SUFFIX
				main_menu_data[submenu_name][main_menu_data[submenu_name].find(submenu_item)]["popup"] = submenu
				match submenu_item.get("type", OptionTypes.REGULAR):
					OptionTypes.REGULAR:
						submenu.add_item(TFT.get_text(submenu_item.get("key", "")), submenu_item.get("code", -1))
					OptionTypes.SEPARATOR:
						submenu.add_separator(TFT.get_text(submenu_item.get("key", "")))
					OptionTypes.CHECKBOX:
						submenu.add_check_item(TFT.get_text(submenu_item.get("key", "")), submenu_item.get("code", -1))
					_:
						Global.send_notification(Global.Notification.ERROR, "Can't add item to submenu!", "Currently regular, separator, and checkbox items are available for submenus.")
			# Connect submenu to handle state function
			submenu.id_pressed.connect(_handle_menu_option_state.bind(submenu))
	# Connect submenu to handle state function for special items (It will call MultiActionScripts)
	if not submenu.id_pressed.is_connected(_handle_menu_option_state):
		submenu.id_pressed.connect(_handle_menu_option_state.bind(submenu, root_option.get("text", "")))
	# Add submenu
	root_menu.add_submenu_node_item(TFT.get_text(root_option.get("key", "")), submenu, root_option.get("code", -1))
	# Disable empty submenus
	if submenu.item_count == 0:
		root_menu.set_item_disabled(-1, true)


## Post-initialize when main action scripts loaded.
func _post_initialize() -> void:
	_handle_cmdline_arguments() # OS "Open With..." option
	_handle_load_last_file() # "Load last file at start" feature


## Reloads templates list.
func reload_templates() -> void:
	if not DirAccess.dir_exists_absolute(S.globalize_path(S.FOLDER_TEMPLATES)):
		DirAccess.make_dir_recursive_absolute(S.globalize_path(S.FOLDER_TEMPLATES))
	templates_submenu.clear()
	for template: String in DirAccess.get_files_at(S.FOLDER_TEMPLATES):
		templates_submenu.add_item(template.get_file().get_basename())


## Loads template with given [param name].
func load_template(_name: String) -> void:
	Signals.new_file.emit()
	await U.wait()
	Global.set_file_name("New file")
	Global.set_file_path("Unsaved")
	var path := S.TEMPLATE_TEMPLATES.format([_name])
	if not FileAccess.file_exists(path):
		Global.send_notification(
			Global.Notification.ERROR,
			"Template not found",
			"Template '%s' could not be loaded." % _name
		)
		return
	Global.set_editor_text(FileAccess.get_file_as_string(path))
	Global.set_editor_disabled(false)
	Signals.check_options.emit()
	start_replace_action(S.PATTERN_PLACEHOLDER)


## Starts replace action, see [function ReplacePopup.start].
func start_replace_action(pattern: String) -> void:
	replace_popup.start(pattern)


## Appends [param file_path] in [constant S.RECENT_FILES_DATA]. New file will be in top of list.
## This function will emit [signal SignalBus.reload_recent_files].
func append_to_recent_files(file_path: String) -> void:
	var current_files := FileAccess.get_file_as_string(S.RECENT_FILES_DATA)
	var file_access := FileAccess.open(S.RECENT_FILES_DATA, FileAccess.WRITE)
	if not file_access:
		Global.send_notification(
			Global.Notification.ERROR,
			"Failed to update recent files!"
		)
		return
	file_access.store_string(file_path + "\n" + current_files)
	file_access.close()
	Signals.reload_recent_files.emit()


## Shows about window.
func show_about() -> void:
	about.show()


## Will append [code]*[/code] to file name to show it was changed.
func _on_editor_text_changed() -> void:
	Global.mark_file_as_unsaved()


## Reloads recent files list, use [signal SignalBus.reload_recent_files] for standard call.
func _reload_recent_files() -> void:
	if not recent_files_submenu:
		return
	var recent_files_old := ""
	if FileAccess.file_exists(S.RECENT_FILES_DATA):
		recent_files_old = FileAccess.get_file_as_string(S.RECENT_FILES_DATA)
		if FileAccess.get_open_error():
			Global.send_notification(
				Global.Notification.ERROR,
				"Failed to reload recent files!"
			)
			return
	# Clear submenu
	recent_files_submenu.clear()
	# Load recent files
	if FileAccess.file_exists(S.globalize_path(S.RECENT_FILES_DATA)):
		var recent_files_list = recent_files_old.split("\n", false)
		recent_files_list = S.merge_unique(recent_files_list, []) # Remove duplicate items
		for recent in recent_files_list:
			if recent_files_submenu.item_count == 15: # Limit list to 15 items
				break
			if not FileAccess.file_exists(S.globalize_path(recent)): # Remove non-existent items
				continue
			recent_files_submenu.add_item(recent.replace("\\", "/"))
	# Save recent files again (to remove repeated and non-existent items)
	var recent_files := PackedStringArray()
	for recent in recent_files_submenu.item_count:
		recent_files.append(recent_files_submenu.get_item_text(recent))
	if "\n".join(recent_files) != recent_files_old:
		var file = FileAccess.open(S.RECENT_FILES_DATA, FileAccess.WRITE)
		if not file:
			Global.send_notification(
				Global.Notification.ERROR,
				"Failed to save recent files!"
			)
			return
		file.store_string("\n".join(recent_files))
		file.close()


## Connects loaded script to its menu option and initializes it.
func _connect_script(path: String, res: Resource) -> void:
	var item: Dictionary
	var was_found := false
	for menu: String in main_menu_data:
		for option: Dictionary in main_menu_data[menu]:
			if _get_script_path_for_item(option) == path:
				item = option
				was_found = true
				break
		if was_found:
			break
	if not was_found:
		Global.send_notification(
			Global.Notification.ERROR,
			"Failed to connect script %s!" % path
		)
		return
	var script = res.new()
	# For MultiActionScripts (submenu roots)
	if item.get("type", OptionTypes.REGULAR) == OptionTypes.SUBMENU:
		Signals.run_subscript.connect(script.run)
	# For ActionScripts (regular, checkbox, radio checkbox)
	else:
		Signals.run_script.connect(script.run)
	# Initialize action script
	Signals.check_options.connect(script._check_option)
	script.id = item.get("code", -1)
	script.menu = item.get("popup")
	script.name = item.get("text", "").to_snake_case().remove_chars(".")
	# Add child
	scripts.add_child.call_deferred(script)


## This function will recive pressing signals from all items in menu, handle state changing and call
## [signal SignalBus.script_run] or [signal SignalBus.run_subscript].
func _handle_menu_option_state(id: int, menu: PopupMenu, rootmenu: String = "") -> void:
	var index = menu.get_item_index(id)
	# For checkable options
	if menu.is_item_checkable(index) and not menu.is_item_radio_checkable(index):
		menu.toggle_item_checked(index)
	# For radio checkable options
	if menu.is_item_radio_checkable(index):
		if menu.is_item_checked(index): # Ignore select currently selected option
			return
		menu.toggle_item_checked(index) # Toggle selected option state
		# Search for related radio options and set them to unchecked
		var check_index = index - 1
		while check_index >= 0: # Options before selected option
			# Break when touch an option that isn't radio checkbox
			if not menu.is_item_radio_checkable(check_index):
				break
			menu.set_item_checked(check_index, false)
			check_index -= 1
		check_index = index + 1
		while check_index < menu.item_count: # Options after selected option
			# Break when touch an option that isn't radio checkbox
			if not menu.is_item_radio_checkable(check_index):
				break
			menu.set_item_checked(check_index, false)
			check_index += 1
	# Call signal
	if not rootmenu:
		Signals.run_script.emit(id)
	else:
		Signals.run_subscript.emit(id, menu, rootmenu)


## Handles OS "Open With..." option.
func _handle_cmdline_arguments() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	if args.is_empty():
		return
	for arg in args:
		if arg.begins_with("uid://") or arg.begins_with("--"):
			continue
		if arg.is_relative_path():
			arg = S.globalize_path(arg)
		if FileAccess.file_exists(arg):
			Signals.open_file.emit(arg)
		break # Currently we can support just one file, so this line skips next files


## Checks for "Load last file at start" feature.
func _handle_load_last_file() -> void:
	if (Global.has_file()
		or not Settings.get_setting_bool("files", "load_last_file_at_start")
		or Global.get_last_file_path() == ""
		or not FileAccess.file_exists(Global.get_last_file_path())):
		return
	if Settings.get_setting_bool("files", "ask_before_load_last_file_at_start"):
		add_child(Factory.confirmation_dialog(
			"Do you want to load your last opened file?",
			"Yes",
			"No",
			"Load last file",
			Callable(),
			_load_last_file.bind(false), true)
		)
	else:
		_load_last_file(true)


## Loads opened last file. When [param is_automatic] is [code]true[/code], sends a notification to
## say this action was done.
func _load_last_file(is_automatic := true) -> void:
	Signals.open_file.emit(Global.get_last_file_path())
	if is_automatic and Settings.get_setting_bool("notifications", "automatic_load_last_file_at_start"):
		Global.send_notification(
			Global.Notification.INFO,
			"Your last opened file was loaded!",
			"You can change this behavior or disable this notification in preferences."
		)
	editor.grab_focus()


## Helper to generate script path for a menu option.
func _get_script_path_for_item(item: Dictionary) -> String:
	return S.globalize_path(S.TEMPLATE_ACTION_SCRIPT.format(
		[item.get("text", "").to_snake_case().remove_chars(".")]
	))
