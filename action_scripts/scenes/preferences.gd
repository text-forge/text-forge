class_name PreferencesWindow
extends Window
## A window to view and modify preferences.
##
## This is a user interface, see [SettingsAPI] for code.

## Container to keep each section.
@export var container: TabContainer
## Tree for section changing.
@export var tree: Tree

func _ready() -> void:
	var config := Settings.presets
	# Loaded once, this loop runs it for every single setting.
	var option_scene := U.load_resource("res://action_scripts/scenes/setting_option.tscn")
	if not option_scene:
		return
	tree.create_item()
	var sections := config.get_sections()
	sections.sort()
	for section in sections:
		var scroll := ScrollContainer.new()
		scroll.follow_focus = true
		var tab := VBoxContainer.new()
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab.theme_type_variation = "SeparatedVBox"
		var keys := config.get_section_keys(section)
		keys.sort()
		for item in keys:
			var option = option_scene.instantiate()
			option.section = section
			option.key = item
			tab.add_child(option)
		scroll.name = section.capitalize().replace("Ui", "UI")
		scroll.add_child(tab)
		container.add_child(scroll)
		var page := tree.create_item()
		page.set_text(0, scroll.name)
		if tab.get_child_count() == 0:
			scroll.queue_free()
			page.free()
	if tree.get_root().get_child_count():
		tree.set_selected(tree.get_root().get_first_child(), 0)
	tree.grab_focus()


func _on_tree_item_selected() -> void:
	container.current_tab = tree.get_selected().get_index()


func _on_tree_item_activated() -> void:
	container.current_tab = tree.get_selected().get_index()
	container.get_child(container.current_tab).get_child(0).get_child(0).pass_focus_to_option()
