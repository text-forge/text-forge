class_name CaseActionScript
extends ActionScript
## Base class for [ActionScript]s with convert case feature.
##
## This is useful template for action scripts with features that:[br]
## - Have complex and operation[br]
## - Can work with multicaret edit mode[br]
## - Can work well with [Editor] keep selection feature[br]
## - Don't changes text length (for example case converting)[br][br]
## [b]Note:[/b] You can use this class for action scripts that changes text length, but automated
## selection restore will select area with same length as unchanged text![br][br]
## [b]Example Usage:[/b]
## [codeblock]
## extends CaseActionScript
## # This is a simple camelCase converting
##
## # NOTE: DON'T override _run_action, if you do this, this action script will be same as regular
## # action scripts!
##
## # To write your action script just override this function, CaseActionScript class will call it
## # for each selected text and do the rest itself! Including caret restoring, replacing, and any
## # other task.
## func _format_text(text: String) -> String:
##     return text.to_camel_case()
## [/codeblock]

## Initializes this action script, for this class, it means set [member ActionScript.requires_file] to [code]true[/code].
func _initialize() -> void:
	requires_file = true

## Handles main operation, you just have to override [method _format_text]. [br]
## What this function do:[br]
## - Handle complex operation[br]
## - Handle multicaret edit[br]
## - Handle text replacing[br]
## - Call [method _format_text] and use its return for replace[br]
## - Handle backward and forward selection
func _run_action() -> void:
	Global.get_editor().begin_complex_operation()
	Global.get_editor().begin_multicaret_edit()

	var text = Global.get_editor_text()

	for caret in Global.get_editor().get_caret_count():
		var selected_text = Global.get_editor().get_selected_text(caret)

		var selected_origin = Global.get_editor().get_char_index(Global.get_editor().get_selection_origin_line(caret), Global.get_editor().get_selection_origin_column(caret))
		var selected_caret = Global.get_editor().get_char_index(Global.get_editor().get_caret_line(caret), Global.get_editor().get_caret_column(caret))

		# reverse backward selection to have forward select, this have no effect on what user see
		if selected_origin > selected_caret:
			var temp_origin = selected_caret
			selected_caret = selected_origin
			selected_origin = temp_origin

		var new_text = text.substr(0, selected_origin) + _format_text(selected_text) + text.substr(selected_caret)
		text = new_text

	Global.set_editor_text(text)

	Global.get_editor().end_multicaret_edit()
	Global.get_editor().end_complex_operation()
	Global.get_editor().text_changed.emit()


## Formats given [param text] and returns formatted version to class functions for replace. This
## will call for each selected text and should return formatted version of that selected text in
## each call. Before override (for example in emtpy script that extends [CaseActionScript]) it will
## return [param text].
func _format_text(text: String) -> String:
	return text
