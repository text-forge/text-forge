class_name ExtensionCore
extends Node
## Global extension core of Text Forge.
##
## This class is a loader and holder for extensions and is accessable with [code]Extensions[/code].
## Each extension must have a configuration file in [code]extension.cfg[/code].[br][br]
## [b]Example Extension Configuration:[/b]
## [codeblock lang=text]
## [main]
##
## name = "null"
## folder = "default" ; will use current folder if "default", it's useful for custom file management
## version = "1.0.0" ; it's string!
## description = "There is no description."
## author = "null"
## license = "! Unlicesed"
##
## [excute]
##
## entry = "extension.gd" ; entry point of extension, will be child of this autoload
## dependencies = {} ; use "extension_id": "extension_name" format
## on_activate = "_activate_extension" ; will be called on setup
## on_deactivate = "_deactivate_extension" ; will be called on cleanup
## uninstall = "_remove_extension" ; will be called on uninstall
## [/codeblock]
## [b]Note:[/b] Above file containes all default values, you can ignore write any key you needn't
## change it. Each extension have a ID and this ID is name of extension folder.[br]
## [b]Note:[/b] Extension entries will load as childern of [code]/root/Extensions[/code].

signal extensions_loaded

## Keeps [PopupMenu] for extensions in main menus. Will seted by [Core].
var menu: PopupMenu
## Keeps a dictionary of all extensions by IDs (folder names).
var extensions: Dictionary[String, Dictionary] = {}
## Keeps IDs list of enabled extensions.
var enabled_extensions: Array = []
## Keeps a dictionary of available options in "Tools > By Extensions" by ID.
var options: Dictionary[int, Callable] = {}


func _ready() -> void:
	get_window().close_requested.connect(cleanup_all_extensions)
	child_order_changed.connect(func(): Signals.module_profiler_refresh.emit())


## (Re)loads all extensions. Calls [method cleanup_all_extensions], [method _load_extensions] and [method _load_enable_list].
func setup_extensions() -> void:
	cleanup_all_extensions()

	_load_enabled_list()
	_load_extensions()

	# Remove non-existent extensions from enabled extensions list
	# Avoid remove items in a for loop that is based on this array
	var to_remove := []
	for enabled: String in enabled_extensions:
		if not enabled in extensions:
			to_remove.append(enabled)
	for item: String in to_remove:
		enabled_extensions.erase(item)

	# just do activation for enabled extensions
	for xtn: String in extensions.keys().filter(func(item): return item in enabled_extensions):
		var entry = Global.load_resource(FileDatabase.FOLDER_EXTENSIONS.path_join(xtn).path_join(extensions[xtn]["entry"])).new()
		entry.name = xtn
		add_child(entry)
		entry.call(extensions[xtn]["on_activate"])

	extensions_loaded.emit()


## Cleanups all extensions with calling [code]on_deactivate[/code] for each enabled extension and
## free entry of all extensions after a process frame. Nothing happens if there is no connected
## entry.
func cleanup_all_extensions() -> void:
	if not get_child_count():
		return

	for xtn: String in extensions.keys().filter(func(item): return item in enabled_extensions):
		get_node(xtn).call(extensions[xtn]["on_deactivate"])

	await get_tree().process_frame
	SLib.free_all_children(self)


## Sets given extension as [param enabled] and activate/diactivate it.
func set_extension_enabled(id: String, enabled: bool = true) -> void:
	if not id in extensions:
		return

	if not enabled:
		if enabled_extensions.has(id):
			enabled_extensions.erase(id)
			get_node(id).call(extensions[id]["on_deactivate"])
			await get_tree().process_frame
			get_node(id).queue_free()
	else:
		if not enabled_extensions.has(id):
			enabled_extensions.append(id)
			var entry = Global.load_resource(FileDatabase.FOLDER_EXTENSIONS.path_join(id).path_join(extensions[id]["entry"])).new()
			entry.name = id
			add_child(entry)
			entry.call(extensions[id]["on_activate"])

	Settings.write_data("extensions", "enabled", enabled_extensions)


## Adds a new option in [member menu] and links it to given [param callable]. [param id] will be
## used to run or remove this action.
func add_extensions_menu_item(text: String, id: int, callable: Callable) -> void:
	options[id] = callable
	menu.add_item(text, id)


## Removes option with given [param id] from [member menu].
func remove_extensions_menu_item(id: int) -> void:
	options.erase(id)
	menu.remove_item(menu.get_item_index(id))


func uninstall_extension(id: String) -> void:
	if id in enabled_extensions:
		set_extension_enabled(id, false)
		await get_tree().process_frame

	if has_node(id):
		get_node(id).call(extensions[id]["uninstall"])
	else:
		Global.load_resource(FileDatabase.FOLDER_EXTENSIONS.path_join(id).path_join(extensions[id]["entry"])).new().call(extensions[id]["uninstall"])

	await get_tree().process_frame
	OS.move_to_trash(SLib.globalize_path(FileDatabase.FOLDER_EXTENSIONS.path_join(id)))


## Calls linked [Callable] based on [param id], see [method add_extensions_menu_item] for more information.
func _menu_id_pressed(id: int) -> void:
	options[id].call()


## Loads list of enabled extensions.
func _load_enabled_list() -> void:
	enabled_extensions = Settings.read_data("extensions", "enabled", [])


## Loads extensions from [constant FileDatabase.FOLDER_EXTENSIONS], each extension is a folder and
## must have a [code]extension.cfg[/code].
func _load_extensions() -> void:
	extensions = {}

	if not DirAccess.dir_exists_absolute(SLib.globalize_path(FileDatabase.FOLDER_EXTENSIONS)):
		DirAccess.make_dir_absolute(SLib.globalize_path(FileDatabase.FOLDER_EXTENSIONS))

	var config := ConfigFile.new()
	for xtn: String in DirAccess.get_directories_at(FileDatabase.FOLDER_EXTENSIONS):
		if not FileAccess.file_exists(SLib.globalize_path(FileDatabase.TEMPLATE_EXTENSION_CONFIG.format([xtn]))):
			continue

		config.load(SLib.globalize_path(FileDatabase.TEMPLATE_EXTENSION_CONFIG.format([xtn])))

		extensions[xtn] = {}
		extensions[xtn]["name"] = config.get_value("main", "name", "null")
		extensions[xtn]["folder"] = config.get_value("main", "folder", "default")
		extensions[xtn]["version"] = config.get_value("main", "version", "1.0.0")
		extensions[xtn]["description"] = config.get_value("main", "description", "There is no description.")
		extensions[xtn]["author"] = config.get_value("main", "author", "null")
		extensions[xtn]["license"] = config.get_value("main", "license", "unlicesed")

		extensions[xtn]["entry"] = config.get_value("excute", "entry", "extension.gd")
		extensions[xtn]["dependencies"] = config.get_value("excute", "dependencies", {})
		extensions[xtn]["on_activate"] = config.get_value("excute", "on_active", "_activate_extension")
		extensions[xtn]["on_deactivate"] = config.get_value("excute", "on_active", "_deactivate_extension")
		extensions[xtn]["uninstall"] = config.get_value("excute", "on_active", "_remove_extension")

		if extensions[xtn]["folder"] == "default":
			extensions[xtn]["folder"] = xtn
