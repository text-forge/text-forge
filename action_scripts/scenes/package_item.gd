class_name PackageItem
extends PanelContainer
## Readr-made scene for package items in [MarketplaceWindow].

## Name label.
@export var n_name: Label
## Version label.
@export var n_version: Label
## Category label.
@export var n_category: Label
## Author label.
@export var n_author: Label
## Tags container.
@export var n_tags: HFlowContainer
## Description label.
@export var n_description: Label
## Created and updated dates label.
@export var n_dates: Label
## Minimum editor version label.
@export var n_min_editor_version: Label
## Install button.
@export var n_button: Button

func setup(
		id: String, package_name: String, version: String, category: String, author: String, tags: Array,
		description: String, updated: String, created: String, min_editor_version: String, action: Callable
	) -> void:
	n_name.text = package_name
	n_version.text = version
	n_category.text = category
	n_author.text = author
	S.free_all_children(n_tags)
	for t in tags:
		var tag := Label.new()
		tag.text = t
		tag.set_theme_type_variation("PackageBadgeLabel")
		n_tags.add_child(tag)
	n_description.text = description
	n_dates.text = updated + " | " + created
	n_min_editor_version.text = "Text Forge {0}+".format([min_editor_version])
	n_button.pressed.connect(action.bind(id))
