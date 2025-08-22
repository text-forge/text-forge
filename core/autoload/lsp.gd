class_name TextForgeLSP
extends Node

signal shutdown_success

var client := StreamPeerTCP.new()
var message_id := 1

var json_rpc := JSONRPC.new()

func _process(delta):
	client.poll()
	if client.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		return
	if client.get_available_bytes() > 0:
		var response = client.get_utf8_string(client.get_available_bytes())
		print("LSP Response:\n", response)
		shutdown()


func shutdown() -> void:
	var msg := json_rpc.make_request(
		"shutdown",
		null,
		message_id
	)
	send_message(msg)


func connect_to_server(host: String, port: int) -> void:
	var err = client.connect_to_host(host, port)
	if err:
		printerr("LSP failed to connect with error code " + str(err))
	else:
		print("LSP client is connecting to {0}:{1}".format([host, port]))
		while client.get_status() == StreamPeerTCP.STATUS_CONNECTING:
			await get_tree().create_timer(0.1).timeout
		print("LSP client connected")
		send_initialize()


func send_initialize() -> void:
	var msg := json_rpc.make_request(
		"initialize",
		{
			"processId": null,
			"rootUri": "file:///" + Global.get_file_path().uri_encode(),
			"clientInfo": {
				"name": "Text Forge",
				"version": SLib.get_project_setting("application/config/version")
			},
			"locale": Settings.get_setting("languages", "main", "en"),
			"workspaceFolders": null, # for project feature
			"capabilities": {

			},
		},
		message_id
	)
	send_message(msg)


func send_did_open(uri: String, language_id: String, text: String) -> void:
	var msg := json_rpc.make_notification(
		"textDocument/didOpen",
		{
			"textDocument": {
				"uri": uri,
				"languageId": language_id,
				"version": 1,
				"text": text
			}
		}
	)
	send_message(msg)


func send_message(msg: Dictionary) -> void:
	var json := JSON.stringify(msg)
	var header := "Content-Length: %d\r\n\r\n" % json.to_utf8_buffer().size()
	#print("Send message to LSP: " + header + json)
	var ful_msg := header.to_ascii_buffer() + json.to_utf8_buffer()
	client.put_data(ful_msg)
	if msg.has("id"):
		message_id += 1
