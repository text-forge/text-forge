class_name NodeFactory
extends Node
## Fast way to create standard popups, menus, windows, etc.
##
## This is node factory of Text Forge. It's designed to generate useful nodes with signle function
## call. You can access to an instance of this class with [code]Factory[/code] singleton.


## Creates new [ConfirmationDialog] based on parameters.
func confirmation_dialog(
		text := "", ok_text := "OK", cancel_text := "Cancel", title := "Please Confirm",
		canceled := Callable(), confirmed := Callable(), show := true
) -> ConfirmationDialog:
	var dialog := ConfirmationDialog.new()
	dialog.dialog_text = text
	dialog.ok_button_text = ok_text
	dialog.cancel_button_text = cancel_text
	dialog.title = title
	dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	if canceled:
		dialog.canceled.connect(canceled)
	if confirmed:
		dialog.confirmed.connect(confirmed)
	dialog.visibility_changed.connect(func(): if not dialog.visible: dialog.queue_free())
	if show:
		dialog.ready.connect(dialog.popup)
	return dialog


func accept_dialog(
		text := "", title := "Alert!", confirmed := Callable(), size := Vector2i(500, 50),
		autowrap := false, show := true
) -> AcceptDialog:
	var dialog := AcceptDialog.new()
	dialog.title = title
	dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	dialog.size = size
	dialog.dialog_autowrap = autowrap
	dialog.dialog_text = text
	if confirmed:
		dialog.confirmed.connect(confirmed)
	dialog.visibility_changed.connect(func(): if not dialog.visible: dialog.queue_free())
	if show:
		dialog.ready.connect(dialog.popup)
	return dialog


## Creates new [MenuButton] based on parameters.
func menu_button(switch_on_hover := false, text := "") -> MenuButton:
	var button := MenuButton.new()
	button.switch_on_hover = switch_on_hover
	button.text = text
	return button


## Creates a [LineEdit] with [Button] for signle line input based on parameters. All will be in
## [PopupPanel] > [MarginContainer] > [HBoxContainer].
func signle_line_input(
		placeholder := "", button_text := "OK", output := Callable(), show := true
) -> PopupPanel:
	var panel := PopupPanel.new()
	var line_edit := LineEdit.new()
	var button := Button.new()
	line_edit.placeholder_text = placeholder
	button.text = "   {0}   ".format([button_text])
	line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line_edit.text_submitted.connect(panel.hide.unbind(1))
	button.pressed.connect(panel.hide)
	panel.visibility_changed.connect(func(): if not panel.visible and output: output.call(line_edit.text); panel.queue_free())
	if show:
		panel.ready.connect(panel.popup)
		panel.ready.connect(line_edit.grab_focus)
	panel.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	panel.size = Vector2(300, 0)
	panel.add_child(MarginContainer.new())
	panel.get_child(0).add_child(HBoxContainer.new())
	panel.get_child(0).get_child(0).add_child(line_edit)
	panel.get_child(0).get_child(0).add_child(button)
	return panel


## Creates new [FileDialog] based on parameters. If you want change default directory use
## [param current_dir], or use [param current_path] to select a file (or dir) as default.[br][br]
## [b]Note:[/b] When [param current_path] isn't [code]""[/code], [param current_dir] has no effect.
## Change [param current_path] will set path's parent directory as current directory.
func file_dialog(
		file_mode := FileDialog.FILE_MODE_SAVE_FILE, access := FileDialog.ACCESS_FILESYSTEM,
		filters := PackedStringArray(), callback := Callable(), show := true, current_dir := "",
		current_path := "", auto_free_on_select := true
) -> FileDialog:
	var dialog := FileDialog.new()
	dialog.file_mode = file_mode
	dialog.access = access
	dialog.filters = filters
	dialog.use_native_dialog = true
	dialog.dialog_hide_on_ok = true
	dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	if show:
		dialog.ready.connect(dialog.popup)
	dialog.dir_selected.connect(callback)
	dialog.file_selected.connect(callback)
	dialog.files_selected.connect(callback)
	if auto_free_on_select:
		dialog.dir_selected.connect(func(_path): dialog.queue_free())
		dialog.file_selected.connect(func(_path): dialog.queue_free())
		dialog.files_selected.connect(func(_paths): dialog.queue_free())
	dialog.canceled.connect(func(): dialog.queue_free())
	if current_path:
		dialog.current_path = current_path
	elif current_dir:
		dialog.current_dir = current_dir
	return dialog


## Creates new [TextForgePanel] with a margin container as child, useful for modes and where scripts
## create panels.
func simple_panel() -> TextForgePanel:
	return Global.load_resource("res://core/classes/simple_panel.tscn").instantiate()
