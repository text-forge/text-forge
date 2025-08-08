extends Window

@export var tree: Tree
@export var tabs: TabContainer
@export var item: PanelContainer
@export var extensions_list: HFlowContainer

func _ready() -> void:
	Extensions.extensions_loaded.connect(_reopen_request)
	# setup tree based on tabs

	# add root
	tree.create_item()

	for child in tabs.get_children():
		var page := tree.create_item()
		page.set_text(0, child.name.capitalize())

	if tree.get_root().get_child_count():
		tree.set_selected(tree.get_root().get_first_child(),0)


	load_extensions()


func load_extensions() -> void:
	for xtn: String in Extensions.extensions:
		extensions_list.add_child(item.duplicate().setup(xtn, Extensions.extensions[xtn]["name"], xtn in Extensions.enabled_extensions))

	if not extensions_list.get_child_count():
		var label := Label.new()
		label.text = "There is no extension!"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		extensions_list.add_child(label)


func _on_close_requested() -> void:
	queue_free()


func _on_tree_item_selected() -> void:
	tabs.current_tab = tree.get_selected().get_index()


func _on_install_pressed() -> void:
	add_child(Factory.file_dialog(FileDialog.FILE_MODE_OPEN_FILE, FileDialog.ACCESS_FILESYSTEM, ["*.tfx,*.zip;Text Forge Extensions;application/zip"], _install_extension, true, OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)))


func _install_extension(path: String) -> void:
	var reader = ZIPReader.new()
	var err := reader.open(path)
	if err:
		Global.send_notification(Global.Notification.ERROR, "Can't load this file!", "Load {0} for install extension failed. Error code: {1}".format([path, str(err)]))
		return

	if not DirAccess.dir_exists_absolute(SLib.globalize_path(FileDatabase.FOLDER_EXTENSIONS)):
		DirAccess.make_dir_recursive_absolute(SLib.globalize_path(FileDatabase.FOLDER_EXTENSIONS))

	var root_dir = DirAccess.open(FileDatabase.FOLDER_EXTENSIONS)

	var files = reader.get_files()
	for file_path in files:
		if file_path.ends_with("/"):
			root_dir.make_dir_recursive(file_path)
			continue

		root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
		var file = FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
		var buffer = reader.read_file(file_path)
		file.store_buffer(buffer)

	Global.get_editor_api().reload_modes()
	_check_reload()
	Global.send_notification(Global.Notification.INFO, "Install extension completed.")


func _check_reload() -> void:
	add_child(Factory.confirmation_dialog("Unpack extension completed, Do you want to reload extensions to use it?", "Yes, Reload", "No, Later", "Do you want reload extensions?", Callable(), Extensions.setup_extensions))


func _reopen_request() -> void:
	Global.send_notification(Global.Notification.INFO, "Please reopen extensions window!", "Extensions was (re)loaded, reopen extensions window to see changes.")
