class_name TFP_Problems
extends TextForgePanel
## A standard panel that receive problems and show them.
##
## This panel is connected to [signal SignalBus.problems_updated] and refresh problem list with this signal.

## Avaiable children for a problem instance.
enum ProblemChildren {
	ICON, ## Problem icon [TextureRect].
	TITLE, ## Problem title [Label].
	DETAILS, ## Problem details [Label].
	BUTTON, ## Problem show [Button].
}

## Pattern problem instance.
@export var instance: PanelContainer
## Problem list container.
@export var problem_list: VBoxContainer
## Message label.
@export var message: Label

func _ready() -> void:
	Signals.problems_updated.connect(_update_problems)
	_update_problems(Array([], TYPE_DICTIONARY, "", null))


func _update_problems(problems: Array[Dictionary]) -> void:
	# Remove old problem list items
	SLib.free_all_children(problem_list)

	for p in problems:
		var item: PanelContainer = instance.duplicate()

		# red for errrors, yellow for warnings
		var icon: Texture2D = Global.load_resource("res://data/panels/problems/error.png" if p["error"] else "res://data/panels/problems/warning.png")
		# color for title, same color as icon
		var color: Color = Color("e50000" if p["error"] else "e8bc03")
		# line and column prefix
		var line_column: String
		# add column to prefix if column provided
		if p["column"] == -1:
			line_column = "Line {0}".format([p["line"] + 1])
		else:
			line_column = "Line {0} (column {1})".format([p["line"] + 1, p["column"]])

		# Setup new problem item
		_get_problem_child(ProblemChildren.ICON, item).texture = icon
		_get_problem_child(ProblemChildren.TITLE, item).text = "{0}: {1}".format([line_column, p["title"]])
		_get_problem_child(ProblemChildren.TITLE, item).add_theme_color_override(&"font_color", color)
		_get_problem_child(ProblemChildren.DETAILS, item).text = p["details"]
		# hide blank details label
		if p["details"] == "":
			_get_problem_child(ProblemChildren.DETAILS, item).hide()
		# add move to action
		_get_problem_child(ProblemChildren.BUTTON, item).pressed.connect(_move_to_problem.bind(p["line"], p["column"]))

		item.show()
		problem_list.add_child(item)

	# show message if there is no problem
	message.visible = problem_list.get_child_count() == 0


# Moves caret to given line and column.
func _move_to_problem(line: int, column: int) -> void:
	Global.get_editor().set_caret_line(line)
	if column <= -1:
		column = Global.get_editor().get_line(line).length()
	Global.get_editor().set_caret_column(column)
	Global.get_editor().merge_overlapping_carets()
	Global.get_editor().grab_focus()


# Returns correct child in given problem node.
func _get_problem_child(children: ProblemChildren, problem: PanelContainer) -> Control:
	match children:
		ProblemChildren.ICON:
			return problem.get_child(0).get_child(0).get_child(0)
		ProblemChildren.TITLE:
			return problem.get_child(0).get_child(0).get_child(1)
		ProblemChildren.DETAILS:
			return problem.get_child(0).get_child(1)
		ProblemChildren.BUTTON:
			return problem.get_child(1)
	return problem
