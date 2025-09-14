class_name Core
extends Control
# official repo: https://github.com/text-forge/text-forge
## Root node of main window.

## Available option types in menus.
enum OptionTypes {
	## Separator items.
	SEPARATOR = -1,
	## Regular items.
	REGULAR,
	## Submenu node items.
	SUBMENU,
	## Checkbox items.
	CHECKBOX,
	## Redio checkbox items.
	RADIO_CHECKBOX,
}

## Section for menu data in config file.
const DATA_SECTION = "main_menu"
## Suffix for menu keys.
const MENU_SUFFIX = "_menu"
## Suffix for submenu keys.
const SUBMENU_SUFFIX = "_submenu"
## Prefix for menu names in translation file.
const MENU_TRANSLATION_PREFIX = "menu."

## [MenuBar] that will keep menu buttons. Menu buttons will be [PopupMenu]s.
@export var menu_container: MenuBar
## This [Label] will be placed above [member editor], its [param text] will be file name and its
## [param tooltip] will be file path. See [method GlobalAccess.get_file_name],
## [method GlobalAccess.get_file_path], [method GlobalAccess.set_file_name],
## [method GlobalAccess.set_file_path] for standard setter and getter.
@export var file_label: Label
## Editor node, you can find more options in [Editor] class.
@export var editor: Editor
## Scripts Node, will keep action scripts separated from other nodes.
@export var scripts: Control
## [PanelManager] node, see class for more information.
@export var panel_manager: PanelManager
## About window.
@export var about: Window
## Module Profiler.
@export var module_profiler: MenuButton

## Recent files [PopupMenu], see also [method _update_recent_files].
var recent_files_submenu: PopupMenu
## Configurations loaded from [constant FileDatabase.MAIN_UI_DATA].
var main_menu_data: Dictionary
var _translation_data: Dictionary[String, Dictionary]

# This is start point of Text Forge
func _ready() -> void:
	Project.project_opened.connect(func(): get_window().title = "%s - Text Forge" % Project.get_project_name())
	Project.project_closed.connect(func(): get_window().title = "Text Forge")
	scripts.child_order_changed.connect(func(): Signals.module_profiler_refresh.emit())
	# Open file with drag and drop feature
	get_window().files_dropped.connect(func(files: PackedStringArray): Signals.open_file.emit(files[0]))
	_translation_data = TFT.cache_source(FileDatabase.TRANSLATION_FILE)

	# Connect reload_recent_files request signal
	Signals.reload_recent_files.connect(_reload_recent_files)
	Signals.check_options.connect(_post_initialize, CONNECT_ONE_SHOT)

	_handle_settings()

	# load data in main_menu_data
	_load_main_menu_data()
	# Load main menu items
	_load_main_menu()

	# Load action scripts
	_load_scripts()


func _post_initialize() -> void:
	_handle_cmdline_arguments()

	_handle_load_last_file()


func _handle_settings() -> void:
	if not Signals.settings_changed.is_connected(_handle_settings):
		Signals.settings_changed.connect(_handle_settings)

	# Define presets

	Settings.define_preset("files", "load_last_file_at_start", true)
	Settings.define_preset("files", "ask_before_load_last_file_at_start", false)

	Settings.define_preset("notifications", "automatic_load_last_file_at_start", true)

	Settings.define_preset("edit", "indent_with_space", false)
	Settings.define_preset("edit", "indent_size", 4)

	# Load settings

	Global.get_editor().indent_use_spaces = Settings.get_setting("edit", "indent_with_space")
	Global.get_editor().indent_size = Settings.get_setting("edit", "indent_size")


## Appends [param file_path] in [constant FileDatabase.RECENT_FILES_DATA]. New file will be in top
## of list. This function will emit [signal SignalBus.reload_recent_files].
func append_to_recent_files(file_path: String) -> void:
	var file: FileAccess
	var files: String
	files = FileAccess.get_file_as_string(FileDatabase.RECENT_FILES_DATA)

	file = FileAccess.open(FileDatabase.RECENT_FILES_DATA, FileAccess.WRITE)
	file.store_string(file_path + "\n" + files)
	file.close()

	Signals.reload_recent_files.emit()


func show_about() -> void:
	about.show()


func _handle_cmdline_arguments() -> void:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	if args.is_empty():
		return

	for arg in args:
		var file_path := arg
		if file_path.begins_with("uid://"):
			continue
		if file_path.is_relative_path():
			file_path = SLib.globalize_path(arg)
		Signals.open_file.emit(file_path)


func _handle_load_last_file() -> void:
	if Global.has_file():
		return
	if not Settings.get_setting_bool("files", "load_last_file_at_start"):
		return
	if Global.get_last_file_path() == "":
		return

	if Settings.get_setting_bool("files", "ask_before_load_last_file_at_start"):
		add_child(Factory.confirmation_dialog("Do you want to load your last opened file?", "Yes", "No", "Load last file", Callable(), _load_last_file.bind(false), true))
	else:
		_load_last_file(true)

func _load_last_file(is_automatic := true) -> void:
	Signals.open_file.emit(Global.get_last_file_path())
	if is_automatic and Settings.get_setting_bool("notifications", "automatic_load_last_file_at_start"):
		Global.send_notification(Global.Notification.INFO, "Your last opened file was loaded!", "You can change this behavior or disable this notification in preferences.")


## Loads data in [member main_menu_data], uses [constant FileDatabase.MAIN_UI_DATA] and [constant DATA_SECTION].
func _load_main_menu_data() -> void:
	var config := ConfigFile.new()
	config.load(SLib.globalize_path(FileDatabase.MAIN_UI_DATA))
	for menu_section: String in config.get_section_keys(DATA_SECTION):
		main_menu_data[menu_section] = config.get_value(DATA_SECTION, menu_section) as Array


## This function will load data from UI source and generate buttons.
func _load_main_menu() -> void:
	var config := ConfigFile.new()
	config.load(SLib.globalize_path(FileDatabase.MAIN_UI_DATA))

	for menu_item: String in config.get_section_keys(DATA_SECTION):
		if menu_item.ends_with(SUBMENU_SUFFIX):
			continue # skip next steps for submenu items

		var current_menu: Array = main_menu_data.get(menu_item)

		# create new menu button
		var new_menu_button := PopupMenu.new()
		# english menu name, remove menu suffix and capitalize it
		var menu_name: String = menu_item.erase(menu_item.rfind(MENU_SUFFIX), MENU_SUFFIX.length())
		menu_name = menu_name.capitalize()

		# translate name
		new_menu_button.name = TFT.get_text_from_cache(MENU_TRANSLATION_PREFIX + menu_name.to_snake_case(), _translation_data)

		# for each option in current menu
		for item: Dictionary in current_menu:
			# set item "popup", see _load_scripts for use case
			main_menu_data[menu_item][current_menu.find(item)]["popup"] = new_menu_button

			var item_text := TFT.get_text_from_cache(item.get("key", ""), _translation_data)

			match item.get("type", OptionTypes.REGULAR):
				OptionTypes.REGULAR:
					new_menu_button.add_item(item_text, item.get("code", -1))
				OptionTypes.SUBMENU:
					_create_submenu(new_menu_button, item, config)
				OptionTypes.SEPARATOR:
					new_menu_button.add_separator(item_text)
				OptionTypes.CHECKBOX:
					new_menu_button.add_check_item(item_text, item.get("code", -1))
				OptionTypes.RADIO_CHECKBOX:
					new_menu_button.add_radio_check_item(item_text, item.get("code", -1))

		# connect menu to handle state function
		new_menu_button.id_pressed.connect(_handle_menu_option_state.bind(new_menu_button))

		# add menu to menus
		menu_container.add_child(new_menu_button)
	get_window().min_size.x = menu_container.get_combined_minimum_size().x + 10


## Creates a submenu in [param root_menu] based on [param root_option] data and [param config_file].
func _create_submenu(root_menu: PopupMenu, root_option: Dictionary, config_file: ConfigFile) -> void:
	var submenu := PopupMenu.new()
	match root_option.get("text", ""):
		"Recent Files": # needs special action
			recent_files_submenu = submenu

			_reload_recent_files()

		"New With Template": # needs special action
			if not DirAccess.dir_exists_absolute(SLib.globalize_path(FileDatabase.FOLDER_TEMPLATES)):
				DirAccess.make_dir_recursive_absolute(SLib.globalize_path(FileDatabase.FOLDER_TEMPLATES))

			for template: String in DirAccess.get_files_at(FileDatabase.FOLDER_TEMPLATES):
				submenu.add_item(template)

		"By Extensions": # needs load from another script
			Extensions.menu = submenu
			submenu.id_pressed.connect(Extensions._menu_id_pressed)
			Extensions.setup_extensions()

		_: # just load items to another popup menu for other submenus
			for submenu_item: Dictionary in config_file.get_value(DATA_SECTION, root_option.get("text", "").to_snake_case() + SUBMENU_SUFFIX):
				var submenu_name: String = root_option.get("text", "").to_snake_case() + SUBMENU_SUFFIX
				main_menu_data[submenu_name][main_menu_data[submenu_name].find(submenu_item)]["popup"] = submenu
				match submenu_item.get("type", OptionTypes.REGULAR):
					OptionTypes.REGULAR:
						submenu.add_item(TFT.get_text(submenu_item.get("key", "")), submenu_item.get("code", -1))
					OptionTypes.SEPARATOR:
						submenu.add_separator(TFT.get_text(submenu_item.get("key", "")))
					_:
						Global.send_notification(Global.Notification.ERROR, "Can't add item to submenu!", "Currently just regular and separatior items are avaliable for submenus.")
			# connect submenu to handle state function
			submenu.id_pressed.connect(_handle_menu_option_state.bind(submenu))

	# connect submenu to handle state function for special items (It will call MultiActionScripts)
	if not submenu.id_pressed.is_connected(_handle_menu_option_state):
		submenu.id_pressed.connect(_handle_menu_option_state.bind(submenu, root_option.get("text", "")))
	# add submenu
	root_menu.add_submenu_node_item(TFT.get_text(root_option.get("key", "")), submenu, root_option.get("code", -1))
	# disable empty submenus
	if submenu.item_count == 0:
		root_menu.set_item_disabled(-1, true)


## This function will load script for each item in menu, if script doesn't exists will disable the item.
## Emits [signal SignalBus.check_option] after load.
func _load_scripts() -> void:
	var paths := PackedStringArray()
	for menu: String in main_menu_data:
		for item: Dictionary in main_menu_data[menu]:
			if item.get("type", OptionTypes.REGULAR) == OptionTypes.SEPARATOR: # ignore separators
				continue

			var script_path: String = FileDatabase.TEMPLATE_ACTION_SCRIPT.format([item.get("text", "").to_snake_case().replace(".", "")])

			if not FileAccess.file_exists(SLib.globalize_path(script_path)):
				# disable items without script (except submenu roots)
				if item.has("popup") and item.get("type", OptionTypes.REGULAR) != OptionTypes.SUBMENU:
					item.get("popup").set_item_disabled(item.get("popup").get_item_index(item.get("code", 0)), true)
				continue

			paths.append(script_path)

	Global.load_resources_threaded(paths, _connect_script, _all_scripts_loaded)


func _connect_script(path: String, res: Resource) -> void:
	var item: Dictionary
	for menu: String in main_menu_data:
		for option: Dictionary in main_menu_data[menu]:
			if FileDatabase.TEMPLATE_ACTION_SCRIPT.format([option.get("text", "").to_snake_case().replace(".", "")]) == path:
				item = option
	var script = res.new()
	# for MultiActionScripts (submenu roots)
	if item.get("type", OptionTypes.REGULAR) == OptionTypes.SUBMENU:
		Signals.run_subscript.connect(script.run)
	# for ActionScripts (regular, checkbox, radio checkbox)
	else:
		Signals.run_script.connect(script.run)

	Signals.check_options.connect(script._check_option)

	script.id = item.get("code", -1)
	script.menu = item.get("popup")
	script.name = item.get("text", "").to_snake_case().replace(".", "")

	scripts.add_child.call_deferred(script)


func _all_scripts_loaded() -> void:
	Signals.check_options.emit() # emit signal for first option check


## This function will recive pressing signals from all items in menu, handle state changing and call
## [signal SignalBus.script_run] or [signal SignalBus.run_subscript].
func _handle_menu_option_state(id: int, menu: PopupMenu, rootmenu: String = "") -> void:
	var index = menu.get_item_index(id)

	# for checkable options
	if menu.is_item_checkable(index) and not menu.is_item_radio_checkable(index):
		menu.toggle_item_checked(index)

	# for radio checkable options
	if menu.is_item_radio_checkable(index):
		if menu.is_item_checked(index): # ignore select currently selected option
			return
		menu.toggle_item_checked(index) # toggle selected option state

		# search for related radio options and set them to unchecked
		var check_index = index - 1
		while true: # options before selected option
			if check_index < 0:
				break
			# break when touch an option that isn't radio checkbox
			if not menu.is_item_radio_checkable(check_index):
				break
			menu.set_item_checked(check_index, false)
			check_index -= 1

		check_index = index + 1
		while true: # options after selected option
			if check_index + 1 > menu.item_count:
				break
			# break when touch an option that isn't radio checkbox
			if not menu.is_item_radio_checkable(check_index):
				break
			menu.set_item_checked(check_index, false)
			check_index += 1

	if not rootmenu:
		Signals.run_script.emit(id)
	else:
		Signals.run_subscript.emit(id, menu, rootmenu)


## Will append [code]*[/code] to file name to show it was changed.
func _on_editor_text_changed() -> void:
	if not file_label.text.ends_with("*"):
		file_label.text += "*"


## Reloads recent files list, use [signal SignalBus.reload_recent_files] for standard call.
func _reload_recent_files() -> void:
	# Clear submenu
	recent_files_submenu.clear()

	# Load recent files
	if FileAccess.file_exists(SLib.globalize_path(FileDatabase.RECENT_FILES_DATA)):
		var recent_files_list = FileAccess.get_file_as_string(FileDatabase.RECENT_FILES_DATA).split("\n", false)

		recent_files_list = SLib.merge_unique(recent_files_list, []) # Remove duplicate items

		for recent in recent_files_list:
			if recent_files_submenu.item_count == 15: # Limit list to 15 items
				break
			if not FileAccess.file_exists(SLib.globalize_path(recent)): # Remove non-existent items
				continue

			recent_files_submenu.add_item(recent.replace("\\", "/"))

	# Save recent files again (to remove repeated and non-existent items)
	var recent_files := PackedStringArray()
	for recent in recent_files_submenu.item_count:
		recent_files.append(recent_files_submenu.get_item_text(recent))
	if "\n".join(recent_files) != FileAccess.get_file_as_string(FileDatabase.RECENT_FILES_DATA):
		var file = FileAccess.open(FileDatabase.RECENT_FILES_DATA, FileAccess.WRITE)
		file.store_string("\n".join(recent_files))
		file.close()
