extends Window

@export var project_item: Button
@export var project_list: VBoxContainer

func _ready() -> void:
	for i in Project.recent_menu.get_item_count():
		var item := project_item.duplicate() as Button
		var config := ConfigFile.new()
		var err := config.load(Project.recent_menu.get_item_text(i))
		if err:
			Global.send_notification(Global.Notification.ERROR, "Failed to read project file: " + Project.recent_menu.get_item_text(i))
			continue
		var icon_path: String = config.get_value("project", "icon", "")
		if icon_path and FileAccess.file_exists(icon_path):
			var image := Image.load_from_file(icon_path)
			if image:
				item.get_node(^"Panel/HBox/Icon").texture = ImageTexture.create_from_image(image)
		item.get_node(^"Panel/HBox/Labels/Name").text = config.get_value("project", "name")
		item.get_node(^"Panel/HBox/Labels/Modified").text = config.get_value("project", "modified")
		item.pressed.connect(_open_project.bind(Project.recent_menu.get_item_text(i)))
		item.show()
		project_list.add_child(item)


func _open_project(path: String) -> void:
	Project.load_project(path)
	queue_free()
