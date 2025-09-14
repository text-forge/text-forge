extends TextForgePanel
## Simple [TextForgePanel], useful for creating panels from script (by modes).

## Returns [MarginContainer] child.
func get_container() -> MarginContainer:
	return get_child(0) as MarginContainer


## Loads given [param scene] as child of [method get_container]. root node on given [param scene]
## should be a [Control], this function will set [member Control.size_flags_horizontal] and
## [member Control.size_flags_vertical] of root node to [constant Control.SIZE_EXPAND_FILL].
## This function will set panel [member Control.custom_minimum_size] to [param scene] root node
## [member Control.custom_minimum_size].
func load_scene_as_child(scene: String) -> void:
	SLib.free_all_children(get_container())
	var instance: Control = Global.load_resource(scene).instantiate()
	get_container().add_child(instance)
	instance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	instance.size_flags_vertical = Control.SIZE_EXPAND_FILL
	self.custom_minimum_size = instance.custom_minimum_size
