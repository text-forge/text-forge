extends MultiActionScript

func _run_action(item_id, popup) -> void:
	if request_save(item_id, popup): return
	Global.get_core().load_template(popup.get_item_text(popup.get_item_index(item_id)))
