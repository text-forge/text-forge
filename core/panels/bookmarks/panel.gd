class_name BookmarksPanel
extends TextForgePanel
## A standard panel to see and intract with bookmarks.

## [BookmarkItemPanel] scene.
const ITEM = preload("res://core/panels/bookmarks/item_panel.tscn")

## [VBoxContainer] to keep bookmark items.
@export var items: VBoxContainer

func _init() -> void:
	place = PanelManager.Panels.LEFT


func _ready() -> void:
	if Global.get_editor():
		Global.get_editor().type_timer_timeout.connect(_update_bookmarks)
		Global.get_editor().gutter_clicked.connect(_update_bookmarks.call_deferred.unbind(2))
		if Signals.open_bookmarks_panel.is_connected(Global.get_panel_manager().show_panel):
			Signals.open_bookmarks_panel.disconnect(Global.get_panel_manager().show_panel)
		Signals.open_bookmarks_panel.connect(Global.get_panel_manager().show_panel.bind(place, index))


## Updates bookmarks, uses available items again and hides additional items.
func _update_bookmarks() -> void:
	var bookmarks := Global.get_editor().get_bookmarked_lines()
	for e in items.get_child_count():
		if e < bookmarks.size():
			items.get_child(e).show()
		else:
			items.get_child(e).hide()
	for i in bookmarks.size():
		while i >= items.get_child_count():
			items.add_child(ITEM.instantiate())
		var c: PanelContainer = items.get_child(i)
		c.update(Global.get_editor().get_line(bookmarks[i]), bookmarks[i])
