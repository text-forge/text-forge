extends ActionScript

func _initialize() -> void:
	Notif.register_notification(
		"file_path_copied",
		Notif.Type.INFO,
		"File path copied."
	)
	requires_file = true
	requires_saved_file = true


func _run_action() -> void:
	DisplayServer.clipboard_set(Global.get_file_path())
	Notif.notif("file_path_copied")
