class_name ProjectSettingsWindow
extends Window
## A window to view and modify project settings.

## Path to project file item's instance.
const FILE_NODE_SCN: PackedScene = preload("res://action_scripts/scenes/project_file_item.tscn")

## [TextEdit] for project details.
@export var details_edit: TextEdit
## List of excluded files.
@export var exclude_files: VBoxContainer
## Button to change icon.
@export var icon_button: Button
## List of include files.
@export var include_files: VBoxContainer
## [LineEdit] for project name.
@export var name_edit: LineEdit
## [LineEdit] for project tags.
@export var tags_edit: LineEdit

func _ready() -> void:
	name_edit.text = Project.current_project.get_value("project", "name")
	details_edit.text = Project.current_project.get_value("project", "details")
	icon_button.text = (
		Project.current_project.get_value("project", "icon")
		if Project.current_project.has_section_key("project", "icon")
		else "Select file"
	)
	tags_edit.text = Project.current_project.get_value("project", "tags")
	for include in Project.current_project.get_value("files", "include"):
		var n: HBoxContainer = FILE_NODE_SCN.instantiate()
		n.get_child(0).text = include
		n.get_child(1).pressed.connect(_remove_file.bind(include, include_files))
		n.show()
		include_files.add_child(n)
	for exclude in Project.current_project.get_value("files", "exclude"):
		var n: HBoxContainer = FILE_NODE_SCN.instantiate()
		n.get_child(0).text = exclude
		n.get_child(1).pressed.connect(_remove_file.bind(exclude, exclude_files))
		n.show()
		exclude_files.add_child(n)


func _add_file(path, container: VBoxContainer) -> void:
	var paths: Array = path if path is PackedStringArray else [path]
	var existing := container.get_children().map(func(file): return file.get_child(0).text)
	for p in paths:
		if p in existing:
			continue
		var n: HBoxContainer = FILE_NODE_SCN.instantiate()
		n.get_child(0).text = p
		n.get_child(1).pressed.connect(_remove_file.bind(p, container))
		n.show()
		container.add_child(n)
		existing.append(p)


func _icon_selected(path: String) -> void:
	icon_button.text = path


func _on_add_exclude_pressed(type: int) -> void:
	add_child(Factory.file_dialog(type, FileDialog.ACCESS_FILESYSTEM, [],
	_add_file.bind(exclude_files), true, OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS), ""))


func _on_add_include_pressed(type: int) -> void:
	add_child(Factory.file_dialog(type, FileDialog.ACCESS_FILESYSTEM, [],
	_add_file.bind(include_files), true, OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS), ""))


func _on_icon_pressed() -> void:
	add_child(Factory.file_dialog(
		FileDialog.FILE_MODE_OPEN_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		[
			"*.png;PNG Image;image/png",
			"*.jpg,*.jpeg;JPEG Image;image/jpeg",
			"*.svg;SVG Image;image/svg+xml",
			"*.bmp;BitMap Image;image/bmp",
			"*.webp;WEBP Image;image/webp",
			"*.tga;X-TGA Image;image/x-tga",
			"*.hdr;HDR Image (Radiance);image/vnd.radiance",
			"*.dds;DDS Image;image/vnd.ms-dds",
			"*.ktx;KTX Image;image/ktx",
			"*.exr;EXR Image;image/exr",
		],
		_icon_selected,
		true,
		OS.get_system_dir(OS.SYSTEM_DIR_PICTURES),
		""
	))


func _on_save_pressed() -> void:
	if name_edit.text.is_empty():
		add_child(Factory.accept_dialog("Please enter a name for your project.", "Alert!",
				Callable(), Vector2i(500, 50), true, true))
		return
	if include_files.get_child_count() == 0:
		add_child(Factory.accept_dialog("Your project must include at least one file or folder.",
				"Alert!", Callable(), Vector2i(500, 50), true, true))
		return

	var config := ConfigFile.new()
	config.load(Project.get_current_project_path())
	var old := config.encode_to_text()
	config.set_value("project", "name", name_edit.text)
	config.set_value("project", "details", details_edit.text)
	if icon_button.text.get_extension().to_lower() in S.IMAGE_EXTS:
		# Validate the new icon file exists
		if not FileAccess.file_exists(icon_button.text):
			add_child(Factory.accept_dialog(
				"The selected icon file does not exist or is not accessible.",
				"Icon Error!",
				Callable(),
				Vector2i(500, 50),
				true,
				true
			))
			return
		var old_icon_path: String = config.get_value("project", "icon", "")
		var should_update := false
		if old_icon_path.is_empty() or not FileAccess.file_exists(old_icon_path):
			# No previous icon or previous icon no longer exists - set new icon
			should_update = true
		else:
			# Both files exist - compare their contents
			var old_bytes := FileAccess.get_file_as_bytes(old_icon_path)
			var new_bytes := FileAccess.get_file_as_bytes(icon_button.text)
			should_update = (old_bytes != new_bytes)
		if should_update:
			config.set_value("project", "icon", Project.cache_icon(icon_button.text))
	config.set_value("project", "tags", tags_edit.text.strip_edges())
	config.set_value("files", "include", include_files.get_children().map(func(file):
		return file.get_child(0).text))
	config.set_value("files", "exclude", exclude_files.get_children().map(func(file):
		return file.get_child(0).text))
	var new := config.encode_to_text()
	if old != new:
		config.set_value("project", "modified", Time.get_datetime_string_from_system(false, true))
		var err := config.save(Project.get_current_project_path())
		if err:
			Notif.notif(
				"save_project_failed",
				{
					"format_title": [Project.get_current_project_path()],
					"text_append": error_string(err),
				}
			)
			return
		await get_tree().process_frame
		Project.load_project(Project.get_current_project_path())
	queue_free()


func _remove_file(path: String, container: VBoxContainer) -> void:
	for file in container.get_children():
		if file.get_child(0).text == path:
			file.queue_free()
			break
