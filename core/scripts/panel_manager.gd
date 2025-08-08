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
## Nodes with [code]Tab[/code] suffix are [ItemList]s with a item for each panel for handle panel chanfing.[br]
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

## LeftTab node, see class description for more information.
@export var tab_left: ItemList
## RightTab node, see class description for more information.
@export var tab_right: ItemList
## BottomTab node, see class description for more information.
@export var tab_bottom: ItemList
## LeftSpliter node, see class description for more information.
@export var spliter_left: HSplitContainer
## RightSpliter node, see class description for more information.
@export var spliter_right: HSplitContainer
## BottomSpliter node, see class description for more information.
@export var spliter_bottom: VSplitContainer
## LeftPanel node, see class description for more information.
@export var panel_left: TabContainer
## RightPanel node, see class description for more information.
@export var panel_right: TabContainer
## BottomPanel node, see class description for more information.
@export var panel_bottom: TabContainer
## Panels data, keeps size, closing state, available panels, and last opened tab for each side.
var data := {
	Panels.LEFT: {"size": 200, "closed": true, "panels": {}, "last_tab": 0},
	Panels.RIGHT: {"size": 200, "closed": true, "panels": {}, "last_tab": 0},
	Panels.BOTTOM: {"size": 200, "closed": true, "panels": {}, "last_tab": 0},
}

func _ready() -> void:
	_load_layout()

	# handle window size changing
	spliter_left.item_rect_changed.connect(_apply_split)
	spliter_right.item_rect_changed.connect(_apply_split)
	spliter_bottom.item_rect_changed.connect(_apply_split)

	# handle spliter draging
	spliter_left.dragged.connect(func(offset):
		data[Panels.LEFT].size = offset
		data[Panels.LEFT].closed = offset == 0
		_apply_split()
	)
	spliter_right.dragged.connect(func(offset):
		data[Panels.RIGHT].size = spliter_right.size.x - offset
		data[Panels.RIGHT].closed = offset + 10 >= spliter_right.size.x
		_apply_split()
	)
	spliter_bottom.dragged.connect(func(offset):
		data[Panels.BOTTOM].size = spliter_bottom.size.y - offset
		data[Panels.BOTTOM].closed = offset + 10 >= spliter_bottom.size.y
		_apply_split()
	)

	# handle panel changing
	tab_left.item_selected.connect(_handle_panel.bind(Panels.LEFT))
	tab_right.item_selected.connect(_handle_panel.bind(Panels.RIGHT))
	tab_bottom.item_selected.connect(_handle_panel.bind(Panels.BOTTOM))

	# save last tabs for reopen panels
	panel_left.tab_selected.connect(func(tab): if tab != -1: data[Panels.LEFT]["last_tab"] = tab)
	panel_right.tab_selected.connect(func(tab): if tab != -1: data[Panels.RIGHT]["last_tab"] = tab)
	panel_bottom.tab_selected.connect(func(tab): if tab != -1: data[Panels.BOTTOM]["last_tab"] = tab)

	get_window().close_requested.connect(_save_layout)

	_load_panels()


## Add given [param panel] in [param location] with [param icon], it means new icon in [param location]
## side and new panel in [member panels].
func add_panel(location: Panels, panel: Control, icon: Texture2D) -> void:
	var current_tab
	var current_panel
	match location:
		Panels.LEFT:
			current_tab = tab_left
			current_panel = panel_left
		Panels.RIGHT:
			current_tab = tab_right
			current_panel = panel_right
		Panels.BOTTOM:
			current_tab = tab_bottom
			current_panel = panel_bottom
	var index = current_tab.add_icon_item(icon)
	panel.index = index
	if index != current_panel.get_child_count():
		current_tab.remove_item(index)
		Global.send_notification(Global.Notification.ERROR, "There is a bug in left panel", "")
		return
	current_panel.add_child(panel)
	data[location]["panels"][index] = panel


## Changes icon of given panel with [param icon].
func change_panel_icon(location: int, index: int, icon: Texture2D) -> void:
	var current_tab: ItemList
	match location:
		Panels.LEFT:
			current_tab = tab_left
		Panels.RIGHT:
			current_tab = tab_right
		Panels.BOTTOM:
			current_tab = tab_bottom
	current_tab.set_item_icon(index, icon)


## Shows given panel (using [method _handle_panel] and virtualize click).
func show_panel(location: int, index: int) -> void:
	if data[location]["closed"] or data[location]["last_tab"] != index:
		_handle_panel(index, location)


## Saves current panels latout.
func _save_layout() -> void:
	Settings.write_data("panels", "layout_data", data)


## Loads panels layout in [member panels]. Will ignore last loaded panels.
func _load_layout() -> void:
	Settings.read_data("panels", "layout_data", data)
	for side in data:
		data[side]["panels"] = {}


## Loads all panels in [constant FileDatabase.FOLDER_PANELS].
func _load_panels() -> void:
	for panel in DirAccess.get_directories_at(FileDatabase.FOLDER_PANELS):
		var config = ConfigFile.new()
		config.load(FileDatabase.TEMPLATE_PANEL_CONFIG.format([panel]))
		var place = config.get_value("panel", "place")
		var converted: int
		if place == "R":
			converted = Panels.RIGHT
		elif place == "B":
			converted = Panels.BOTTOM
		else: # Also panels with invalid place
			converted = Panels.LEFT
		add_panel(converted, ResourceLoader.load(FileDatabase.TEMPLATE_PANEL_SCENE.format([panel])).instantiate(),
				ResourceLoader.load(FileDatabase.TEMPLATE_PANEL_ICON.format([panel])))


## Changes current panel based on selected items. Calls [method _apply_split] if changes [member panels].
func _handle_panel(selected: int, panel_id: int) -> void:
	var current_panel
	match panel_id:
		Panels.LEFT:
			current_panel = panel_left
		Panels.RIGHT:
			current_panel = panel_right
		Panels.BOTTOM:
			current_panel = panel_bottom
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
	spliter_left.split_offset = max(data[Panels.LEFT].size, panel_left.get_child(panel_left.current_tab).custom_minimum_size.x if panel_left.get_child_count() else 0)
	if data[Panels.LEFT].closed or panel_left.get_child_count() == 0:
		spliter_left.split_offset = 0
		panel_left.current_tab = -1
	else:
		panel_left.current_tab = data[Panels.LEFT]["last_tab"]

	spliter_right.split_offset = max(spliter_right.size.x - data[Panels.RIGHT].size, panel_right.get_child(panel_right.current_tab).custom_minimum_size.x if panel_right.get_child_count() else 0)
	if data[Panels.RIGHT].closed or panel_right.get_child_count() == 0:
		spliter_right.split_offset = spliter_right.size.x
		panel_right.current_tab = -1
	else:
		panel_right.current_tab = data[Panels.RIGHT]["last_tab"]

	spliter_bottom.split_offset = max(spliter_bottom.size.y - data[Panels.BOTTOM].size, panel_bottom.get_child(panel_bottom.current_tab).custom_minimum_size.y if panel_bottom.get_child_count() else 0)
	if data[Panels.BOTTOM].closed or panel_bottom.get_child_count() == 0:
		spliter_bottom.split_offset = spliter_bottom.size.y
		panel_bottom.current_tab = -1
	else:
		panel_bottom.current_tab = data[Panels.BOTTOM]["last_tab"]
