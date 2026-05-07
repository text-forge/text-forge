extends ActionScript

func _initialize() -> void:
	Notif.register_notification(
		"invalid_template_name",
		Notif.Type.ERR,
		"Invalid template name!",
		"Please use letters, numbers, space, dash or underscore."
	)
	Notif.register_notification(
		"save_template_failed",
		Notif.Type.ERR,
		"Failed to save file as template!",
		"Error: "
	)
	Notif.register_notification(
		"save_template_completed",
		Notif.Type.INFO,
		"Template saved."
	)
	requires_file = true


func _run_action() -> void:
	add_child(Factory.confirmation_dialog(
		"Do you want to save this file as template?\nYou can use {{{Key Name}}} to add placeholders.",
		"Yes",
		"No, Cancel",
		"Save as template?",
		Callable(),
		_ask_for_name,
		true
	))


func _ask_for_name() -> void:
	add_child(Factory.single_line_input("Template Name", "Save", _save_template, true))


func _save_template(_name: String) -> void:
	_name = _name.strip_edges().validate_filename()
	if _name.is_empty():
		Notif.notif("invalid_template_name")
		return
	if not DirAccess.dir_exists_absolute(S.globalize_path(S.FOLDER_TEMPLATES)):
		DirAccess.make_dir_recursive_absolute(S.globalize_path(S.FOLDER_TEMPLATES))
	var path := S.TEMPLATE_TEMPLATES.format([_name])
	var file_access := FileAccess.open(path, FileAccess.WRITE)
	if not file_access:
		Notif.notif(
			"save_template_failed",
			{"text_append": error_string(FileAccess.get_open_error())}
		)
		return
	file_access.store_string(Global.get_editor_text())
	file_access.close()
	Notif.notif("save_template_completed")
	Global.get_core().reload_templates()
	Global.set_file_name(Global.get_file_name().replace("*", ""))
	Signals.open_file.emit(path)
