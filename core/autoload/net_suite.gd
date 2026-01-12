extends Node
## Helper for network tasks.

func _ready() -> void:
	child_entered_tree.connect(Signals.refresh_module_profiler.unbind(1))
	child_exiting_tree.connect(Signals.refresh_module_profiler.unbind(1))
	Notif.register_notification(
		"http_request_failed",
		Notif.Type.ERR,
		"Failed to send HTTP request!",
		"Error: "
	)


## Creates a new [HTTPRequest] and initializes it with these optional parameters:[br]
## َ    - [param callback]: [Callable] to connect to [signal HTTPRequest.request_completed].[br]
## َ    - [param request]: Optional request with keys:[br]
## َ        - [code]"url"[/code]: URL to request.[br]
## َ        - [code]"raw"[/code] (Optional, default [code]false[/code]): Uses [method HTTPRequest.request_raw]
##           instead of [method HTTPRequest.request] when [code]true[/code].[br]
## َ        - [code]"custom_headers"[/code] (Optional, default is empty [PackedStringArray]): Custom
##           headers to send request.[br]
## َ        - [code]"method"[/code] (Optional, default [constant HTTPClient.METHOD_GET]): Request method.[br]
## َ        - [code]"request_data_raw"[/code] (Optional, default empty [PackedByteArray]): Binary body
##           when [code]"raw"[/code] is [code]true[/code].[br]
## َ        - [code]"request_data"[/code] (Optional, default empty [String]): String body when [code]"raw"[/code]
##           is [code]false[/code] (default).[br]
## َ    - [param timeout]: Optional timeout in seconds.[br]
## َ    - [param download_file]: The file to download into.[br][br]
## [b]Note:[/b] All parameters are optional, but if you need to send a request in this function you
## should set a value for [param request] [code]"url"[/code] key.[br][br]
## [b]See also:[/b] [HTTPRequest], [HTTPClient]
func http_request(callback := Callable(), request := {}, timeout := 0.0, download_file := "") -> HTTPRequest:
	var hr := HTTPRequest.new()
	hr.download_file = download_file
	hr.timeout = timeout
	if callback.is_valid():
		hr.request_completed.connect(callback)
		hr.request_completed.connect(func(a, b, c, d): await get_tree().process_frame; hr.queue_free())
	if request.has("url"):
		add_child(hr)
		hr.name = "HTTPRequest (" + request.get("url").replace("://", ">").replace("/", ">").replace(".", "_") + ")"
		var err := Error.OK
		if request.get("raw", false):
			err = hr.request_raw(
				request.get("url"),
				request.get("custom_headers", PackedStringArray()),
				request.get("method", HTTPClient.METHOD_GET),
				request.get("request_data_raw", PackedByteArray())
			)
		else:
			err = hr.request(
				request.get("url"),
				request.get("custom_headers", PackedStringArray()),
				request.get("method", HTTPClient.METHOD_GET),
				request.get("request_data", String())
			)
		if err:
			Notif.notif(
				"http_request_failed",
				{"text_append": error_string(err)}
			)
			remove_child(hr)
			hr.queue_free()
			return null
	return hr
