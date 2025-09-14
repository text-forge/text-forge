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

## Panel IDs.
enum Panels {
	## Left panel.
	LEFT,
	## Right panel.
	RIGHT,
	## Bottom panel.
	BOTTOM,
}

@export var tabs: Dictionary[Panels, ItemList]
@export var spliters: Dictionary[Panels, SplitContainer]
@export var containers: Dictionary[Panels, TabContainer]

## Panels data, keeps size, closing state, available panels, and last opened tab for each side.
var data := {
	Panels.LEFT: {"size": 200, "closed": true, "panels": {}, "last_tab": 0},
	Panels.RIGHT: {"size": 200, "closed": true, "panels": {}, "last_tab": 0},
	Panels.BOTTOM: {"size": 200, "closed": true, "panels": {}, "last_tab": 0},
}

func _ready() -> void:
	_load_layout()

	for side in 3:
		# handle panel changing
		tabs[side].item_selected.connect(_handle_panel.bind(side))
		spliters[side].item_rect_changed.connect(_apply_split)
		containers[side].tab_selected.connect(_write_tab.bind(side))

	# handle spliter draging
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

	get_window().close_requested.connect(_save_layout)

	_load_panels()


## Add given [param panel] in [param location] with [param icon], it means new icon in [param location]
## side and new panel in [member panels].
func add_panel(location: Panels, panel: TextForgePanel, icon: Texture2D) -> void:
	var current_tab = tabs[location]
	var current_panel = containers[location]
	var index = current_tab.add_icon_item(icon)
	panel.index = index
	panel.place = location
	if index != current_panel.get_child_count():
		current_tab.remove_item(index)
		Global.send_notification(Global.Notification.ERROR, "There is a bug in panel management", "")
		return
	current_panel.add_child(panel)
	data[location]["panels"][index] = panel


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
	Settings.write_data("panels", "layout_data", data)


## Loads panels layout in [member panels]. Will ignore last loaded panels.
func _load_layout() -> void:
	data = Settings.read_data("panels", "layout_data", data)


## Loads all panels in [constant FileDatabase.FOLDER_PANELS].
func _load_panels() -> void:
	for panel in DirAccess.get_directories_at(FileDatabase.FOLDER_PANELS):
		var config = ConfigFile.new()
		config.load(SLib.globalize_path(FileDatabase.TEMPLATE_PANEL_CONFIG.format([panel])))
		var place = config.get_value("panel", "place")
		var converted: int
		if place == "R":
			converted = Panels.RIGHT
		elif place == "B":
			converted = Panels.BOTTOM
		else: # Also panels with invalid place
			converted = Panels.LEFT
		add_panel(converted, Global.load_resource(FileDatabase.TEMPLATE_PANEL_SCENE.format([panel])).instantiate(),
				Global.load_resource(FileDatabase.TEMPLATE_PANEL_ICON.format([panel])))


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
	spliters[Panels.LEFT].split_offset = max(data[Panels.LEFT].size, containers[Panels.LEFT].get_child(containers[Panels.LEFT].current_tab).custom_minimum_size.x if containers[Panels.LEFT].get_child_count() else 0)
	if data[Panels.LEFT].closed or containers[Panels.LEFT].get_child_count() == 0:
		spliters[Panels.LEFT].split_offset = 0
		containers[Panels.LEFT].current_tab = -1
	else:
		containers[Panels.LEFT].current_tab = data[Panels.LEFT]["last_tab"]

	spliters[Panels.RIGHT].split_offset = max(spliters[Panels.RIGHT].size.x - data[Panels.RIGHT].size, containers[Panels.RIGHT].get_child(containers[Panels.RIGHT].current_tab).custom_minimum_size.x if containers[Panels.RIGHT].get_child_count() else 0)
	if data[Panels.RIGHT].closed or containers[Panels.RIGHT].get_child_count() == 0:
		spliters[Panels.RIGHT].split_offset = spliters[Panels.RIGHT].size.x
		containers[Panels.RIGHT].current_tab = -1
	else:
		containers[Panels.RIGHT].current_tab = data[Panels.RIGHT]["last_tab"]

	spliters[Panels.BOTTOM].split_offset = max(spliters[Panels.BOTTOM].size.y - data[Panels.BOTTOM].size, containers[Panels.BOTTOM].get_child(containers[Panels.BOTTOM].current_tab).custom_minimum_size.y if containers[Panels.BOTTOM].get_child_count() else 0)
	if data[Panels.BOTTOM].closed or containers[Panels.BOTTOM].get_child_count() == 0:
		spliters[Panels.BOTTOM].split_offset = spliters[Panels.BOTTOM].size.y
		containers[Panels.BOTTOM].current_tab = -1
	else:
		containers[Panels.BOTTOM].current_tab = data[Panels.BOTTOM]["last_tab"]


func _write_tab(tab: int, side: Panels):
	if tab != -1: data[side]["last_tab"] = tab
