class_name ProjectAPI
extends Node

signal project_opened
signal project_closed
signal load_files(include: Array, exclude: Array)

const VERSION = "1.0"

var current_project := ConfigFile.new()
var recent_menu := PopupMenu.new()
var all_files: Array[String] = []

func _ready() -> void:
	Settings.define_preset("files", "save_files_when_moving_between_project_files", false)
	get_window().close_requested.connect(close_project)
	load_recent_projects()


func has_project() -> bool:
	if current_project:
		return current_project.has_section("project")
	return false


func close_project() -> void:
	if Global.has_unsaved_change():
		Signals.save_request.emit(-1)
		await get_tree().process_frame
	if has_project():
		current_project.set_value("files", "open", Global.get_file_path() if Global.has_file() else "")
		current_project.set_value("files", "caret_line", Global.get_editor().get_caret_line())
		current_project.set_value("files", "caret_column", Global.get_editor().get_caret_column())
		var err := current_project.save(get_current_project_path())
		if err:
			Global.send_notification(Global.Notification.ERROR, "Failed to close project!", "Error code: " + str(err))
			return
		current_project.clear()
		load_files.emit([], [])
		Signals.close_file.emit()
		project_closed.emit()
		get_window().set_title("Text Forge")


func load_project(file_path: String) -> void:
	Global.set_editor_disabled(true)
	Global.get_editor_api()._unload_current_mode()
	if has_project():
		close_project()
		await get_tree().process_frame

	var err := current_project.load(file_path)
	if err:
		Global.send_notification(Global.Notification.ERROR, "Failed to load project: {0}".format([err]))
		project_closed.emit()
		return
	if current_project.get_value("project", "version") != VERSION:
		Global.send_notification(
			Global.Notification.INFO,
			"Incompatible project version.",
			"The project was created with a different TFPM version. Please select a converter script to update it, then open the project again."
		)
		current_project.clear()
		add_child(Factory.file_dialog(FileDialog.FILE_MODE_OPEN_FILE, FileDialog.ACCESS_FILESYSTEM, ["*.gd;GDScript File"], convert_project.bind(file_path), true, OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS), ""))
		return
	Global.get_core().append_to_recent_files(file_path)
	append_to_recent_projects(file_path)
	project_opened.emit()
	load_files.emit(current_project.get_value("files", "include"), current_project.get_value("files", "exclude"))
	if current_project.get_value("files", "open", "") != "":
		Signals.open_file.emit(current_project.get_value("files", "open"))
		await get_tree().process_frame
		Global.get_editor().set_caret_line(current_project.get_value("files", "caret_line", 0))
		Global.get_editor().set_caret_column(current_project.get_value("files", "caret_column", 0))
	Signals.check_options.emit()


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_IN:
			if current_project:
				if current_project.has_section_key("project", "name"):
					load_files.emit(current_project.get_value("files", "include"), current_project.get_value("files", "exclude"))


func _on_recent_id_pressed(id: int) -> void:
	load_project(recent_menu.get_item_text(recent_menu.get_item_index(id)))


func load_recent_projects() -> void:
	recent_menu.clear()

	# Load recent projects
	if FileAccess.file_exists(FileDatabase.RECENT_PROJECTS_DATA):
		var recent_projects_list = FileAccess.get_file_as_string(FileDatabase.RECENT_PROJECTS_DATA).split("\n", false)

		recent_projects_list = SLib.merge_unique(recent_projects_list, []) # Remove duplicate items

		for recent in recent_projects_list:
			if recent_menu.item_count == 15: # Limit list to 15 items
				break
			if not FileAccess.file_exists(recent): # Remove non-existent items
				continue

			recent_menu.add_item(recent.replace("\\", "/"))

	# Save recent projects again (to remove repeated and non-existent items)
	var recent_projects := PackedStringArray()
	for recent in recent_menu.item_count:
		recent_projects.append(recent_menu.get_item_text(recent))

	var existing_content: String = FileAccess.get_file_as_string(FileDatabase.RECENT_PROJECTS_DATA) if FileAccess.file_exists(FileDatabase.RECENT_PROJECTS_DATA) else ""
	if "\n".join(recent_projects) != existing_content:
		var file = FileAccess.open(FileDatabase.RECENT_PROJECTS_DATA, FileAccess.WRITE)
		file.store_string("\n".join(recent_projects))
		file.close()


func append_to_recent_projects(file_path: String) -> void:
	var file: FileAccess
	var files := ""
	if FileAccess.file_exists(FileDatabase.RECENT_PROJECTS_DATA):
		files = FileAccess.get_file_as_string(FileDatabase.RECENT_PROJECTS_DATA)

	file = FileAccess.open(FileDatabase.RECENT_PROJECTS_DATA, FileAccess.WRITE)
	file.store_string(file_path.replace("\\", "/") + "\n" + files)
	file.close()

	load_recent_projects()


func convert_project(script_path: String, project_file: String) -> void:
	var script: Object = Global.load_resource(script_path).new()
	if not (script.has_method("convert_project") and script.has_signal("convert_completed")):
		Global.send_notification(Global.Notification.ERROR, "Converter is invalid!")
		script.free()
		return
	script.call("convert_project", project_file)
	Global.send_notification(Global.Notification.INFO, "Conversion started.")

	await script.convert_completed

	script.free()
	Global.send_notification(Global.Notification.INFO, "Conversion completed.", "You can open the project file now.")


func cache_icon(path: String) -> String:
	if path == "" or not FileAccess.file_exists(path):
		return ""
	var cache_dir := FileDatabase.FOLDER_CACHED_PROJECT_ICONS
	if not DirAccess.dir_exists_absolute(cache_dir):
		DirAccess.make_dir_recursive_absolute(cache_dir)

	var icon := FileAccess.get_file_as_bytes(path)
	if icon.is_empty():
		return ""
	for f: String in DirAccess.get_files_at(cache_dir):
		if icon == FileAccess.get_file_as_bytes(cache_dir.path_join(f)):
			return cache_dir.path_join(f)

	var id: int = 0
	var ext := path.get_extension().to_lower()
	var target := cache_dir.path_join(str(id) + "." + ext)
	while FileAccess.file_exists(target):
		id += 1
		target = cache_dir.path_join(str(id) + "." + ext)

	var file := FileAccess.open(target, FileAccess.WRITE)
	if file == null:
		return ""
	file.store_buffer(icon)
	file.close()

	return target


func get_project_name() -> String:
	if not has_project():
		return "Unnamed Project"
	return current_project.get_value("project", "name", "Unnamed Project")


func get_current_project_path() -> String:
	if has_project():
		return recent_menu.get_item_text(0)
	return ""
