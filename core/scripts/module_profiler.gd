extends MenuButton

@export var modulate_timer: Timer
@onready var modules_list: Dictionary[String, Node] = {
	"Extensions": Extensions,
	"Action Scripts": Global.get_core().scripts,
	"Modes": Global.get_editor_api(),
}
var _old_count: int = 0
var count = 0

func _ready() -> void:
	get_popup().index_pressed.connect(_on_index_pressed)
	Signals.module_profiler_refresh.connect(_refresh)

	_refresh()


func _refresh() -> void:
	if not is_inside_tree():
		return
	if get_popup().visible:
		await get_popup().visibility_changed
	_old_count = count
	count = 0
	_update_menu()
	_update_count()


func _update_menu() -> void:
	get_popup().clear(true)
	get_popup().add_item("Reload")
	get_popup().add_separator()
	for section in modules_list:
		get_popup().add_submenu_node_item(section, _node_to_popup_menu_tree(modules_list[section]))


func _node_to_popup_menu_tree(node: Node) -> PopupMenu:
	var popup := PopupMenu.new()
	for child in node.get_children():
		if child.get_child_count():
			popup.add_submenu_node_item(child.name + str(" ({0})").format([child.get_child_count()]), _node_to_popup_menu_tree(child))
		else:
			popup.add_item(child.name)
		count += 1
	return popup


func _update_count() -> void:
	text = str(count) + " Module" + ("s" if count > 1 else "")
	if _old_count > count:
		modulate = Color.SPRING_GREEN
	if _old_count < count:
		modulate = Color.ORANGE
	if count != _old_count:
		modulate_timer.start()


func _on_index_pressed(index: int) -> void:
	if index != 0:
		return

	_refresh()


func _on_timer_2_timeout() -> void:
	create_tween().tween_property(self, ^"modulate", Color.WHITE, 1)
