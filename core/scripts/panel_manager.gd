class_name PanelManager
extends HBoxContainer
## Panel manager node in scene.
##
## This is panel manager for panel support feature, this is structure of panel related nodes:
## [codeblock lang=text]
## ┠╴PanelManager
## ┃  ┠╴LeftTab
## ┃  ┠╴LeftSpliter
## ┃  ┃  ┠╴LeftPanel
## ┃  ┃  ┖╴RightSpliter
## ┃  ┃     ┠╴BottomSpliter
## ┃  ┃     ┃  ┠╴Editor
## ┃  ┃     ┃  ┃  ┖╴API
## ┃  ┃     ┃  ┖╴BottomPanel
## ┃  ┃     ┖╴RightPanel
## ┃  ┖╴RightTab
## ┖╴BottomTab
## [/codeblock]
## Nodes with [code]Tab[/code] suffix are [ItemList]s with a item for each panel for handle panel changing.[br]
## Nodes with [code]Spliter[/code] suffix are [SplitContainer]s for handle panel sizes and open/close.[br]
## Nodes with [code]Panel[/code] suffix are [TabContainer]s with panels as children for show panels.

## Emits when panel loading completed (for performance monitoring).
signal load_completed

## Panel IDs.
enum Panels {
	LEFT,
	RIGHT,
	BOTTOM,
}

## Tabs to show panel icons.
@export var tabs: Dictionary[Panels, ItemList]
## [SplitContainer]s to resize panels.
@export var spliters: Dictionary[Panels, SplitContainer]
## Containers to show panel contents.
@export var containers: Dictionary[Panels, TabContainer]

## Panels data, keeps size, closing state, available panels, and last opened tab for each side.
var data := {
	Panels.LEFT: {"size": 200, "closed": true, "panels": {}, "last_tab": 0},
	Panels.RIGHT: {"size": 200, "closed": true, "panels": {}, "last_tab": 0},
	Panels.BOTTOM: {"size": 200, "closed": true, "panels": {}, "last_tab": 0},
}
## Panels with name and place to load.
var _panels: Dictionary[String, Dictionary] = {}
var _cache: Dictionary[String, Resource] = {}

func _ready() -> void:
	Notif.register_notification(
		"panel_index_mismatch",
		Notif.Type.ERR,
		"There is a bug in panel management.",
		"Panel index doesn't match with expected value."
	)
	for side in 3:
		# Handle panel changing
		tabs[side].item_selected.connect(_handle_panel.bind(side))
		spliters[side].item_rect_changed.connect(_apply_split)
		containers[side].tab_selected.connect(_write_tab.bind(side))
	# Handle spliter draging
	spliters[Panels.LEFT].dragged.connect(func(offset):
		data[Panels.LEFT].size = offset
		data[Panels.LEFT].closed = offset == 0
		_apply_split()
	)
	spliters[Panels.RIGHT].dragged.connect(func(offset):
		data[Panels.RIGHT].size = spliters[Panels.RIGHT].size.x - offset
		data[Panels.RIGHT].closed = offset + 10 >= spliters[Panels.RIGHT].size.x
		_apply_split()
	)
	spliters[Panels.BOTTOM].dragged.connect(func(offset):
		data[Panels.BOTTOM].size = spliters[Panels.BOTTOM].size.y - offset
		data[Panels.BOTTOM].closed = offset + 10 >= spliters[Panels.BOTTOM].size.y
		_apply_split()
	)
	# Save layout before exit
	get_window().close_requested.connect(_save_layout)
	# Load panels and last layout
	_load_panels()
	_load_layout()


## Adds given [param panel] with [param icon], it means new icon in [member TextForgePanel.place]
## side and new panel in [member panels].
func add_panel(panel: TextForgePanel, icon: Texture2D) -> void:
	var location := panel.place
	var current_tab = tabs[location]
	var current_panel = containers[location]
	var index = current_tab.add_icon_item(icon)
	panel.index = index
	if index != current_panel.get_child_count():
		current_tab.remove_item(index)
		Notif.notif("panel_index_mismatch")
		return
	current_panel.add_child(panel)
	data[location]["panels"][index] = panel


## Removes target panel.
func remove_panel(location: Panels, index: int) -> void:
	var current_tab = tabs[location]
	var current_panel = containers[location]
	current_tab.remove_item(index)
	current_panel.remove_child(current_panel.get_child(index))
	data[location]["panels"].erase(index)


## Changes icon of given panel with [param icon].
func change_panel_icon(location: Panels, index: int, icon: Texture2D) -> void:
	var current_tab: ItemList
	match location:
		Panels.LEFT:
			current_tab = tabs[Panels.LEFT]
		Panels.RIGHT:
			current_tab = tabs[Panels.RIGHT]
		Panels.BOTTOM:
			current_tab = tabs[Panels.BOTTOM]
	current_tab.set_item_icon(index, icon)


## Shows given panel (using [method _handle_panel] and virtualize click).
func show_panel(location: Panels, index: int) -> void:
	if data[location]["closed"] or data[location]["last_tab"] != index:
		_handle_panel(index, location)


## Saves current panels latout.
func _save_layout() -> void:
	var data_to_save := data.duplicate(true)
	for l in data_to_save:
		data_to_save[l]["panels"] = {}
	Settings.write_data("panels", "layout_data", data_to_save)


## Loads panels layout in [member panels]. Will ignore last loaded panels.
func _load_layout() -> void:
	data = Settings.read_data("panels", "layout_data", data)


## Loads all panels in [constant S.FOLDER_PANELS].
func _load_panels() -> void:
	var paths: Array[String] = []
	var panels := Array(ResourceLoader.list_directory(S.FOLDER_PANELS)).filter(func(i: String): return i.ends_with("/"))
	for panel in Array(panels).map(func(i: String): return i.trim_suffix("/")):
		paths.append(S.TEMPLATE_PANEL_SCENE.format([panel]))
		paths.append(S.TEMPLATE_PANEL_SCRIPT.format([panel]))
		paths.append(S.TEMPLATE_PANEL_ICON.format([panel]))
		_panels[S.TEMPLATE_PANEL_SCENE.format([panel])] = {
			"name": panel,
		}
	U.load_resources_threaded(paths, _cache_resource, _complete_loading)


func _cache_resource(path: String, resource: Resource) -> void:
	if resource == null:
		push_warning("Attempted to cache null resource for path: " + path)
		return
	if _cache.has(path):
		push_warning("Overwriting cached resource for path: " + path)
	_cache[path] = resource


## Adds loaded panels.
func _complete_loading() -> void:
	for p in _panels:
		for file: String in [
			S.TEMPLATE_PANEL_SCENE,
			S.TEMPLATE_PANEL_SCRIPT,
			S.TEMPLATE_PANEL_ICON,
		]:
			file = file.format([_panels[p]["name"]])
			if not _cache.has(file):
				push_warning("Failed to cache % with threaded loading, retry with simple load..." % file)
				_cache[file] = U.load_resource(file)

		var scene = _cache.get(p)
		var icon = _cache.get(S.TEMPLATE_PANEL_ICON.format([_panels[p]["name"]]))

		if scene == null:
			push_error("Failed to load panel scene: " + p)
			continue
		if icon == null:
			push_warning("Missing icon for panel: " + p)
			icon = load("res://assets/deactive.png")

		add_panel(
			scene.instantiate(),
			icon
		)
	_apply_split()
	load_completed.emit()


## Changes current panel based on selected items. Calls [method _apply_split] if changes [member panels].
func _handle_panel(selected: int, panel_id: int) -> void:
	var current_panel = containers[panel_id]
	if current_panel.current_tab == selected and data[panel_id].closed == false:
		data[panel_id].closed = true
		_apply_split()
		return
	current_panel.current_tab = selected
	if data[panel_id].closed == true:
		data[panel_id].closed = false
		if data[panel_id].size <= 10: data[panel_id].size = 200
		_apply_split()


## Handle spliters to keep each side in setes minimum size and keep empty sides close.
func _apply_split() -> void:
	# --- Left ---
	spliters[Panels.LEFT].split_offset = max(
		data[Panels.LEFT].size,
		(
			containers[Panels.LEFT].get_child(containers[Panels.LEFT].current_tab).custom_minimum_size.x
			if containers[Panels.LEFT].get_child_count()
			else 0
		)
	)
	if data[Panels.LEFT].closed or containers[Panels.LEFT].get_child_count() == 0:
		spliters[Panels.LEFT].split_offset = 0
		containers[Panels.LEFT].current_tab = -1
	else:
		containers[Panels.LEFT].current_tab = min(
			data[Panels.LEFT]["last_tab"],
			containers[Panels.LEFT].get_tab_count() - 1
		)
	# --- Right ---
	spliters[Panels.RIGHT].split_offset = max(
		spliters[Panels.RIGHT].size.x - data[Panels.RIGHT].size,
		(
			containers[Panels.RIGHT].get_child(containers[Panels.RIGHT].current_tab).custom_minimum_size.x
			if containers[Panels.RIGHT].get_child_count()
			else 0
		)
	)
	if data[Panels.RIGHT].closed or containers[Panels.RIGHT].get_child_count() == 0:
		spliters[Panels.RIGHT].split_offset = spliters[Panels.RIGHT].size.x
		containers[Panels.RIGHT].current_tab = -1
	else:
		containers[Panels.RIGHT].current_tab = min(
			data[Panels.RIGHT]["last_tab"],
			containers[Panels.RIGHT].get_tab_count() - 1
		)
	# --- Bottom ---
	spliters[Panels.BOTTOM].split_offset = max(
		spliters[Panels.BOTTOM].size.y - data[Panels.BOTTOM].size,
		(
			containers[Panels.BOTTOM].get_child(containers[Panels.BOTTOM].current_tab).custom_minimum_size.y
			if containers[Panels.BOTTOM].get_child_count()
			else 0
		)
	)
	if data[Panels.BOTTOM].closed or containers[Panels.BOTTOM].get_child_count() == 0:
		spliters[Panels.BOTTOM].split_offset = spliters[Panels.BOTTOM].size.y
		containers[Panels.BOTTOM].current_tab = -1
	else:
		containers[Panels.BOTTOM].current_tab = min(
			data[Panels.BOTTOM]["last_tab"],
			containers[Panels.BOTTOM].get_tab_count() - 1
		)


## Saves current tab for each panel to [member data].
func _write_tab(tab: int, side: Panels):
	if tab != -1:
		data[side]["last_tab"] = tab
