class_name SettingOption
extends HBoxContainer
## A ready-made scene to use as one setting option (in [PreferencesWindow]).

## List of option types.
@export var options: TabContainer
## Option label.
@export var label: Label

## Option section.
var section: String
## Option key.
var key: String
## Current value.
var value

func _ready() -> void:
	if section.is_empty() or key.is_empty():
		return
	label.text = key.capitalize()
	value = Settings.get_setting(section, key)
	match typeof(value):
		TYPE_BOOL:
			options.current_tab = 0
			options.get_child(0).button_pressed = value
			if not value: options.get_child(0).text = "Off"
		TYPE_INT, TYPE_FLOAT:
			options.current_tab = 1
			options.get_child(1).value = value
		TYPE_STRING:
			options.current_tab = 2
			options.get_child(2).text = value
		TYPE_ARRAY:
			options.current_tab = 3
			options.get_child(3).text = ", ".join(value.map(func(item): return str(item)))
		_:
			Global.send_notification(
				Global.Notification.ERROR,
				"Invalid Setting Type!",
				"There isn't support for type {0} (in {1} > {2})".format([str(typeof(value)), section, key])
			)
			queue_free()

func _on_check_box_pressed() -> void:
	value = options.get_child(0).button_pressed
	if value:
		options.get_child(0).text = "On"
	else:
		options.get_child(0).text = "Off"
	Settings.set_setting(section, key, value)


func _on_spin_box_value_changed() -> void:
	value = options.get_child(1).value
	Settings.set_setting(section, key, value)


func _on_line_edit_text_submitted(new_text: String) -> void:
	value = new_text
	Settings.set_setting(section, key, value)


func _on_line_edit_2_text_submitted(new_text: String) -> void:
	value = Array(new_text.split(",")).map(func(item: String): return item.strip_edges())
	Settings.set_setting(section, key, value)
