class_name TextForgeTranslator
extends Node
## Text Forge Translation and localization tool.
##
## This class is an autoload ([code]TFT[/code]) for translation feature in Text Forge, based on
## Text Forge modularity we haven't any translation database, so if translate texts of module is
## required, module should hold its translation csv file.[br][br]
## [b]Note:[/b] This function will send notifications, but can't translate itself notifications
## because this action can make infinite loop, so notifications from this function will be english![br]
## [b]Note:[/b] Notifications from this function at editor initializing time will not shown, because
## translation task will done before notification UI systems initializing.

## Section name for this module configurations.
const CONFIG_SECTION: String = "languages"
## Key name for main language configuration.
const CONFIG_MAIN_KEY: String = "main"
## Key name for fallback language configuration.
const CONFIG_FALLBACK_KEY: String = "fallback"
## File path to temprory translation source.
const TEMP_TRANSLATION_SOURCE: String = "user://_translation.cfg"

## Current language code, use [method set_language] to set it.
var language: String
## Language code for fallbacks, use [method set_language] to set it.
var fallback: String


func _ready() -> void:
	# define presets
	Settings.define_preset(CONFIG_SECTION, CONFIG_MAIN_KEY, "en")
	Settings.define_preset(CONFIG_SECTION, CONFIG_FALLBACK_KEY, "en")

	Signals.settings_changed.connect(_load_config)
	_load_config()


## Loads [member language] and [member fallback] from settings.
func _load_config() -> void:
	language = Settings.get_setting(CONFIG_SECTION, CONFIG_MAIN_KEY)
	fallback = Settings.get_setting(CONFIG_SECTION, CONFIG_FALLBACK_KEY)


## Stes [member language] and [member fallback] to [param language_code] and [param fallback_code].
## If a parammeter be [code]"default"[/code] will loaded from default settings.
func set_language(language_code: String = "default", fallback_code: String = "default") -> void:
	if language_code == "default":
		language_code = Settings.get_default(CONFIG_SECTION, CONFIG_MAIN_KEY)
	if fallback_code == "default":
		fallback_code = Settings.get_default(CONFIG_SECTION, CONFIG_FALLBACK_KEY)

	language = language_code
	fallback = fallback_code

	Settings.set_setting(CONFIG_SECTION, CONFIG_MAIN_KEY, language)
	Settings.set_setting(CONFIG_SECTION, CONFIG_FALLBACK_KEY, fallback)


## Returns translated text from a saved [b]csv[/b] file, possible exceptions:[br]
##  - [param source_file] does not exist: [code]Can't load translation data[/code] error, returns [param key].[br]
##  - [member language] does not exist but the [member fallback] is successful: [code]Translation fallback to %fallback%[/code] warning, returns translated key to fallback language.[br]
##  - [member language] and [member fallback] do not exist: [code]Invalid language code![/code] error, returns [param key].[br]
##  - [param key] does not exist: [code]Invalid translation key![/code] error, returns [param key].
func get_text(key: String, source_file: String) -> String:
	if key == "":
		return ""

	if not FileAccess.file_exists(source_file):
		Signals.notification.emit(Global.Notification.ERROR, "Can't load translation data", "File {0} doesn't exitsts!".format([source_file]))
		return key

	var file := FileAccess.open(source_file, FileAccess.READ)
	var column_names := file.get_csv_line()
	var lang
	if not column_names.has(language):
		if not column_names.has(fallback):
			Signals.notification.emit(Global.Notification.ERROR, "Invalid language code!", "Language {0} doesn't exitst in {1}, usign fallback language ({2}) failed.".format([language, source_file, fallback]))
			file.close()
			return key
		else:
			Signals.notification.emit(Global.Notification.WARNING, "Translation fallback to {0}".format([fallback]), "Can't find language {0} in translation source: {1}, using fallback language".format([language, source_file]))
			lang = fallback
	else:
		lang = language
	var index = column_names.find(lang)
	while file.get_position() < file.get_length():
		var line = file.get_csv_line()
		if line[0] == key:
			file.close()
			if line.size() == 1:
				return line[0]
			return line[index] if line.size() > index else line[1]
	Signals.notification.emit(Global.Notification.ERROR, "Invalid translation key!", "Can't find key \"{0}\" in translation source: {1}".format([key, source_file]))
	file.close()

	## Remove temprory translation file
	if FileAccess.file_exists(TEMP_TRANSLATION_SOURCE):
		DirAccess.remove_absolute(TEMP_TRANSLATION_SOURCE)

	return key


## Returns translated [param key] from [param source] string csv.
## [br][b]Note:[/b] This function will save [param source] in [constant TEMP_TRANSLATION_SOURCE]
## and call [method get_text] for it, so if there is any bug you will see this file as source file.
func get_text_from_string_source(key: String, source: String) -> String:
	var file = FileAccess.open(TEMP_TRANSLATION_SOURCE, FileAccess.WRITE)
	file.store_string(source)
	file.close()
	return get_text(key, TEMP_TRANSLATION_SOURCE)
