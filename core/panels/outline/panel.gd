class_name TFP_Outline
extends TextForgePanel
## A standard panel that receive file outline and show it.
##
## This panel is connected to SignalBus.outline_updated and refresh problem list with this signal.

## Outline [Tree] node to show file outline.
@export var outline_tree: Tree
## Message label.
@export var message: Label

func _init() -> void:
	place = PanelManager.Panels.LEFT


func _ready() -> void:
	Signals.outline_updated.connect(_update_outline)
	_update_outline([])


func _update_outline(outline: Array) -> void:
	outline_tree.clear()

	var root = outline_tree.create_item()

	for i in outline.size():
		_add_new_branch(outline_tree, root, outline[i])

	message.visible = root.get_child_count() == 0


# Adds new branch for given tree in parent children and continue recursive method.
func _add_new_branch(tree: Tree, parent: TreeItem, strcuture: Array) -> void:
	var item = tree.create_item(parent)
	item.set_text(0, strcuture[0])
	item.set_tooltip_text(0, "Line {0}".format([strcuture[1] + 1]))

	for i in range(2, strcuture.size()):
		_add_new_branch(tree, item, strcuture[i])


# Moves caret to given section.
func _on_tree_item_selected() -> void:
	# int(String) constructor removes any non-number character.
	var line := int(outline_tree.get_selected().get_tooltip_text(0))
	line = min(max(int(line) - 1, 0), Global.get_editor().get_line_count() - 1)
	Global.get_editor().select(line, Global.get_editor().get_line(line).length(), line, Global.get_editor().get_line(line).length())
	Global.get_editor().center_viewport_to_caret()
	Global.get_editor().grab_focus()
