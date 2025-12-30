class_name S
extends Object
## Global object for [b]static[/b] and shared method and properties.

## Path to UI configurations.
const MAIN_UI_DATA = "res://data/main_ui.ini"
## Path to main translation source.
const TRANSLATION_FILE = "res://data/translation.csv"
## Saved recent files list.
const RECENT_FILES_DATA = "user://recent_files.txt"
## Saved recent projects list.
const RECENT_PROJECTS_DATA = "user://recent_projects.txt"
## Path to backup database.
const BACKUP_DATABASE = "user://backups.ini"
const DEFAULT_MODES = "res://data/default_modes.tfmode"
## Root folder for saved templates.
const FOLDER_TEMPLATES = "user://templates/"
## Root folder for cached project icons.
const FOLDER_CACHED_PROJECT_ICONS = "user://project_icons/"
## Root folder for action scripts.
const FOLDER_ACTION_SCRIPTS = "res://action_scripts/"
## Root folder for modes.
const FOLDER_MODES = "user://modes/"
## Root folder for panels.
const FOLDER_PANELS = "res://core/panels/"
## Root folder for backups.
const FOLDER_BACKUPS = "user://backups/"
## Root folder for extensions.
const FOLDER_EXTENSIONS = "user://extensions/"
## Root folder for themes.
const FOLDER_THEMES = "user://themes/"
## Root folder for internal themes.
const FOLDER_INTERNAL_THEMES = "res://data/themes/"
## Template file path for action script shotcut files.
const TEMPLATE_ACTION_SCRIPT_SHORTCUT = "res://shortcuts/{0}.tres"
## Template file path for action script files.
const TEMPLATE_ACTION_SCRIPT = "res://action_scripts/{0}.gd"
## Template file path for panel main scene.
const TEMPLATE_PANEL_SCENE = "res://core/panels/{0}/panel.tscn"
## Template file path for panel main script.
const TEMPLATE_PANEL_SCRIPT = "res://core/panels/{0}/panel.gd"
## Template file path for panel icon.
const TEMPLATE_PANEL_ICON = "res://core/panels/{0}/icon.png"
## Template file path for extension configuration file.
const TEMPLATE_EXTENSION_CONFIG = "user://extensions/{0}/extension.cfg"
## Template file path for mode information file.
const TEMPLATE_MODE_INFO = "user://modes/{0}/mode.cfg"
## Template file path for mode script.
const TEMPLATE_MODE_SCRIPT = "user://modes/{0}/mode.gd"
## Template file path for mode icon.
const TEMPLATE_MODE_ICON = "user://modes/{0}/icon.png"
## Template file path for backup files.
const TEMPLATE_BACKUP_FILE = "user://backups/{0}"
## Template file path for themes.
const TEMPLATE_THEME = "user://themes/{0}.tres"
## Template file path for templates.
const TEMPLATE_TEMPLATES = "user://templates/{0}.txt"
## Valid image extensions for runtime loading.
const IMAGE_EXTS = ["bmp", "dds", "ktx", "exr", "hdr", "jpg", "jpeg", "png", "tga", "svg", "webp"]
## Editor version.
const EDITOR_VERSION = "0.2.0"
## [RegEx] pattern for template placeholders.
const PATTERN_PLACEHOLDER = r"\{\{\{(.*?)\}\}\}"

## Maps all array members to [int].
static func map_array_to_int(array: Array) -> Array[int]:
	return Array(array.map(func(e): return int(e)), TYPE_INT, "", null)


## Globalizes given [param path].
static func globalize_path(path: String) -> String:
	if path.begins_with("res://"):
		if OS.has_feature("editor"):
			path = ProjectSettings.globalize_path(path)
		else:
			path = OS.get_executable_path().get_base_dir().path_join(path.replace("res://", ""))
		return path
	return ProjectSettings.globalize_path(path)


## Calls [method Node.queue_free] for all children of given [param node].
static func free_all_children(node: Node) -> void:
	for c in node.get_children():
		c.queue_free()


## Merges two [Array]s and removes duplicated items.
static func merge_unique(array1: Array, array2: Array) -> Array:
	var merged_array = []
	for i in array1:
		if not merged_array.has(i):
			merged_array.append(i)
	for j in array2:
		if not merged_array.has(j):
			merged_array.append(j)
	return merged_array


## Adds a fade-out tween for given [param object].
static func fade_out(object: Node, duration := 1.0) -> Tween:
	var tween := object.create_tween()
	tween.tween_property(object, "modulate", Color.TRANSPARENT, duration)
	tween.tween_callback(object.hide)
	return tween
