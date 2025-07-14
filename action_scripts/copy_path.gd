extends ActionScript

func _initialize() -> void:
	requires_file = true
	requires_saved_file = true

func _run_action() -> void:
	DisplayServer.clipboard_set(Global.get_file_path())
	Global.send_notification(Global.Notification.INFO, "File path copied.")
