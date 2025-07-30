class_name GlobalExtensionHub
extends Node
## Global Forge Bridge for extensions.
##
## This is a hub for extensions to make connections (global signleton: [code]ExtensionHub[/code]).
## With this class extensions can define as dock and connect to other ports to communication
## with other extensions.[br][br]
## [b]Important:[/b] Ports are signals. For limitation of Godot, all data should passed as a signle
## array as signal parameters, this will fixed in Godot 4.5 (currently unreleased version).[br]
## [b]Example usage:[/b]
## [codeblock]
## # extension_one.gd
## extends Node
##
## # define input port, input_ prefix is optional but recommended
## # input ports will used by other extensions to send data here
## signal input_print_data(data: Array)
##
## # define output port, output_ prefix is optional but recommended
## # output ports will used by this extension to share information, it can be an event, a callback or anything else
## signal output_timeout
##
## var timer: Timer
##
## func _ready() -> void:
##     ExtensionHub.dock("example_extension_one", self) # dock self to hub
##
##     input_print_data.connect(_print_data) # connect input ports to self functions
##
##     timer = Timer.new()
##     add_child(timer)
##     timer.wait_time = 30 # this extension have a timer for each 30 seconds
##     timer.timeout.connect(output_timeout) # use port
##     timer.start()
##
##
## func _print_data(data: Array) -> void:
##     print("Extension one said this:")
##     print(data[0)
##     print("Extension one or other extensions can do this!")
##     print("It's true, but this action was created for other extensions...")
## [/codeblock]
## [codeblock]
## # extension_two.gd
## # anything can connect to extension hub, just should be object
## extends Object
##
## # this extension haven't any port
##
## func _ready():
##     if ExtensionHub.has_dock("example_extension_one"):
##         if ExtensionHub.has_port("example_extension_one", "output_timeout"):
##             ExtensionHub.connect_to_port(("example_extension_one", "output_timeout", _on_timeout)
##
##     ExtensionHub.emit_port("example_extension_one", "input_print_data", ["Extension Two Is Ready!"])
##
##
## func _on_timeout():
##     print("30 seconds passed")
## [/codeblock]

## Stores all docked docks (see [method dock] and [method undock]).
var docks: Dictionary[String, Object]

## Connects given [param callable] to spific [param port] of dock with [param dock_id]. Returns
## [constant ERR_INVALID_PARAMETER] and pushes an error message if the port already connected,
## unless the port is connected with [constant Object.CONNECT_REFERENCE_COUNTED] flag. See
## [enum Object.ConnectFlags] for available [param flag] values (merge multiple flag is available).
func connect_to_port(dock_id: String, port: String, callable: Callable, flags: int = 0) -> Error:
	return docks[dock_id].connect(port, callable, flags)


## Returns [code]true[/code] if a connection exists between the given [param port] name and
## [param callable].
func is_connected_to_port(dock_id: String, port: String, callable: Callable) -> bool:
	return docks[dock_id].is_connected(port, callable)


## Disconnects a [param port] by name from a given [param callable]. If the connection does not
## exist, generates an error. Use [method is_connected_to_port] to make sure that the connection
## exists.
func disconnect_from_port(dock_id: String, port: String, callable: Callable) -> void:
	docks[dock_id].disconnect(port, callable)


## Returs All available dock ids, You can use dock id to access to a dock ind its ports.
func get_docks() -> Array[String]:
	return docks.keys()


## Returns names of valid ports in dock with given [param dock_id].
func get_ports(dock_id: String) -> Array[String]:
	return docks[dock_id].get_signal_list().map(func(dict): return dict["name"])


## Returns an [Array] of connections for the given [param port] name. See
## [method Object.get_signal_connection_list] for structure.
func get_port_connections(dock_id: String, port: String) -> Array[Dictionary]:
	return docks[dock_id].get_signal_connection_list(port)


## Docks given [param object] with [param id] as new dock, this id will be access way to this dock.
func dock(id: String, object: Node) -> void:
	docks[id] = object


## Undocks dock with given [param id].[br][br]
## [b]Note:[/b] Undock a dock will not disconnect connections of its ports.
func undock(id: String) -> void:
	if has_dock(id): docks.erase(id)


## Returns [code]true[/code] if given [param id] is valid.
func has_dock(id: String) -> bool:
	return docks.has(id)


## Returns [code]true[/code] if given [param dock_id] has a port with given [param port] name.
func has_port(dock_id: String, port: String) -> bool:
	return docks[dock_id].get_signal_list().any(func(dict): return dict["name"] == port)


## Emits given [param port] with given [param data]. For limitation of Godot, currntly all ports
## with data transfering feature must use a single [Array] as parameter.[br][br]
## [b]Note:[/b] It will be fixed after release first stable version of Godot 4.5.
func emit_port(dock_id: String, port: String, data: Array = []) -> void:
	if data != []:
		docks[dock_id].emit_signal(port, data)
	else:
		docks[dock_id].emit_signal(port)
