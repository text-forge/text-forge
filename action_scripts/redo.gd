extends ActionScript

func _initialize() -> void:
	requires_file = true
	Documents.watch(&"type_timer_timeout", _check_redo)


func _run_action() -> void:
	Global.get_editor().redo()


func _check_redo() -> void:
	menu.set_item_disabled(menu.get_item_index(id), not Global.get_editor().has_redo())
