class_name SettingsAPI
extends Node
## Autoload singleton for manage configuration and settings.
##
## This class is an autoload ([code]Settigns[/code]), this object can handle settings define, set,
## get, and reset. All changes will save in [b]INI[/b] style in [code].cfg[/code] files in
## [code]user://[/code].[br]
## There is two type of data in this object: preset and setting.[br]
## [b]Presets:[/b] presets are sources of settings, they have section, key and default value. A preset with
## section and key is pattern of a setting with same section and key, it means default value of
## setting is stored value in preset.[br]
## [b]Settings:[/b] settings are regular configurations, with section, key and value. You can save
## current value of configurations in settings.[br][br]
## [b]Note:[/b] You can have settings without presets, but it isn't recommended.[br][br]
## [b]example usage:[/b]
## [codeblock]
## extends Control
##
## func _ready() -> void:
##     # setup presets here
##     Settings.define_preset("note_module", "note", "You can type anything here!")
##     # then load settings
##     # param default is null, so it will use defined default if there is no saved data
##     $Notes.text = Settings.get_setting("note_module", "note")
##
## func _on_notes_text_changed(new_text: String) -> void:
##     # save settings
##     Settings.set_setting("note_module", "note", new_text)
##
## func _on_reset_pressed() -> void:
##     # reset to defined value, will be same as its preset
##     Settings.restore_default("note_module", "note")
## [/codeblock]

## File path to settings data.
const SETTINGS_FILE := "user://settings.cfg"
## File path to presets data, this file is storage of available settings and default values, see
## [method define_preset] for more information.
const PRESETS_FILE := "user://presets.cfg"
## File path to configuration data.
const DATA_FILE := "user://data.cfg"

## [ConfigFile] loaded for settings.
static var settings := ConfigFile.new()
## [ConfigFile] loaded for presets.
static var presets := ConfigFile.new()
## [ConfigFile] loaded for editor data.
static var data := ConfigFile.new()

static var ACTION_PLAN: Array[Dictionary] = [
	{"path": DATA_FILE, "object": data, "open_file_name": "data", "save_file_name": "data file", "load_failed": false},
	{"path": PRESETS_FILE, "object": presets, "open_file_name": "presets", "save_file_name": "presets source", "load_failed": false},
	{"path": SETTINGS_FILE, "object": settings, "open_file_name": "settings", "save_file_name": "settings file", "load_failed": false},
]

func _init() -> void:
	for step in ACTION_PLAN:
		if not FileAccess.file_exists(S.globalize_path(step.path)):
			continue
		var err: Error = step.object.load(S.globalize_path(step.path))
		if err:
			step.load_failed = true
			OS.alert("Failed to open " + step.open_file_name + " to setup editor!")


func _ready() -> void:
	get_window().close_requested.connect(flush)


func _notification(what: int) -> void:
	# Additional flush calls to keep changes safe
	if what in [
		NOTIFICATION_CRASH,
		NOTIFICATION_WM_GO_BACK_REQUEST,
		NOTIFICATION_APPLICATION_FOCUS_OUT,
		NOTIFICATION_EXIT_TREE,
		]:
		flush()


## Saves [member data], [member presets], and [member settings] to data files.
func flush() -> Error:
	var error := OK
	for step in ACTION_PLAN:
		if step.load_failed:
			continue
		var err: Error = step.object.save(step.path)
		if err:
			Notif.notif(
				"save_file_failed",
				{
					"format_title": [step.save_file_name],
					"text_append": error_string(err)
				}
			)
			error = err
			continue
	return error


## Returns stored setting, if [param default] is [code]null[/code] will load it from
## [method get_default] (witch will be [code]null[/code] if this preset was not defined), otherwise
## uses [param default] for [method ConfigFile.get_value], so if default is not specified or set to
## null, an error is also raised.
func get_setting(section: String, key: String, default: Variant = null) -> Variant:
	if default == null:
		default = get_default(section, key)
	return settings.get_value(section, key, default)


## Sets default value for given setting, see also [method get_default].
func restore_default(section: String, key: String) -> void:
	set_setting(section, key, get_default(section, key))


## Sets [param velue] for given setting and save settings.
func set_setting(section: String, key: String, value: Variant = null, force_silent := false) -> void:
	if settings.has_section_key(section, key):
		if get_setting(section, key) == value:
			return
	settings.set_value(section, key, value)
	if not force_silent:
		Signals.settings_changed.emit()


## Defines new preset, it means this preset will have default value ([param default]) and can reset
## linked setting to it, if your module uses any setting, you should define presets for them in
## module initialization with this function.
func define_preset(section: String, key: String, default: Variant = null) -> void:
	presets.set_value(section, key, default)


## Returns default value for given preset, witch can be set by [method define_preset]. For
## none-existent preset will return [code]null[/code] without any error.
func get_default(section: String, key: String) -> Variant:
	if presets.has_section_key(section, key):
		return presets.get_value(section, key)
	else:
		return null


## Reads data from [member data].
func read_data(section: String, key: String, default = null) -> Variant:
	return data.get_value(section, key, default)


## Writes data to [member data].
func write_data(section: String, key: String, value = null, force_flush := false) -> void:
	data.set_value(section, key, value)
	if force_flush:
		if ACTION_PLAN[0].load_failed:
			Notif.notif(
				"save_file_failed",
				{
					"format_title": [ACTION_PLAN[0].save_file_name],
					"text_append": "Data was not loaded"
				}
			)
			return
		var err := data.save(DATA_FILE)
		if err:
			Notif.notif(
				"save_file_failed",
				{
					"format_title": ["data file"],
					"text_append": error_string(err)
				}
			)
