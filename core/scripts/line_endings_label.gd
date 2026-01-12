class_name LineEndings
extends MenuButton
## Shows line endings settings to user and provides settings changing.

func _ready() -> void:
	Global.get_editor().type_timer_timeout.connect(_update_label)
	Signals.settings_changed.connect(_update_label)
	get_popup().id_pressed.connect(_on_id_pressed)
	_update_label()


func _update_label() -> void:
	var _is_enable: bool = Settings.get_setting("edit", "normalize_line_endings")
	var _char: String = Settings.get_setting("edit", "line_endings")
	if _is_enable:
		text = _char
	else:
		var _text := Global.get_editor_text()
		_text = _text.replace("<<CRLF>>", "")
		_text = _text.replace("\r\n", "<<CRLF>>")
		var _crlf_count := _text.count("<<CRLF>>")
		var _lf_count := _text.count("\n")
		var _cr_count := _text.count("\r")
		if _lf_count >= _crlf_count and _lf_count >= _cr_count:
			text = "LF"
		elif _crlf_count >= _cr_count and _crlf_count >= _lf_count:
			text = "CRLF"
		else:
			text = "CR"
	if not _is_enable:
		text += "*"
	tooltip_text = "Current EOL" + (
		"\n*Auto normalizer is disabled"
		if not _is_enable else
		""
	)


func _on_id_pressed(id: int) -> void:
	match id:
		0:
			_eol_to("\n")
		1:
			_eol_to("\r\n")
		2:
			_eol_to("\r")


func _eol_to(to: String) -> void:
	var _text := Global.get_editor_text()
	_text = _text.replace("\r\n", "\n")
	_text = _text.replace("\r", "\n")
	_text = _text.replace("\n", to)
	Global.set_editor_text(_text, true)
	var _save_eol: String
	if to == "\n":
		_save_eol = "LF"
	elif to == "\r\n":
		_save_eol = "CRLF"
	else:
		_save_eol = "CR"
	Settings.set_setting("edit", "line_endings", _save_eol)
