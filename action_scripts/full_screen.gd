extends ActionScript

func _initialize() -> void:
	if get_window().mode == Window.MODE_FULLSCREEN:
		menu.set_item_checked(menu.get_item_index(id), true)
		_run_action()

func _run_action() -> void:
	if menu.is_item_checked(menu.get_item_index(id)):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(int(Global.get_window_mode_before_fullscreen()))
	menu.set_item_checked(menu.get_item_index(id), get_window().mode == Window.MODE_FULLSCREEN)
