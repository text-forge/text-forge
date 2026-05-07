extends MultiActionScript

func _run_action(item_id: int, popup: PopupMenu) -> void:
	if request_save(item_id, popup): return
	Signals.open_file.emit(popup.get_item_text(popup.get_item_index(item_id)))
