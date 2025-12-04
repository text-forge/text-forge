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
var settings := ConfigFile.new()
## [ConfigFile] loaded for presets.
var presets := ConfigFile.new()
## [ConfigFile] loaded for editor data.
var data := ConfigFile.new()

func _ready() -> void:
	if FileAccess.file_exists(S.globalize_path(DATA_FILE)):
		var err := data.load(S.globalize_path(DATA_FILE))
		if err:
			Global.send_notification(
				Global.Notification.ERROR,
				"Failed to open data file!",
				"Error code: " + str(err)
			)
	if FileAccess.file_exists(S.globalize_path(PRESETS_FILE)):
		var err := presets.load(S.globalize_path(PRESETS_FILE))
		if err:
			Global.send_notification(
				Global.Notification.ERROR,
				"Failed to open presets file!",
				"Error code: " + str(err)
			)
	if FileAccess.file_exists(S.globalize_path(SETTINGS_FILE)):
		var err := settings.load(S.globalize_path(SETTINGS_FILE))
		if err:
			Global.send_notification(
				Global.Notification.ERROR,
				"Failed to open settings file!",
				"Error code: " + str(err)
			)


## Returns stored setting, if [param default] is [code]null[/code] will load it from
## [method get_default] (witch will be [code]null[/code] if this preset was not defined), otherwise
## uses [param default] for [method ConfigFile.get_value], so if default is not specified or set to
## null, an error is also raised.
func get_setting(section: String, key: String, default: Variant = null) -> Variant:
	if default == null:
		default = get_default(section, key)
	return settings.get_value(section, key, default)


## Same as [method get_setting] but just for [bool] values. (for static typing)
func get_setting_bool(section: String, key: String, default: Variant = null) -> bool:
	return bool(get_setting(section, key, default))


## Sets default value for given setting, see also [method get_default].
func restore_default(section: String, key: String) -> void:
	set_setting(section, key, get_default(section, key))


## Sets [param velue] for given setting and save settings.
func set_setting(section: String, key: String, value: Variant = null, force_silent := false) -> void:
	if settings.has_section_key(section, key):
		if get_setting(section, key) == value:
			return
	settings.set_value(section, key, value)
	var err := settings.save(SETTINGS_FILE)
	if err:
		Global.send_notification(
			Global.Notification.ERROR,
			"Can't save settings file!",
			"Error code: " + str(err)
		)
		return
	if not force_silent:
		Signals.settings_changed.emit()


## Defines new preset, it means this preset will have default value ([param default]) and can reset
## linked setting to it, if your module uses any setting, you should define presets for them in
## module initialization with this function.
func define_preset(section: String, key: String, default: Variant = null) -> void:
	presets.set_value(section, key, default)
	var err := presets.save(PRESETS_FILE)
	if err:
		Global.send_notification(
			Global.Notification.ERROR,
			"Can't save preset source!",
			"Error code: " + str(err)
		)


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
func write_data(section: String, key: String, value = null) -> void:
	data.set_value(section, key, value)
	_save_data()


func _save_data() -> void:
	var err := data.save(DATA_FILE)
	if err:
		Global.send_notification(
			Global.Notification.ERROR,
			"Can't save data file!",
			"Error code: " + str(err)
		)
