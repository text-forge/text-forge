extends ActionScript

func _initialize() -> void:
	Notif.register_notification(
		"secure_delete_completed",
		Notif.Type.INFO,
		"Secure delete complete."
	)
	requires_file = true
	requires_saved_file = true


func _run_action() -> void:
	if Global.emit_save_request(id): return
	add_child(Factory.confirmation_dialog(
			"Secure delete will remove saved file byte by byte and you will not be able to restore this file, are you sure?",
			"Yes, Delete for ever",
			"Cancel",
			"Are you sure? we can't undo this action!",
			Callable(),
			_secure_delete,
			true
	))


func _secure_delete() -> void:
	var clear_buffer: Array
	for i in FileAccess.get_file_as_bytes(Global.get_file_path()).size():
		clear_buffer.append(0)
	var file = FileAccess.open(Global.get_file_path(), FileAccess.WRITE)
	file.store_buffer(PackedByteArray(clear_buffer))
	file.close()
	DirAccess.remove_absolute(S.globalize_path(Global.get_file_path()))
	Signals.close_file.emit()
	Notif.notif("secure_delete_completed")
