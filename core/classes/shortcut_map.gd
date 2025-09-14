class_name ShortcutMap
extends Resource

@export var map: Dictionary[String, InputEventKey] = {}

func get_shortcut(name: String) -> InputEventKey:
	return map.get(name, InputEventKey.new())
