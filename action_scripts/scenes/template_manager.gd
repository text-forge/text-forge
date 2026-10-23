class_name TemplateManagerWindow
extends Window
## A window to edit or remove templates.

## List of templates.
@export var templates: ItemList
## Panel to show preview.
@export var preview_panel: VBoxContainer
## Template name in preview.
@export var template_name: Label
## Template content in preview.
@export var preview: TextEdit

func _ready() -> void:
	templates.clear()
	if not DirAccess.dir_exists_absolute(S.globalize_path(S.FOLDER_TEMPLATES)):
		DirAccess.make_dir_recursive_absolute(S.globalize_path(S.FOLDER_TEMPLATES))
	for t in DirAccess.get_files_at(S.FOLDER_TEMPLATES):
		templates.add_item(t.get_basename())
	if templates.item_count == 0:
		templates.add_item("There is no template to show!", null, false)
		templates.add_item("Use Format > Save As Template to create one.", null, false)


func _on_edit_pressed() -> void:
	hide()
	Signals.open_file.emit(S.TEMPLATE_TEMPLATES.format([template_name.text]))
	await U.wait()
	queue_free()


func _on_remove_pressed() -> void:
	add_child(Factory.confirmation_dialog(
		"Are you sure you want to delete this template?",
		"Yes, Delete",
		"Cancel",
		"Delete Template",
		Callable(),
		_delete_template,
		true
	))


func _delete_template() -> void:
	OS.move_to_trash(S.globalize_path(S.TEMPLATE_TEMPLATES.format([template_name.text])))
	preview_panel.hide()
	_ready()


func _on_templates_item_selected(index: int) -> void:
	preview_panel.show()
	template_name.text = templates.get_item_text(index)
	preview.text = FileAccess.get_file_as_string(S.TEMPLATE_TEMPLATES.format([template_name.text]))
