class_name WindowActionScript
extends ActionScript
## An [ActionScript] that only has a window to show.
##
## [b]Note:[/b] This action script only loads given [member window_scene] and adds it to the scene
## tree, other tasks should be done in window by itself.[br]
## [b]Note:[/b] DON'T override [method ActionScript._run_action].

## Path to window [PackedScene] save file. Set it in [method ActionScript._initialize].
var window_scene: String

func _run_action() -> void:
	add_child(Global.load_resource(window_scene).instantiate())
