extends ActionScript

func _initialize() -> void:
	requires_file = true

func _run_action() -> void:
	Signals.open_find_panel.emit()
