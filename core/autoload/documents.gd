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
## Keeps [method save_session] from storing the same quit twice, closing documents empties the list.
var _session_stored := false

## Title of the document that represents "nothing is opened", it matches the initial file label of
## [Core] and the state [method close] leaves behind.
const NO_FILE_TITLE := "There is no opened file"


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
	var title := doc.display_name + ("*" if doc.dirty else "")
	var same := 0
	var index := 0
	for other in docs:
		if other.display_name != doc.display_name:
			continue
		same += 1
		if other == doc:
			index = same
	if same < 2:
		return title
	# Tabs sharing a name are told apart by their folder, or by a counter when they have none.
	if doc.path.is_absolute_path():
		return doc.path.get_base_dir().get_file() + "/" + title
	return title + " (%d)" % index


## Cycles tabs with [b]Ctrl+Tab[/b] and [b]Ctrl+Shift+Tab[/b]. CodeEdit uses plain [b]Tab[/b] for
## indentation, so only the modified variants move between documents.
func _shortcut_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if not event.ctrl_pressed or event.keycode != KEY_TAB or not tabs:
		return
	var count := tabs.get_tab_count()
	if count < 2:
		return
	tabs.current_tab = (tabs.current_tab + (-1 if event.shift_pressed else 1) + count) % count
	get_viewport().set_input_as_handled()


## Switching tabs, by mouse or [b]Ctrl+Tab[/b], also moves the focus to the editor, so typing goes
## to the document that was just selected.
func _on_tab_changed(index: int) -> void:
	if index < 0 or index >= docs.size():
		return
	activate(docs[index])
	var editor := docs[index].editor
	if editor:
		editor.grab_focus()


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


## Creates a document with its own [Editor] and appends it as a new tab.
func create(path := "Unsaved", display_name := "New file", text := "", editable := false) -> EditorDocument:
	if not tabs:
		return null
	var editor_scene := U.load_resource(S.EDITOR_SCENE) as PackedScene
	if not editor_scene:
		return null
	var doc := EditorDocument.new()
	doc.editor = editor_scene.instantiate() as Editor
	doc.path = path
	doc.display_name = display_name
	doc.dirty = false
	# Content and editable are set before wiring, so filling the editor does not mark the new
	# document as unsaved through the text_changed chain.
	doc.editor.text = text
	doc.editor.editable = editable
	tabs.add_child(doc.editor)
	docs.append(doc)
	_wire(doc.editor)
	refresh_tabs()
	_drop_placeholders(doc)
	return doc


## Closes leftover "There is no opened file" documents once [param keep] holds a real file, so the
## placeholder never lingers beside real tabs.
func _drop_placeholders(keep: EditorDocument) -> void:
	for doc in docs.duplicate():
		if doc != keep and doc.path == "" and not doc.dirty:
			close(doc)


## Returns a document that is still the empty placeholder ([member EditorDocument.path] is
## [code]""[/code], no unsaved change and no text), preferring the active one.
func _placeholder() -> EditorDocument:
	var found: EditorDocument = null
	for doc in docs:
		if doc.path != "" or doc.dirty or not doc.editor or not doc.editor.text.is_empty():
			continue
		if doc == active:
			return doc
		if not found:
			found = doc
	return found


## Gives a document to load a file into, taking over the empty placeholder so opening a file never
## leaves "There is no opened file" behind, and creating a tab only when there is none free.
func reuse_or_create() -> EditorDocument:
	var doc := _placeholder()
	if not doc:
		doc = create()
		if not doc:
			return null
	activate(doc)
	_drop_placeholders(doc)
	return doc


## Makes [param doc] the active document and re-applies shared editor state to it.
func activate(doc: EditorDocument) -> void:
	if not doc or not docs.has(doc):
		return
	if doc == active:
		# A filled placeholder keeps its tab, but its name, text and caret changed.
		_sync_forward()
		return
	_sync_back()
	active = doc
	_sync_forward()
	Signals.active_document_changed.emit(doc)


## Stores caret, scroll, and mode of the outgoing document so switching tabs keeps its state.
func _sync_back() -> void:
	if not active or not active.editor:
		return
	active.caret = Vector2i(active.editor.get_caret_line(), active.editor.get_caret_column())
	active.scroll = Vector2i(active.editor.scroll_horizontal, active.editor.scroll_vertical)
	var api := Global.get_editor_api()
	if api:
		active.mode = api.current_mode


## Applies file label, view settings and mode to the incoming document.
func _sync_forward() -> void:
	if not active or not active.editor:
		return
	var editor := active.editor
	Global.set_file_name(active.display_name + ("*" if active.dirty else ""))
	Global.set_file_path(active.path)
	var api := Global.get_editor_api()
	if api:
		api.apply_view_settings()
		api.load_mode_for(active)
	# Loading a mode can move the caret and the view, so the stored state goes on top of it.
	editor.set_caret_line(active.caret.x)
	editor.set_caret_column(active.caret.y)
	editor.scroll_horizontal = active.scroll.x
	editor.scroll_vertical = active.scroll.y
	refresh_tabs()


## Removes [param doc] and its tab. When it was the active document the next one (or a
## [constant NO_FILE_TITLE] document) takes over, so at least one document always stays open, unless
## [param keep_one] is [code]false[/code].
func close(doc: EditorDocument, keep_one := true) -> void:
	if not doc or not docs.has(doc):
		return
	var index := docs.find(doc)
	var was_active := doc == active
	docs.erase(doc)
	# Detach before creating the replacement, so the tab bar never holds a page of a closed document.
	if doc.editor:
		if doc.editor.get_parent():
			doc.editor.get_parent().remove_child(doc.editor)
		doc.editor.queue_free()
	if was_active:
		if docs.is_empty():
			var replacement := create("", NO_FILE_TITLE) if keep_one else null
			# Nothing is left, so nothing may stay active, a freed editor must not be handed out.
			active = replacement
		else:
			active = docs[index] if index < docs.size() else docs[docs.size() - 1]
	_sync_forward()
	refresh_tabs()


## Returns the open document of [param path], or [code]null[/code] when that file is not open.
func find_by_path(path: String) -> EditorDocument:
	for doc in docs:
		if doc.path == path:
			return doc
	return null


## Closes every document one by one, asking about the unsaved ones, so the tabs that are left show
## what is still open. Closing from the last tab keeps the remaining ones in place and handles the
## active document first. Returns [code]false[/code] while a save prompt is open: the action script
## runs again once the user answered and picks up the documents that are still open.
func close_all(from_id: int) -> bool:
	var queue := docs.duplicate()
	queue.reverse()
	for doc in queue:
		if doc.dirty:
			activate(doc)
			if Global.emit_save_request(from_id):
				return false
		close(doc, false)
	return true


## Stores the open files, the active one and their caret and scroll in [constant S.SESSION_DATA], so
## the next start brings the same tabs back. Only files on disk are stored and it runs once per quit,
## because the documents that are already closed must not shorten the list.
func save_session() -> void:
	if _session_stored:
		return
	_session_stored = true
	_sync_back()
	var entries: Array[Dictionary] = []
	for doc in docs:
		if not doc.path.is_absolute_path():
			continue
		entries.append({"path": doc.path, "caret": doc.caret, "scroll": doc.scroll})
	var config := ConfigFile.new()
	config.set_value("session", "documents", entries)
	config.set_value("session", "active", maxi(docs.find(active), 0))
	var err := config.save(S.SESSION_DATA)
	if err:
		push_error("Cannot store session in %s, error %d" % [S.SESSION_DATA, err])


## Opens the documents stored by [method save_session] and returns [code]true[/code] when there was
## something to open. A stored file that is gone comes back as an empty document instead of being
## dropped, so a session never loses a tab without telling.
func restore_session() -> bool:
	var config := ConfigFile.new()
	if config.load(S.SESSION_DATA) != OK:
		return false
	var entries: Array = config.get_value("session", "documents", [])
	var active_index: int = config.get_value("session", "active", 0)
	var opened: Array[EditorDocument] = []
	for entry: Dictionary in entries:
		var path: String = entry.get("path", "")
		if not path.is_absolute_path():
			continue
		var doc := create(path, path.get_file(), "", false)
		if not doc:
			continue
		# Caret and scroll go in before the activation that applies them, [method
		# GlobalAccess.set_editor_text] keeps both while it fills the editor, so a session needs one
		# activation per document instead of two, and no mode reload twice.
		var caret: Vector2i = entry.get("caret", Vector2i.ZERO)
		var scroll: Vector2i = entry.get("scroll", Vector2i.ZERO)
		doc.caret = caret
		doc.scroll = scroll
		activate(doc)
		if FileAccess.file_exists(path):
			Global.get_editor_api().load_file(path)
		else:
			Global.set_editor_disabled(false)
		# Loading a file also loads its mode, which can move the caret, so the stored position goes
		# on top of it here, where it costs two assignments instead of another activation.
		doc.editor.set_caret_line(caret.x)
		doc.editor.set_caret_column(caret.y)
		# Loading moves the view, so put the stored scroll back on top of it, see [method
		# _restore_view].
		_restore_view.call_deferred(doc, scroll)
		doc.dirty = false
		opened.append(doc)
	if opened.is_empty():
		return false
	activate(opened[clampi(active_index, 0, opened.size() - 1)])
	var editor := Global.get_editor()
	if editor:
		editor.grab_focus()
	return true


## Puts [param scroll] back on [param doc] one frame after its file was loaded. Setting it in the
## same frame clamps against the scroll range of the empty editor and is dropped.
func _restore_view(doc: EditorDocument, scroll: Vector2i) -> void:
	await get_tree().process_frame
	if not is_instance_valid(doc.editor):
		return
	doc.editor.scroll_horizontal = scroll.x
	doc.editor.scroll_vertical = scroll.y


## Adopts [param original] as the first document. Idempotent for the same editor, so both
## [method GlobalAccess._ready] and [method Core._ready] can call it. When the first call could
## only get a detached editor (main scene was not in tree yet), the second call replaces it.
func ensure_bootstrap(original: Editor) -> void:
	if not original:
		return
	if docs.is_empty():
		var none_doc := EditorDocument.new()
		none_doc.path = ""
		none_doc.display_name = NO_FILE_TITLE
		docs.append(none_doc)
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
