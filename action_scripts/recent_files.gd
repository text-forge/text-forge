extends MultiActionScript

func _run_action(item_id, popup) -> void:
	if Global.get_file_name().ends_with("*"):
		Global.send_notification(Global.Notification.INFO, "Please do this action again", "You have unsaved changes, But there isn's support for load recent files after save/discad changes.")
		await SLib.wait(1)
		Signals.close_file.emit()
		return
	Signals.open_file.emit(popup.get_item_text(popup.get_item_index(item_id)))
