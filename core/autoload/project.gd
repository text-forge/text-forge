class_name ProjectAPI
extends Node
## A global API to work with projects.

## Emits when opens a project.
signal project_opened
## Emits when closes a project.
signal project_closed
## Sends list of project files rules.
signal load_files(include: Array, exclude: Array)

## Version of TFPM API.
const VERSION = "1.0"

## Loaded content of current project file.
var current_project := ConfigFile.new()
## Recent projects.
var recent_menu := PopupMenu.new()
## List of all project files. (Will be set from other modules)
var all_files: Array[String] = []

var close_project_action_script_id: int

func _ready() -> void:
	Signals.close_project.connect(close_project)
	Notif.register_notification(
		"save_project_failed",
		Notif.Type.ERR,
		"Failed to save project at {0}!",
		"Error: ",
	)
	Notif.register_notification(
		"load_project_file_failed",
		Notif.Type.ERR,
		"Failed to load project file!",
		"Error: "
	)
	Notif.register_notification(
		"new_project_created",
		Notif.Type.INFO,
		"New project created at {0}.",
	)
	Notif.register_notification(
		"close_project_failed",
		Notif.Type.ERR,
		"Failed to close project!",
		"Error: "
	)
	Notif.register_notification(
		"incompatible_project_version",
		Notif.Type.INFO,
		"Incompatible project version.",
		"The project was created with a different TFPM version."
		+ " Please select a converter script to update it, then open the project again."
	)
	Notif.register_notification(
		"invalid_project_converter",
		Notif.Type.ERR,
		"Converter is invalid!"
	)
	Notif.register_notification(
		"project_conversion_started",
		Notif.Type.INFO,
		"Conversion started."
	)
	Notif.register_notification(
		"project_conversion_completed",
		Notif.Type.INFO,
		"Conversion completed.",
		"You can open the project file now."
	)
	Settings.define_preset("files", "save_files_when_moving_between_project_files", false)
	get_window().close_requested.connect(close_project)
	load_recent_projects()


## Returns [code]true[/code] if there is valid opened project.
func has_project() -> bool:
	if current_project:
		return current_project.has_section("project")
	return false


## Closes currently opened project.
func close_project() -> void:
	if Global.has_unsaved_change():
		if close_project_action_script_id:
			Signals.save_request.emit(close_project_action_script_id)
			return
		else:
			Signals.save_request.emit(-1)
			await get_tree().process_frame
	if has_project():
		current_project.set_value("files", "open", Global.get_file_path() if Global.has_file() else "")
		if Global.has_file():
			current_project.set_value("files", "caret_line", Global.get_editor().get_caret_line())
			current_project.set_value("files", "caret_column", Global.get_editor().get_caret_column())
		var err := current_project.save(get_current_project_path())
		if err:
			Notif.notif(
				"close_project_failed",
				{"text_append": error_string(err)}
			)
			return
		current_project.clear()
		load_files.emit([], [])
		Signals.close_file.emit()
		project_closed.emit()
		get_window().set_title("Text Forge")


## Loads and opens given project.
func load_project(file_path: String) -> void:
	Global.set_editor_disabled(true)
	Global.get_editor_api()._unload_current_mode()
	if has_project():
		close_project()
		await get_tree().process_frame
	var err := current_project.load(file_path)
	if err:
		Notif.notif(
			"load_project_file_failed",
			{"text_append": error_string(err)}
		)
		project_closed.emit()
		return
	if current_project.get_value("project", "version") != VERSION:
		Notif.notif("incompatible_project_version")
		current_project.clear()
		add_child(Factory.file_dialog(
			FileDialog.FILE_MODE_OPEN_FILE,
			FileDialog.ACCESS_FILESYSTEM,
			["*.gd;GDScript File"],
			convert_project.bind(file_path),
			true,
			OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS),
			""
		))
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
	if what != NOTIFICATION_APPLICATION_FOCUS_IN:
		return
	if current_project:
		if current_project.has_section_key("project", "name"):
			load_files.emit(current_project.get_value("files", "include"), current_project.get_value("files", "exclude"))


func _on_recent_id_pressed(id: int) -> void:
	load_project(recent_menu.get_item_text(recent_menu.get_item_index(id)))


## Loads recent projects list to [member recent_menu].
func load_recent_projects() -> void:
	recent_menu.clear()
	# Load recent projects
	if FileAccess.file_exists(S.RECENT_PROJECTS_DATA):
		var recent_projects_list = FileAccess.get_file_as_string(S.RECENT_PROJECTS_DATA).split("\n", false)
		recent_projects_list = S.merge_unique(recent_projects_list, []) # Remove duplicate items
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
	var existing_content: String = FileAccess.get_file_as_string(S.RECENT_PROJECTS_DATA) if FileAccess.file_exists(S.RECENT_PROJECTS_DATA) else ""
	if "\n".join(recent_projects) != existing_content:
		var file := FileAccess.open(S.RECENT_PROJECTS_DATA, FileAccess.WRITE)
		if not file:
			Notif.notif(
				"save_file_failed",
				{"format_title": ["recent projects"], "text_append": error_string(FileAccess.get_open_error())}
			)
			return
		file.store_string("\n".join(recent_projects))
		file.close()


## Appends given project to recent projects.
func append_to_recent_projects(file_path: String) -> void:
	var file: FileAccess
	var files := ""
	if FileAccess.file_exists(S.RECENT_PROJECTS_DATA):
		files = FileAccess.get_file_as_string(S.RECENT_PROJECTS_DATA)
	file = FileAccess.open(S.RECENT_PROJECTS_DATA, FileAccess.WRITE)
	if not file:
		Notif.notif(
			"save_file_failed",
			{"format_title": ["recent projects"], "text_append": error_string(FileAccess.get_open_error())}
		)
		return
	file.store_string(file_path.replace("\\", "/") + "\n" + files)
	file.close()
	load_recent_projects()


## Converts given project file with provided script to another version.
func convert_project(script_path: String, project_file: String) -> void:
	var script: Object = U.load_resource(script_path).new()
	if not (script.has_method("convert_project") and script.has_signal("convert_completed")):
		Notif.notif("invalid_project_converter")
		script.free()
		return
	script.call("convert_project", project_file)
	Notif.notif("project_conversion_started")
	await script.convert_completed
	script.free()
	Notif.notif("project_conversion_completed")


## Caches project icon in editor data.
func cache_icon(path: String) -> String:
	if path == "" or not FileAccess.file_exists(path):
		return ""
	var cache_dir := S.FOLDER_CACHED_PROJECT_ICONS
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
	if not file:
		return ""
	file.store_buffer(icon)
	file.close()
	return target


## Returns name of current project or [code]"Unnamed Project"[/code].
func get_project_name() -> String:
	if not has_project():
		return "Unnamed Project"
	return current_project.get_value("project", "name", "Unnamed Project")


## Returns path to current project file.
func get_current_project_path() -> String:
	if has_project() and recent_menu.get_item_count() != 0:
		return recent_menu.get_item_text(0)
	return ""
