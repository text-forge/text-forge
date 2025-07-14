extends ActionScript

func _initialize() -> void:
	requires_file = true

func _run_action() -> void:
	Signals.shift_find_result.emit(true)
