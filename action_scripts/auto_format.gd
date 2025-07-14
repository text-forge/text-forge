extends ActionScript

func _initialize() -> void:
	requires_file = true
	requires_saved_file = true

func _run_action() -> void:
	Global.get_editor_api().auto_format()
	Global.get_editor().text_changed.emit()
