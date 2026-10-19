extends CheckableActionScript

func _setup() -> void:
	settings_section = "edit"
	settings_key = "normalize_line_endings"
	default = true
	Global.get_editor_api().connect_to_hook(EditorAPI.Hooks.BEFORE_SAVE, _normalizer)
	Settings.define_preset("edit", "line_endings", "LF")
	_repair_line_endings()


## An old build could store a line endings value that is not a real one, the normalizer would then
## write the files with the wrong endings, so the preset default takes its place.
func _repair_line_endings() -> void:
	var stored := str(Settings.get_setting("edit", "line_endings"))
	if stored in S.LINE_ENDINGS:
		return
	Settings.set_setting("edit", "line_endings", Settings.get_default("edit", "line_endings"), true)


func _get_value() -> bool:
	return Settings.get_setting(settings_section, settings_key)


func _set_value(to: bool) -> void:
	Signals.check_options.emit()


func _normalizer() -> void:
	if not _get_value():
		return
	var _text := Global.get_editor_text()
	_text = _text.replace("\r\n", "\n")
	_text = _text.replace("\r", "\n")
	var saved_eol: String = Settings.get_setting("edit", "line_endings")
	var eol: String
	if saved_eol == "LF":
		eol = "\n"
	elif saved_eol == "CRLF":
		eol = "\r\n"
	else:
		eol = "\r"
	_text = _text.replace("\n", eol)
	Global.set_editor_text(_text, true)
