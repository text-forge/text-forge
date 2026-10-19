extends ActionScript

func _initialize() -> void:
	requires_file = true
	requires_saved_file = true


func _run_action() -> void:
	if Global.emit_save_request(id): return
	# Reloads in place, going through Signals.open_file would open a second tab for the same file.
	Global.get_editor_api().load_file(Global.get_file_path())
