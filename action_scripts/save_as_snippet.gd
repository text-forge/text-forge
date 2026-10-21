extends ActionScript

func _initialize() -> void:
	Notif.register_notification(
		"invalid_snippet_name",
		Notif.Type.ERR,
		"Invalid snippet name!",
		"Please use letters, numbers, space, dash or underscore."
	)
	Notif.register_notification(
		"save_snippet_failed",
		Notif.Type.ERR,
		"Failed to save file as snippet!",
		"Error: "
	)
	Notif.register_notification(
		"save_snippet_completed",
		Notif.Type.INFO,
		"Snippet saved."
	)
	requires_file = true


func _run_action() -> void:
	add_child(Factory.confirmation_dialog(
		"Do you want to save this file as snippet?\nYou can use {{{Key Name}}} to add placeholders.",
		"Yes",
		"No, Cancel",
		"Save as snippet?",
		Callable(),
		_ask_for_name,
		true
	))


func _ask_for_name() -> void:
	add_child(Factory.single_line_input("Snippet Name", "Save", _save_snippet, true))


func _save_snippet(_name: String) -> void:
	_name = _name.strip_edges().validate_filename()
	if _name.is_empty():
		Notif.notif("invalid_snippet_name")
		return
	if not DirAccess.dir_exists_absolute(S.globalize_path(S.FOLDER_SNIPPETS)):
		DirAccess.make_dir_recursive_absolute(S.globalize_path(S.FOLDER_SNIPPETS))
	var path := S.TEMPLATE_SNIPPETS.format([_name])
	var file_access := FileAccess.open(path, FileAccess.WRITE)
	if not file_access:
		Notif.notif("save_snippet_failed", {"text_append": error_string(FileAccess.get_open_error())})
		return
	file_access.store_string(Global.get_editor_text())
	file_access.close()
	Notif.notif("save_snippet_completed")
	Global.get_core().reload_snippets()
