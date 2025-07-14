class_name SignalBus
extends Node
## Signal bus accessable with [code]Signals[/code] autoload.
##
## This is main signal bus of Text Forge, a lot of connections and information transfers are carried
## out in this way.

@warning_ignore_start("unused_signal")

## Emits when a script run requested, it will send to all [ActionScript]s. (See also [method ActionScript.run])
signal run_script(script_id: int)
## Emits when a subscript run requested, it will send to all [MultiActionScript]s. (See also [method MultiActionScript.run])
signal run_subscript(subscript_id: int, submenu: PopupMenu, submenu_name: String)
## Will send to all scripts to check current state with them activation state.
signal check_options
## Standard way to send notifications between modules.[br]
## [b]Note:[/b] For extensions, use [GlobalExtensionHub].
signal notification(id: String, data: Array)
## Standard notifications from editor, see [enum GlobalAccess.Notification] for [param type] meanings.
signal editor_notification(type: Global.Notification, title: String, text: String)
## Requests close file, close script should connect itself to this.
signal close_file
## Requests open file, open script should connect itself to this.
signal open_file(path: String)
## Requests create new file, new script should connect itself to this.
signal new_file
## Requests saving changes, [param from] will send to savers and return here to emit [signal run_script] again.
signal save_request(from: int)
## Emits when save request finished, signal bus will emit [signal run_script] with [param to] id.
signal save_finished(to: int)
## Requests open find panel.
signal open_find_panel
## Requests shift find result selection.
signal shift_find_result(next: bool)
## Requests replace all find results.
signal replace_all
## Emits when user selects a caret (for multi caret edits that have caret selection support).
signal caret_selected(index: int)
## Emits when user selects a mode.
signal mode_selected(index: int)
## Emits when one or more setting option changed with centalized preferences editor. Connect your
## modules to this to reload related settings after change and apply them.
signal settings_changed
## Requests reload for recent files, [method Core._reload_recent_files] is basic connection.
signal reload_recent_files

@warning_ignore_restore("unused_signal")

func _ready() -> void:
	editor_notification.connect(_log_notification)
	save_request.connect(_handle_save_request)
	save_finished.connect(_resume_after_save)


## Connected to [signal editor_notification]. Prints notification with types.
func _log_notification(type: Global.Notification, title: String, text: String) -> void:
	var start: String
	match type:
		Global.Notification.INFO:
			start = "[color=white]Notification: Info: "
		Global.Notification.WARNING:
			start = "[color=yellow]Notification: Warning: "
		Global.Notification.ERROR:
			start = "[color=red]Notification: Error: "
		_:
			start = "[color=darkgray]Notification: Other: "
	print_rich("{0}{1}[/color]{2}{3}".format([start, title, "\n\t" if text != "" else "", text]))


## Connected to [signal save_request]. Creates a save change [ConfirmationDialog] and show it, [param confirmed] signal will connected
## to [method _save_changes] and [param canceled] will connected to [method _resum_after_save].
func _handle_save_request(from: int) -> void:
	add_child(Factory.confirmation_dialog(
			"You have unsaved changes in currently opened file, what do you want to do with them?",
			"Save", "Discard", "You have unsaved changes!", _resume_after_save.bind(from),
			_save_changes.bind(from), true
	))


## Calls [signal run_script] with id of save script and sets its callback to [param from], save
## action script will emit [signal save_finished] with [param from]. See save action script and
## [method _resume_after_save] for more information.
func _save_changes(from: int) -> void:
	Global.get_scripts_node().get_node("save").callback = from
	run_script.emit(Global.get_scripts_node().get_node("save").id)


## Connected to [signal save_finished]. If [param to] is [code]-1[/code] do nothing, otherwise, will
## wait 0.5 second, removes [code]*[/code] from file name and emits [signal run_script] with [param to].
func _resume_after_save(to: int) -> void:
	if to == -1:
		return
	await SLib.wait(0.5)
	Global.set_file_name(Global.get_file_name().replace("*", ""))
	run_script.emit(to)
