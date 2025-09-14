extends MenuButton

func _ready() -> void:
	Signals.mode_changed.connect(_update_mode.unbind(1))


func _update_mode() -> void:
	var current_mode := Global.get_editor_api().current_mode
	get_popup().clear(true)
	if current_mode == {}:
		text = "Current Mode: None"
	else:
		text = "Current Mode: " + current_mode["name"]
	var modes := PopupMenu.new()
	var extensions := PopupMenu.new()
	for m in Global.get_editor_api().mode_list:
		var mode_extensions := PopupMenu.new()
		for e in m["extensions"]:
			extensions.add_item(e)
			mode_extensions.add_item(e)
		modes.add_submenu_node_item("{0} ({1})".format([m["name"], m["id"]]), mode_extensions)
	get_popup().add_submenu_node_item("Modes ({0})".format([modes.item_count]), modes)
	get_popup().add_submenu_node_item("Available extensions ({0})".format([extensions.item_count]), extensions)
