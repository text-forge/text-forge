class_name DocumentManager
extends Node
## Keeps every open document and the active one.
##
## You can access to this class using [code]Documents[/code] autoload. See [EditorDocument] for
## what a document is.

## All open documents, in tab order. Empty only before [method ensure_bootstrap].
var docs: Array[EditorDocument] = []
## Document user is looking at, [code]null[/code] before [method ensure_bootstrap].
var active: EditorDocument
## [TabContainer] that holds documents as its pages, [code]null[/code] before [method attach_tabs].
var tabs: TabContainer
## Registered [code]{signal: StringName, callback: Callable}[/code] pairs, see [method watch].
var _watchers: Array[Dictionary] = []


## Makes [param container] the home of document editors and binds its tab bar.
func attach_tabs(container: TabContainer) -> void:
	if tabs == container:
		return
	tabs = container
	var bar := tabs.get_tab_bar()
	bar.drag_to_rearrange_enabled = true
	bar.tab_close_display_policy = TabBar.CLOSE_BUTTON_SHOW_ACTIVE_ONLY
	tabs.tab_changed.connect(_on_tab_changed)
	bar.tab_close_pressed.connect(_on_tab_close_pressed)
	bar.active_tab_rearranged.connect(_on_tab_rearranged)
	refresh_tabs()


## Rewrites every tab title and the active tab, call after a name or dirty change.
func refresh_tabs() -> void:
	if not tabs:
		return
	for index in docs.size():
		if index >= tabs.get_tab_count():
			break
		tabs.set_tab_title(index, _title(docs[index]))
	var index := docs.find(active)
	if index != -1 and tabs.current_tab != index:
		tabs.current_tab = index


func _title(doc: EditorDocument) -> String:
	if doc.dirty:
		return doc.display_name + "*"
	return doc.display_name


func _on_tab_changed(index: int) -> void:
	if index >= 0 and index < docs.size() and docs[index] != active:
		active = docs[index]


func _on_tab_close_pressed(index: int) -> void:
	if index >= 0 and index < docs.size() and docs[index] == active:
		Signals.close_file.emit()


## Only the active tab can be dragged, so it is the only document that changes place.
func _on_tab_rearranged(index: int) -> void:
	if not active or index < 0 or index >= docs.size():
		return
	docs.erase(active)
	docs.insert(index, active)


## Connects [param callback] to [param signal_name] of every current and future document editor,
## so consumers do not need to rewire on document switch. Skips already connected callbacks.
func watch(signal_name: StringName, callback: Callable) -> void:
	_watchers.append({"signal": signal_name, "callback": callback})
	for doc in docs:
		if doc.editor:
			_connect_watch(doc.editor, signal_name, callback)


func _connect_watch(editor: Editor, signal_name: StringName, callback: Callable) -> void:
	if editor.has_signal(signal_name) and not editor.is_connected(signal_name, callback):
		editor.connect(signal_name, callback)


## Adopts [param original] as the first document. Idempotent for the same editor, so both
## [method GlobalAccess._ready] and [method Core._ready] can call it. When the first call could
## only get a detached editor (main scene was not in tree yet), the second call replaces it.
func ensure_bootstrap(original: Editor) -> void:
	if not original:
		return
	if docs.is_empty():
		docs.append(EditorDocument.new())
	elif docs[0].editor and docs[0].editor.is_inside_tree():
		return
	docs[0].editor = original
	active = docs[0]
	_wire(original)
	refresh_tabs()


## Connects cross-node editor signals. Self connections live in [method Editor._ready].
func _wire(editor: Editor) -> void:
	var core := _find_core(editor)
	if not core:
		return
	if not editor.text_changed.is_connected(core._on_editor_text_changed):
		editor.text_changed.connect(core._on_editor_text_changed)
	if not editor.gutter_clicked.is_connected(_on_gutter_clicked_dirty):
		editor.gutter_clicked.connect(_on_gutter_clicked_dirty)
	var api := Global.get_editor_api()
	if api and not editor.code_completion_requested.is_connected(api._on_editor_code_completion_requested):
		editor.code_completion_requested.connect(api._on_editor_code_completion_requested)
	for watcher in _watchers:
		_connect_watch(editor, watcher["signal"], watcher["callback"])


func _find_core(node: Node) -> Core:
	while node:
		if node is Core:
			return node as Core
		node = node.get_parent()
	return null


## Gutter clicks also count as a change, because bookmarks are saved with the file.
func _on_gutter_clicked_dirty(_line: int, _gutter: int) -> void:
	Global.get_core()._on_editor_text_changed()
