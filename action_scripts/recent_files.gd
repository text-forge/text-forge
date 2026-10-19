extends MultiActionScript

func _run_action(item_id: int, popup: PopupMenu) -> void:
	Signals.open_file.emit(popup.get_item_text(popup.get_item_index(item_id)))
