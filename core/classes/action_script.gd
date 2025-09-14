class_name ActionScript
extends Node
## Base class for action scripts.
##
## A regular [ActionScript]. This is class of main part of scripts in
## [code]res://action_scripts[/code].[br][br]
## Features:[br]
## - Access to linked menu option.[br]
## - Automated shortcut loading.[br]
## - Automated enable/disable linked menu option.[br]
## - Translate [InputEventKey] to [enum Key] with masks.[br]
## - Do action based on shortcut.[br][br]
## [b]Important:[/b] Toggle linked item for checkboxes and radio checkboxes will handle in [Core],
## don't do it here![br]
## [b]Important:[/b] [ActionScript]s will not be a child of [PopupMenu]s in main menu, all action
## acripts will be child of [code]Global.get_scripts_node()[/code], see
## [method GlobalAccess.get_scripts_node] for more information.[br]
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
## [InputEventKey] for this action script. See also [method _load_shortcut].
var action_shortcut := InputEventKey.new()
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


## Returns [code]true[/code] if this action script is enable.
func is_enable() -> bool:
	return enable


## Loads shortcut as item accelerator (see also [method PopupMenu.set_item_accelerator]). This means
## it will call [method _run_action] when [member action_shortcut] pressed. (See
## [method MultiActionScript._load_shortcut] for other behavior.)
func _load_shortcut() -> void:
	action_shortcut = Global.shortcut_map.get_shortcut(name)
	menu.set_item_accelerator(index, action_shortcut.get_keycode_with_modifiers())


## Defines this action as a command for command palettes, this command will be connected to
## [method _run_action].
func _define_action() -> void:
	Global.define_command(name.capitalize(), action_shortcut.as_text_keycode(), self._run_action)


## Routes [signal SignalBus.run_script] to [method _run_action] if [param script_id] matches
## with this action script [member id].
func run(script_id: int) -> void:
	if id != script_id: return
	_run_action()


## [b][color=lightblue]Virtual[/color][/b][br]
## Called from [method run] when emitted command is for this action script. This is main part of
## action script.[br][br]
## [b]example usage:[/b]
## [codeblock]
## extends ActionScript
##
## func _run_action() -> void:
##     print("User clicked on my option!")
## [/codeblock]
func _run_action() -> void:
	pass
