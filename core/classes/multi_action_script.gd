class_name MultiActionScript
extends Node
## Base class for multi action scripts.
##
## An [ActionScript] with submenu support. This is class of scripts in [code]res://action_scripts[/code]
## with submenu as linked menu option.[br][br]
## Features:[br]
## - Access to linked menu option.[br]
## - Automated shortcut loading.[br]
## - Automated enable/disable linked menu option.[br]
## - Translate [InputEventKey] to [enum Key] with masks.[br]
## - Show submenu based on shortcut.[br]
## - Receive clicks on submenu items.[br][br]
## [b]Important:[/b] Toggle linked item for checkboxes and radio checkboxes will handle in [Core],
## don't do it here![br]
## [b]Note:[/b] Functions with [b][color=lightblue]Virtual[/color][/b] badges is intended to be
## overriden.

## Unique identifier for this action script, this value is id of linked option in [member menu] too.
var id: int
## Index of linked option in [member menu], will use [code]menu.get_item_index(id)[/code] as getter.
## So this is a shortcut to item.
var index: int
## Parent [PopupMenu].
var menu: PopupMenu
## Specifies whether this action script requires opened file or no. See also [method _check_option].
var requires_file := false
## Specifies whether this action script requires saved file or no. See also [method _check_option].
var requires_saved_file := false
## [Shortcut] for this action script. See also [method _load_shortcut].
var action_shortcut := Shortcut.new()
## Specifiest this action script is now runable or no.
var enable := true:
	set(value):
		if value != enable:
			menu.set_item_disabled(index, not value)
		enable = value

## Called after add action script in [SceneTree]. See also [method Node._enter_tree].
func _enter_tree() -> void:
	index = menu.get_item_index(id)
	_initialize()
	_load_shortcut()
	_define_action()


## Handles shortcut pressing, when [param event] matches with [member action_shortcut] [member menu]
## will popup and linked submenu will popup in center. (See also [method PopupMenu.popup_centered]
## and [method Shortcut.metches_event])
func _shortcut_input(event: InputEvent) -> void:
	if action_shortcut.matches_event(event):
		menu.popup()
		menu.get_item_submenu_node(index).popup_centered()


## [b][color=lightblue]Virtual[/color][/b][br]
## Called from [method _enter_tree], Override it for initialize you action script.
func _initialize() -> void:
	pass


## Sets linked item enabled/disabled based on current situation.[br][br]
## [b]Note:[/b] Use [method _check_option_extra] for customizing.
func _check_option() -> void:
	var has_file := (not Global.is_editor_disabled()) if requires_file else true
	var has_saved_file := Global.has_file() if requires_saved_file else true
	enable = has_file and has_saved_file and _check_option_extra()


## Override this function to add more check for option state. When returns [code]false[/code] option
## will be disable, but when returns [code]true[/code] it depends on internal [method _check_option]
## logic. (see also [member requires_file] and [member requires_saved_file].)
func _check_option_extra() -> bool:
	return true


## Loads shortcut as item accelerator (see also [method PopupMenu.set_item_accelerator]). For
## [ActionScript]s it means call [method _run_action] when [member action_shortcut] pressed, but for
## [MultiActionScript]s this will only show the shortcut in [member menu]. (See also
## [method _shortcut_input])
func _load_shortcut() -> void:
	action_shortcut.events.append(Global.shortcut_map.get_shortcut(name))
	var key: Key = action_shortcut.events[0].get_keycode_with_modifiers()
	menu.set_item_accelerator(index, key)


## Defines this action as a command for command palettes, this command will be connected to
## [method _shortcut_input].
func _define_action() -> void:
	Global.define_command(name.capitalize(), action_shortcut.events[0].as_text_keycode(), self._shortcut_input.bind(action_shortcut.events[0]))


## Routes [signal SignalBus.run_subscript] to [method _run_action] if [param action_name] matches
## with this action script name.
func run(script_id: int, popup: PopupMenu, action_name: String) -> void:
	if name != action_name.to_snake_case():
		return
	_run_action(script_id, popup)


## [b][color=lightblue]Virtual[/color][/b][br]
## Called from [method run] when emitted command is for this action script. [param script_id] is id
## of clicked item in [param popup], so you can handle multiple commands here.[br][br]
## [b]example usage:[/b]
## [codeblock]
## extends MultiActionScript
##
## # Note: Make sure these values match with item IDs in submenu
## enum SubActions {
##     MOVE_LINE_UP = 0,
##     MOVE_LINE_DOWN = 1,
## }
##
## func _run_action(script_id: int, popup: PopupMenu) -> void:
##     match script_id:
##         SubActions.MOVE_LINE_UP:
##             print("This block is excuted when the user clicks 'Move Line Up' in the submenu!")
##         SubActions.MOVE_LINE_DOWN:
##             print("But this block is excuted when the user clicks 'Move Line Down'!")
## [/codeblock]
func _run_action(script_id: int, popup: PopupMenu) -> void:
	pass
