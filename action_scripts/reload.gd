extends ActionScript

func _initialize() -> void:
	requires_file = true
	requires_saved_file = true


func _run_action() -> void:
	if Global.emit_save_request(id): return
	Signals.open_file.emit(Global.get_file_path())
