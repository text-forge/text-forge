class_name CheckableActionScript
extends ActionScript
## Base class for [ActionsScript]s with checkable items that will apear in setting.
##
## This is useful template for action scripts with features that:[br]
## - Special section and key in settings with default value for it[br]
## - Have [code]enabled[/code]/[code]disabled[/code] state[br]
## [b]Note:[/b] Just override [method _setup], [method _get_value] and [method _set_value]![br][br]
## [b]Note:[/b] Functions with [b][color=lightblue]Virtual[/color][/b] badges is intended to be
## overriden.[br][br]
## [b]Example Usage:[/b]
## [codeblock]
## extends CheckableActionScript
##
## # NOTE: DON'T override _run_action, if you do this, this action script will be same as regular
## # action scripts!
##
## # To write your action script just override functions you can see in this example, CheckableActionScript class will use them.
##
## # This example is a customization for have placeholder with your name for two users Bob and John,
## # this action script will handle it.
##
## func _setup() -> void:
##     settings_section = "examples"
##     settings_key = "is_bob"
##     default = false
##
## func _get_value() -> bool:
##     return Global.get_editor().placeholder_text == "Bob is writing..."
##
## func _set_value(to: bool) -> void:
##     if to: # when is_bob
##         Global.get_editor().placeholder_text = "Bob is writing..."
##     else: # otherwise
##         Global.get_editor().placeholder_text = "John is writing..."
## [/codeblock]

## Specifies section of this option is settings (and presets).
var settings_section: String
## Specifies key of this option is settings (and presets).
var settings_key: String
## Specifies default value of this option is settings (with define preset).
var default: bool = false

## [b][color=lightblue]Virtual[/color][/b][br]
## Override this function to setup your [CheckableActionScript] variables, Will
## be called from [method _initialize].
func _setup() -> void:
	pass


## [b][color=lightblue]Virtual[/color][/b][br]
## Override this function to handle what should done in changes, see example in
## description for more information.
func _set_value(to: bool) -> void:
	pass


## [b][color=lightblue]Virtual[/color][/b][br]
## Override this function to return current state as [bool] based on editor
## values, etc. See example in description for more information.
func _get_value() -> bool:
	return false


## Initializes this [ActionScript], steps:[br]
## - call [method _setup][br]
## - define preset (based on variables)[br]
## - connect [signal SignalBus.settings.changed] to [method _load_config][br]
## - call [method _load_config]
func _initialize() -> void:
	_setup()
	Settings.define_preset(settings_section, settings_key, default)
	Signals.settings_changed.connect(_load_config)
	_load_config()


## Changes current value and call [method _set_value] with changed value.
func _run_action() -> void:
	Settings.set_setting(settings_section, settings_key, not _get_value())


## Loads saved value from settings and calls [method _set_value] for it and set
## linked menu item checked state.
func _load_config() -> void:
	_set_value(Settings.get_setting(settings_section, settings_key))
	menu.set_item_checked(menu.get_item_index(id), _get_value())
