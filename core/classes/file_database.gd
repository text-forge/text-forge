class_name FileDatabase
extends Object
## Source of file paths.
##
## This class holds file paths and template strings for file paths. All file paths are constants, so
## they can be used without instantiating this class.

# NOTE: keep file paths before folders ans folders before templates.

## Saved scene for menus like "File" and "Edit", see also [member Core.menu_container].
const MENU_BUTTON_SCENE: String = "res://core/prebuilds/menu_button.tscn"
## Path to UI configurations.
const MAIN_UI_DATA: String = "res://data/main_ui.ini"
## Path to data file, this is for custom configurations, for standard configuration save/load use
## [SettingsAPI].
const DATA_FILE: String = "user://data.cfg"
## Path to main translation source.
const TRANSLATION_FILE: String = "res://data/translation.csv"
## Saved recent files list.
const RECENT_FILES_DATA: String = "user://recent_files.txt"
## Root folder for saved templates.
const FOLDER_TEMPLATES: String = "user://templates/"
## Root folder for action scripts.
const FOLDER_ACTION_SCRIPTS: String = "res://action_scripts/"
## Root folder for modes.
const FOLDER_MODES: String = "user://modes/"
## Root folder for panels.
const FOLDER_PANELS: String = "res://data/panels/"
## Template file path for action script shotcut files.
const TEMPLATE_ACTION_SCRIPT_SHORTCUT: String = "res://shortcuts/{0}.tres"
## Template file path for action script files.
const TEMPLATE_ACTION_SCRIPT: String = "res://action_scripts/{0}.gd"
## Template file path for panel configs.
const TEMPLATE_PANEL_CONFIG: String = "res://data/panels/{0}/panel.cfg"
## Template file path for panel main scene.
const TEMPLATE_PANEL_SCENE: String = "res://data/panels/{0}/panel.tscn"
## Template file path for panel icon.
const TEMPLATE_PANEL_ICON: String = "res://data/panels/{0}/icon.png"
