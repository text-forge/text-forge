class_name MarketplaceWindow
extends Window
## Marketplace to view and install external packages.
##
## See [url=https://github.com/text-forge/mp]text-forge/mp[/url] repository for backend source.[br]
## Visit [url=https://text-forge.github.io/marketplace]Online Marketplace[/url] to explore
## marketplace without editor.

## Status of compatibility between package and editor.
enum CompatibilityStatus {
	COMPATIBLE,
	INCOMPATIBLE,
	UNVERIFIED
}

## Path to download host.
const MP_HOST = "https://raw.githubusercontent.com/text-forge/mp/refs"
## Name of central package information file.
const PACKAGES_INFORMATION = "packages.json"
## Name of package information file for each package.
const PACK_INFORMATION = "pack.json"
## Package item scene.
const PACKAGE_ITEM = preload("res://action_scripts/scenes/package_item.tscn")

## Packages list.
@export var packages: VBoxContainer
## Version [LineEdit].
@export var version_edit: LineEdit
## Package information name.
@export var i_name: Label
## Package information author.
@export var i_author: Label
## Package information category.
@export var i_category: Label
## Package information version.
@export var i_version: Label
## Package information minimum editor version.
@export var i_min_editor_version: Label
## Package information release and update dates.
@export var i_dates: Label
## Package information tags.
@export var i_tags: HFlowContainer
## Package information description.
@export var i_description: Label
## Package information images.
@export var i_images: HBoxContainer
## Package information popup window.
@export var information_popup: Window
## Package information install button.
@export var install_button: Button
## Search [LineEdit].
@export var search: LineEdit
## Filter options.
@export var filter: OptionButton

## Content of [constant PACKAGES_INFORMATION] file.
var info: Array
## Version of current branch in host.
var version: String

func _ready() -> void:
	Notif.register_notification(
		"marketplace_connection_failed",
		Notif.Type.ERR,
		"Failed to connect to marketplace!"
	)
	Notif.register_notification(
		"package_information_parse_failed",
		Notif.Type.ERR,
		"Failed to parse package information!",
		"Invalid JSON response from server.",
	)
	Notif.register_notification(
		"package_not_found",
		Notif.Type.ERR,
		"Package not found!",
		"Could not find package with id: ",
	)
	Notif.register_notification(
		"invalid_package_information",
		Notif.Type.ERR,
		"Invalid package information!",
		"Missing compatible_versions field.",
	)
	Notif.register_notification(
		"downloading_and_installing_package",
		Notif.Type.INFO,
		"Please don't close marketplace window!",
		"Downloading and installing package is in progress...",
	)
	Notif.register_notification(
		"download_package_failed",
		Notif.Type.ERR,
		"Failed to download package!",
		"Result code: {0}\nResponse code: {1}",
	)
	Notif.register_notification(
		"save_package_failed",
		Notif.Type.ERR,
		"Failed to save package!",
		"Could not open {0} for writing. Error: {1}"
	)
	Notif.register_notification(
		"package_installed",
		Notif.Type.INFO,
		"Package installed!",
		"You can close marketplace window now."
	)
	Notif.register_notification(
		"download_package_image_failed",
		Notif.Type.ERR,
		"Failed to download package image!",
		"Result code: {0}\nResponse code: {1}"
	)
	Notif.register_notification(
		"load_package_image_failed",
		Notif.Type.ERR,
		"Failed to load package PNG image from buffer!",
		"Error: "
	)
	Notif.register_notification(
		"invalid_package_version",
		Notif.Type.ERR,
		"Invalid package version information!",
		"{0} doesn't match with package version information pattern."
	)
	version = version_edit.text
	if NetSuite.http_request(
		_on_packages_info_request_completed,
		{ "url": MP_HOST.path_join(version).path_join(PACKAGES_INFORMATION) }
	) == null:
		Notif.notif(
			"marketplace_connection_failed",
			{"text": "Could not initiate HTTP request."},
		)
		S.free_all_children(packages)


func _on_packages_info_request_completed(__: int, response_code: int, ___: PackedStringArray, body: PackedByteArray) -> void:
	S.free_all_children(packages)
	if response_code != HTTPClient.RESPONSE_OK:
		Notif.notif(
			"marketplace_connection_failed",
			{"text": "Response code: " + str(response_code)}
		)
		return
	info = JSON.parse_string(body.get_string_from_utf8())
	if info == null:
		Notif.notif("package_information_parse_failed")
		return
	for p in info:
		if not (p is Dictionary and p.has_all(["id", "name", "version", "category", "author",
			"tags", "description", "updated", "created", "editor_version_min"])):
			continue
		var n := PACKAGE_ITEM.instantiate()
		n.setup(
			p["id"], p["name"], p["version"], p["category"], p["author"], p["tags"],
			p["description"], p["updated"], p["created"], p["editor_version_min"],
			_on_package_information_requested
		)
		packages.add_child(n)


func _on_package_information_requested(id: String) -> void:
	var filtered := info.filter(func(p): return p["id"] == id)
	if filtered.is_empty():
		Notif.notif(
			"package_not_found",
			{"text_append": id},
		)
		return
	var pack_info: Dictionary = filtered[0]
	i_description.text = "Loading..."
	S.free_all_children(i_images)
	NetSuite.http_request(
		_complete_package_information.bind(pack_info),
		{ "url": MP_HOST.path_join(version).path_join("packages").path_join(pack_info["id"]).path_join(PACK_INFORMATION) }
	)
	S.free_all_children(i_tags)
	install_button.disabled = true
	i_name.text = pack_info["name"]
	i_author.text = "by " + pack_info["author"]
	i_category.text = pack_info["category"]
	i_version.text = pack_info["version"]
	i_min_editor_version.text = "Text Forge {0}+".format([pack_info["editor_version_min"]])
	i_dates.text = pack_info["updated"] + " | " + pack_info["created"]
	for t in pack_info["tags"]:
		var tag := Label.new()
		tag.text = t
		tag.set_theme_type_variation("PackageBadgeLabel")
		i_tags.add_child(tag)
	information_popup.show()


func _complete_package_information(
		__: int,
		response_code: int,
		___: PackedStringArray,
		body: PackedByteArray,
		pack_info: Dictionary
	) -> void:
	if install_button.pressed.is_connected(_install_package):
		install_button.pressed.disconnect(_install_package)
	if response_code != HTTPClient.RESPONSE_OK:
		Notif.notif(
			"marketplace_connection_failed",
			{"text": "Response code: " + str(response_code)}
		)
		return
	var _info = JSON.parse_string(body.get_string_from_utf8())
	if _info == null:
		Notif.notif("package_information_parse_failed")
		return
	if not _info.has("compatible_versions"):
		Notif.notif("invalid_package_information")
		return
	match get_compatibility_status(_info["compatible_versions"]):
		CompatibilityStatus.INCOMPATIBLE:
			install_button.text = "Install"
			install_button.tooltip_text = "This package isn't compatible with your editor version!"
			install_button.disabled = true
		CompatibilityStatus.UNVERIFIED:
			install_button.text = "Install (!)"
			install_button.tooltip_text = "This package isn't tested with your editor version! Use with caution."
			install_button.disabled = false
		CompatibilityStatus.COMPATIBLE:
			install_button.text = "Install"
			install_button.tooltip_text = ""
			install_button.disabled = false
	i_description.text = _info["description"]
	if _info.has("images"):
		for i in _info["images"]:
			NetSuite.http_request(
				_add_image,
				{ "url": MP_HOST.path_join(version).path_join("packages").path_join(pack_info["id"]).path_join(i) }
			)
	install_button.pressed.connect(_install_package.bind(pack_info, _info))


func _install_package(pack_info: Dictionary, _info: Dictionary) -> void:
	var path_to_download := "user://_temp_mode.tfmode"
	if pack_info["category"] == "themes":
		path_to_download = S.FOLDER_THEMES.path_join(_info["file"])
	elif pack_info["category"] == "extensions":
		path_to_download = "user://_temp_extension.tfx"
	var data_to_pass := {
		"name": pack_info["name"],
		"category": pack_info["category"],
		"file": path_to_download,
	}
	NetSuite.http_request(
		_complete_installation.bind(data_to_pass),
		{
			"url": MP_HOST.path_join(version).path_join("packages").path_join(pack_info["id"]).path_join(_info["file"]),
		}
	)
	Notif.notif("downloading_and_installing_package")
	information_popup.hide()


func _complete_installation(
		result: int,
		response_code: int,
		__: PackedStringArray,
		body: PackedByteArray,
		data: Dictionary
	) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != HTTPClient.RESPONSE_OK:
		Notif.notif(
			"download_package_failed",
			{"format_text": [result, response_code]}
		)
		return
	var path: String = data["file"]
	var downloaded := FileAccess.open(path, FileAccess.WRITE)
	if downloaded == null:
		Notif.notif(
			"save_package_failed",
			{"format_text": [path, error_string(FileAccess.get_open_error())]}
		)
		return
	downloaded.store_buffer(body)
	downloaded.close()
	match data["category"]:
		"extensions":
			Extensions.install_extension(path)
		"modes":
			Global.get_editor_api().import_mode(path)
		"themes":
			add_child(Factory.confirmation_dialog(
				"Theme installation complete. Do you want to use it now?",
				"Yes",
				"No, later",
				"Do you want to use the new theme?",
				Callable(),
				_change_theme.bind(path.get_file().get_basename())
			))
	Notif.notif("package_installed")


func _change_theme(t_name: String) -> void:
	Settings.set_setting("editor_ui", "theme_name", t_name)


func _add_image(result: int, response_code: int, __: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != HTTPClient.RESPONSE_OK:
		Notif.notif(
			"download_package_image_failed",
			{"format_text": [result, response_code]}
		)
		return
	var image := Image.new()
	var err := image.load_png_from_buffer(body)
	if err:
		Notif.notif(
			"load_package_image_failed",
			{"text_append": error_string(err)}
		)
		return
	var texture = ImageTexture.create_from_image(image)
	var texture_rect = TextureRect.new()
	texture_rect.texture = texture
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	i_images.add_child(texture_rect)


func get_compatibility_status(compatible_versions: String) -> CompatibilityStatus:
	var editor_version: Array[int] = S.map_array_to_int(S.EDITOR_VERSION.split(".", false, 2))
	var regex := RegEx.new()
	regex.compile(r">(?<min_e>=?)(?<min>\d+\.\d+\.\d+)(?: <(?<max_e>=?)(?<max>\d+\.\d+\.\d+))? \|\| \?(?<unv>\d+\.\d+\.\d+)")
	var result := regex.search(compatible_versions)
	if not result:
		Notif.notif(
			"invalid_package_version",
			{"format_text": [compatible_versions]}
		)
		return CompatibilityStatus.INCOMPATIBLE
	if true: # Unverified versions check
		var unv := S.map_array_to_int(result.get_string("unv").split(".", false, 2))
		if _compare_versions(editor_version, unv) == 1 or editor_version[2] == unv[2]:
			return CompatibilityStatus.UNVERIFIED
	if true: # Minimum version check
		var minimum := S.map_array_to_int(result.get_string("min").split(".", false, 2))
		var minimum_e := result.get_string("min_e") != ""
		if (
			_compare_versions(editor_version, minimum) == -1
			or (editor_version[2] == minimum[2] and not minimum_e)
		):
			return CompatibilityStatus.INCOMPATIBLE
	if result.get_string("max") != "": # Maximum version check
		var maximum := S.map_array_to_int(result.get_string("max").split(".", false, 2))
		var maximum_e := result.get_string("max_e") != ""
		if (
			_compare_versions(editor_version, maximum) == 1
			or (editor_version[2] == maximum[2] and not maximum_e)
		):
			return CompatibilityStatus.INCOMPATIBLE
	return CompatibilityStatus.COMPATIBLE


# Helper function to compare versions
func _compare_versions(a: Array[int], b: Array[int]) -> int:
	for i in range(min(a.size(), b.size())):
		if a[i] < b[i]:
			return -1
		elif a[i] > b[i]:
			return 1
	return 0


func _on_search_text_changed(new_text: String) -> void:
	var selected_id := filter.get_selected_id()
	var selected_category := filter.get_item_text(filter.get_item_index(selected_id)).to_lower()
	for n: PanelContainer in packages.get_children():
		if ((
				n.n_category.text == selected_category
				or selected_id == 0
			) and (
				n.n_name.text.containsn(new_text)
				or new_text.is_empty()
			)):
			n.visible = true
		else:
			n.visible = false


func _on_filter_item_selected() -> void:
	_on_search_text_changed(search.text)
