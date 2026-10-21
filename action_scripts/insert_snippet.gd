extends MultiActionScript

func _run_action(item_id, popup) -> void:
	Global.get_core().insert_snippet(popup.get_item_text(popup.get_item_index(item_id)))
