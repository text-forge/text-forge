class_name FileDatabase
extends Object
## Source of file paths.
##
## This class holds file paths and template strings for file paths. All file paths are constants, so
## they can be used without instantiating this class.

# NOTE: keep file paths before folders ans folders before templates.

## Saved scene for menus like "File" and "Edit", see also [member Core.menu_container].
const MENU_BUTTON_SCENE = "res://core/prebuilds/menu_button.tscn"
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
## Root folder for saved templates.
const FOLDER_TEMPLATES = "user://templates/"
## Root folder for cached project icons.
const FOLDER_CACHED_PROJECT_ICONS = "user://project_icons/"
## Root folder for action scripts.
const FOLDER_ACTION_SCRIPTS = "res://action_scripts/"
## Root folder for modes.
const FOLDER_MODES = "user://modes/"
## Root folder for panels.
const FOLDER_PANELS = "res://data/panels/"
## Root folder for backups.
const FOLDER_BACKUPS = "user://backups/"
## Root folder for extensions.
const FOLDER_EXTENSIONS = "user://extensions/"
## Template file path for action script shotcut files.
const TEMPLATE_ACTION_SCRIPT_SHORTCUT = "res://shortcuts/{0}.tres"
## Template file path for action script files.
const TEMPLATE_ACTION_SCRIPT = "res://action_scripts/{0}.gd"
## Template file path for panel configs.
const TEMPLATE_PANEL_CONFIG = "res://data/panels/{0}/panel.cfg"
## Template file path for panel main scene.
const TEMPLATE_PANEL_SCENE = "res://data/panels/{0}/panel.tscn"
## Template file path for panel icon.
const TEMPLATE_PANEL_ICON = "res://data/panels/{0}/icon.png"
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

const IMAGE_EXTS = ["bmp", "dds", "ktx", "exr", "hdr", "jpg", "jpeg", "png", "tga", "svg", "webp"]
