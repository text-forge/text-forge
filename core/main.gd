class_name Core
extends Control
# official repo: https://text-forge/text-forge
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
const DATA_SECTION: String = "main_menu"
## Suffix for menu keys.
const MENU_SUFFIX: String = "_menu"
## Suffix for submenu keys.
const SUBMENU_SUFFIX: String = "_submenu"
## Prefix for menu names in translation file.
const MENU_TRANSLATION_PREFIX: String = "menu."

## [Container] that will keep menu buttons. Menu buttons will be [MenuButton]s.
@export var menu_container: Container
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

## Recent files [PopupMenu], see also [method _update_recent_files].
var recent_files_submenu: PopupMenu
## Configurations loaded from [constant FileDatabase.MAIN_UI_DATA].
var main_menu_data: Dictionary

# This is start point of Text Forge
func _ready() -> void:
	# Open file with drag and drop feature
	get_window().files_dropped.connect(func(files): Signals.open_file.emit(files[0]))

	# Connect reload_recent_files request signal
	Signals.reload_recent_files.connect(_reload_recent_files)

	# load data in main_menu_data
	_load_main_menu_data()
	# Load main menu items
	_load_main_menu()
	# Load action scripts
	_load_scripts()


## Appends [param file_path] in [constant FileDatabase.RECENT_FILES_DATA]. New file will be in top
## of list. This function will emit [signal SignalBus.reload_recent_files].
func append_to_recent_files(file_path: String) -> void:
	var file: FileAccess
	var files: String
	if FileAccess.file_exists(FileDatabase.RECENT_FILES_DATA):
		file = FileAccess.open(FileDatabase.RECENT_FILES_DATA, FileAccess.READ)
		files = file.get_as_text()
		file.close()
	else:
		files = ""

	file = FileAccess.open(FileDatabase.RECENT_FILES_DATA, FileAccess.WRITE)
	file.store_string(file_path + "\n" + files)
	file.close()

	Signals.reload_recent_files.emit()


func show_about() -> void:
	about.show()


## Loads data in [member main_menu_data], uses [constant FileDatabase.MAIN_UI_DATA] and [constant DATA_SECTION].
func _load_main_menu_data() -> void:
	var config := ConfigFile.new()
	config.load(FileDatabase.MAIN_UI_DATA)
	for menu_section: String in config.get_section_keys(DATA_SECTION):
		main_menu_data[menu_section] = config.get_value(DATA_SECTION, menu_section)


## This function will load data from UI source and generate buttons.
func _load_main_menu() -> void:
	var config := ConfigFile.new()
	config.load(FileDatabase.MAIN_UI_DATA)

	for menu_item: String in config.get_section_keys(DATA_SECTION):
		if menu_item.ends_with(SUBMENU_SUFFIX):
			continue # skip next steps for submenu items

		var current_menu: Array = main_menu_data[menu_item]

		# create new menu button
		var new_menu_button := Factory.menu_button(true)
		# english menu name, remove menu suffix and capitalize it
		var menu_name: String = menu_item.erase(menu_item.rfind(MENU_SUFFIX), MENU_SUFFIX.length())
		menu_name = menu_name.capitalize()

		# translate name
		new_menu_button.text = TFT.get_text(MENU_TRANSLATION_PREFIX + menu_name.to_snake_case(), FileDatabase.TRANSLATION_FILE)

		# for each option in current menu
		for item: Dictionary in current_menu:
			# set item "popup", see _load_scripts for use case
			main_menu_data[menu_item][current_menu.find(item)]["popup"] = new_menu_button.get_popup()

			var item_text := TFT.get_text(item.get("key", ""), FileDatabase.TRANSLATION_FILE)

			match item.get("type", OptionTypes.REGULAR):
				OptionTypes.REGULAR:
					new_menu_button.get_popup().add_item(item_text, item.get("code", -1))
				OptionTypes.SUBMENU:
					_create_submenu(new_menu_button, item, config)
				OptionTypes.SEPARATOR:
					new_menu_button.get_popup().add_separator(item_text)
				OptionTypes.CHECKBOX:
					new_menu_button.get_popup().add_check_item(item_text, item.get("code", -1))
				OptionTypes.RADIO_CHECKBOX:
					new_menu_button.get_popup().add_radio_check_item(item_text, item.get("code", -1))

		# connect menu to handle state function
		new_menu_button.get_popup().id_pressed.connect(_handle_menu_option_state.bind(new_menu_button.get_popup()))

		# add menu to menus
		menu_container.add_child(new_menu_button)


## Creates a submenu in [param root_menu] based on [param root_option] data and [param config_file].
func _create_submenu(root_menu: MenuButton, root_option: Dictionary, config_file: ConfigFile) -> void:
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

		"Extensions": # needs load from another script
			pass

		_: # just load items to another popup menu for other submenus
			for submenu_item: Dictionary in config_file.get_value(DATA_SECTION, root_option.get("text", "").to_snake_case() + SUBMENU_SUFFIX):
				var submenu_name: String = root_option.get("text", "").to_snake_case() + SUBMENU_SUFFIX
				main_menu_data[submenu_name][main_menu_data[submenu_name].find(submenu_item)]["popup"] = submenu
				match submenu_item.get("type", OptionTypes.REGULAR):
					OptionTypes.REGULAR:
						submenu.add_item(TFT.get_text(submenu_item.get("key", ""), FileDatabase.TRANSLATION_FILE), submenu_item.get("code", -1))
					OptionTypes.SEPARATOR:
						submenu.add_separator(TFT.get_text(submenu_item.get("key", ""), FileDatabase.TRANSLATION_FILE))
					_:
						Global.send_notification(Global.Notification.ERROR, "Can't add item to submenu!", "Currently just regular and separatior items are avaliable for submenus.")
			# connect submenu to handle state function
			submenu.id_pressed.connect(_handle_menu_option_state.bind(submenu))

	# connect submenu to handle state function for special items (It will call MultiActionScripts)
	if not submenu.id_pressed.is_connected(_handle_menu_option_state):
		submenu.id_pressed.connect(_handle_menu_option_state.bind(submenu, root_option.get("text", "")))
	# add submenu
	root_menu.get_popup().add_submenu_node_item(TFT.get_text(root_option.get("key", ""), FileDatabase.TRANSLATION_FILE), submenu, root_option.get("code", -1))
	# disable empty submenus
	if submenu.item_count == 0:
		root_menu.get_popup().set_item_disabled(-1, true)


## This function will load script for each item in menu, if script doesn't exists will disable the item.
## Emits [signal SignalBus.check_option] after load.
func _load_scripts() -> void:
	for menu: String in main_menu_data:
		for item: Dictionary in main_menu_data[menu]:
			if item.get("type", OptionTypes.REGULAR) == OptionTypes.SEPARATOR: # ignore separators
				continue

			var script_path: String = FileDatabase.TEMPLATE_ACTION_SCRIPT.format([item.get("text", "").to_snake_case().replace(".", "")])

			if not FileAccess.file_exists(script_path):
				# disable items without script (except submenu roots)
				if item.has("popup") and item.get("type", OptionTypes.REGULAR) != OptionTypes.SUBMENU:
					item.get("popup").set_item_disabled(item.get("popup").get_item_index(item.get("code", 0)), true)
				continue

			var script = load(script_path).new()

			# for MultiActionScripts (submenu roots)
			if item.get("type", 0) == 1:
				Signals.run_subscript.connect(script.run)
			# for ActionScripts (regular, checkbox, radio checkbox)
			else:
				Signals.run_script.connect(script.run)

			Signals.check_options.connect(script._check_option)

			script.id = item.get("code", -1)
			script.menu = item.get("popup")
			script.name = item.get("text", "").to_snake_case().replace(".", "")

			scripts.add_child(script)

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
	if FileAccess.file_exists(FileDatabase.RECENT_FILES_DATA):
		var file_access = FileAccess.open(FileDatabase.RECENT_FILES_DATA, FileAccess.READ)
		var recent_files_list = file_access.get_as_text().split("\n", false)
		file_access.close()

		recent_files_list = SLib.merge_unique(recent_files_list, []) # Remove repeated items

		for recent in recent_files_list:
			if recent_files_submenu.item_count == 15: # Limit list to 15 items
				break
			if not FileAccess.file_exists(recent): # Remove non-existent items
				continue

			recent_files_submenu.add_item(recent)

	# Save recent files (to remove repeated and non-existent items)
	var recent_files := PackedStringArray()
	for recent in recent_files_submenu.item_count:
		recent_files.append(recent_files_submenu.get_item_text(recent))
	var file = FileAccess.open(FileDatabase.RECENT_FILES_DATA, FileAccess.WRITE)
	file.store_string("\n".join(recent_files))
	file.close()
