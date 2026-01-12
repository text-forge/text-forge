class_name Utils
extends Node
## Keeps useful and helper functions for global access. Use with [code]U[/code] singleton.

## Available syntax colors.
enum SyntaxColors {
	BUILTIN,
	COMMENT,
	CUSTOM_1,
	CUSTOM_2,
	CUSTOM_3,
	CUSTOM_4,
	CUSTOM_5,
	DEFAULT,
	DOC_COMMENT,
	FUNCTION,
	FUNCTION_DEF,
	KEYWORD_1,
	KEYWORD_2,
	KEYWORD_3,
	MEMBER,
	NUMBER,
	STRING,
	SYMBOL,
	TYPE_1,
	TYPE_2,
	TYPE_3,
}

## Maps each [enum SyntaxColors] to one string in themes.
const SYNTAX_COLORS_MAP: Dictionary[SyntaxColors, String] = {
	SyntaxColors.BUILTIN: "builtin",
	SyntaxColors.COMMENT: "comment",
	SyntaxColors.CUSTOM_1: "custom1",
	SyntaxColors.CUSTOM_2: "custom2",
	SyntaxColors.CUSTOM_3: "custom3",
	SyntaxColors.CUSTOM_4: "custom4",
	SyntaxColors.CUSTOM_5: "custom5",
	SyntaxColors.DEFAULT: "default",
	SyntaxColors.DOC_COMMENT: "doc_comment",
	SyntaxColors.FUNCTION: "function",
	SyntaxColors.FUNCTION_DEF: "function_def",
	SyntaxColors.KEYWORD_1: "keyword1",
	SyntaxColors.KEYWORD_2: "keyword2",
	SyntaxColors.KEYWORD_3: "keyword3",
	SyntaxColors.MEMBER: "member",
	SyntaxColors.NUMBER: "number",
	SyntaxColors.STRING: "string",
	SyntaxColors.SYMBOL: "symbol",
	SyntaxColors.TYPE_1: "type1",
	SyntaxColors.TYPE_2: "type2",
	SyntaxColors.TYPE_3: "type3",
}

func _ready() -> void:
	Notif.register_notification(
		"deprecated_function",
		Notif.Type.WARN,
		"A deprecated function used!",
		"Please report this to avoid future bugs:\n{0}\nis used by\n{1}"
	)


## Sends a deprecated notification to user.
func deprecated() -> void:
	var caller: Array[Dictionary] = get_stack()
	caller.pop_front()
	var deprecated_func := _format_stack(caller.pop_front())
	var caller_formated := caller.map(_format_stack)
	Notif.notif(
		"deprecated_function",
		{"format_text": [deprecated_func, "\n".join(caller_formated)]}
	)
	var helper_message := ["Deprecated function in core detected!", "Please use Help > Submit Issue to report it."]
	if caller_formated[0].begins_with("user://"):
		var regex := RegEx.new()
		regex.compile(r"(?:user:\/\/)(?<type>[^/]*)\/(?<folder>[^/]*)\/?.*")
		var result := regex.search(caller_formated[0])
		match result.get_string("type"):
			"modes":
				helper_message = [
					"Deprecated function in {0} mode detected!".format([result.get_string("folder")]),
					"Please report this to mode provider."
				]
			"extensions":
				helper_message = [
					"Deprecated function in {0} extension detected!".format([result.get_string("folder")]),
					"Please report this to extension provider."
				]
			_:
				helper_message = ["Deprecated function in unknown external module detected!", ""]
	Notif.notif(
		"dynamic_notification",
		{"title": helper_message[0], "text": helper_message[1]}
	)


## Creates a [SceneTreeTimer] with given p[aram time] and wait until it's [signal SceneTreeTimer.timeout]
## signal. Usage:
## [codeblock]
## print("first print...")
## await U.wait(3)
## print("second pront, 3 seconds after first one!")
## [/codeblock]
## [b]Note:[/b] You can use [code]0[/code] for [param time] (default value) to add a single frame delay:
## [codeblock]
## func _on_button_pressed() -> void:
##     print("Button pressed!")
##     await U.wait() # or await U.wait(0)
##     print("One frame passed!")
## [/codeblock]
func wait(time: float = 0) -> Signal:
	if time != 0:
		return get_tree().create_timer(time).timeout
	else:
		return get_tree().process_frame


## Loads a resource with globalizing [param path].
func load_resource(path: String) -> Resource:
	if path.is_empty() or not FileAccess.file_exists(S.globalize_path(path)):
		return null
	return ResourceLoader.load(S.globalize_path(path))


## Creates a new [GlobalAccess.ThreadedLoader] node and pass arguments to it. Calls [method GlobalAccess.ThreadedLoader.initialize]
## and [method GlobalAccess.ThreadedLoader.start] after add loader to tree.
func load_resources_threaded(paths: PackedStringArray, for_each: Callable, after_all := Callable()) -> void:
	var loader := ThreadedLoader.new(get_tree(), paths, for_each, after_all)
	loader.start()


## Returns [Color] of given key in current theme.
func get_syntax_color(token_name: SyntaxColors) -> Color:
	return get_window().get_theme_color(SYNTAX_COLORS_MAP[token_name], "SyntaxColors")


func _format_stack(stack: Dictionary) -> String:
	stack["line"] = str(stack["line"])
	var _stack: Dictionary[String, String] = Dictionary(stack, TYPE_STRING, "", null, TYPE_STRING, "", null)
	return stack["source"].replace("res://", "") \
	.replace(S.globalize_path("user://"), "user://") + ":" + str(stack["line"]) + ":" + stack["function"] + "()"


## Threaded resource loader for multiple resources.
##
## This class will request threaded loading for all given resources and handle loaded resources in
## loading order, so resource that was loaded faster will handle before others.[br][br]
class ThreadedLoader extends Object:
	var _tree: SceneTree
	var _pending: Dictionary[String, bool]= {}
	var _for_each: Callable
	var _after_all: Callable

	## Initializes threaded loader for given [param paths], you can do this multiple times to add
	## all files you need, but each time will overwrite [param for_each] and [param after_all] values.[br]
	## [param for_each]: a [Callable] wich will be called for each loader with [code]resource_path, loaded_resource[/code]
	## parameters as [String] and [Resource]. Use this to use loaded resource.[br]
	## [param after_all]: a [Callable] that will be called when all resources loaded. You can use this to
	## load resources when order metters, because this function cachs resources.
	func _init(tree: SceneTree, paths: PackedStringArray, for_each := Callable(), after_all := Callable()) -> void:
		_tree = tree
		for p in paths:
			_pending[p] = false
		if for_each.is_valid():
			_for_each = for_each
		if after_all.is_valid():
			_after_all = after_all

	## Starts threaded loader.
	func start() -> void:
		if _pending.is_empty():
			if _after_all:
				_after_all.call()
			return
		for p in _pending:
			var err := ResourceLoader.load_threaded_request(p, "", true)
			if err:
				push_error("Threaded load request failed for {0} (error: {1})".format([p, str(err)]))
		_monitor_loading()

	func _monitor_loading() -> void:
		while _pending.values().any(func(s): return not s):
			for path in _pending:
				if _pending[path]:
					continue
				var status := ResourceLoader.load_threaded_get_status(path)
				match status:
					ResourceLoader.THREAD_LOAD_LOADED:
						var res := ResourceLoader.load_threaded_get(path)
						_pending[path] = true
						if _for_each:
							_for_each.call(path, res)
					ResourceLoader.THREAD_LOAD_IN_PROGRESS:
						pass
					_:
						push_error("Threaded load failed for {0} (status: {1})".format([path, str(status)]))
						_pending[path] = true
						if _for_each:
							_for_each.call(path, null)
			await _tree.process_frame
		if _after_all:
			_after_all.call()
		free()
