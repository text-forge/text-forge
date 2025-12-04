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
	var config := ConfigFile.new()
	config.load(S.globalize_path(Settings.PRESETS_FILE))
	tree.create_item()
	for section in config.get_sections():
		var scroll := ScrollContainer.new()
		var tab := VBoxContainer.new()
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for item in config.get_section_keys(section):
			var option = U.load_resource("res://action_scripts/scenes/setting_option.tscn").instantiate()
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


func _on_tree_item_selected() -> void:
	container.current_tab = tree.get_selected().get_index()
