class_name LayerButton
extends Button

var i := 0
var visibility_button : BaseButton
var lock_button : BaseButton
var linked_button : BaseButton
var label : Label
var line_edit : LineEdit


func _ready() -> void:
	visibility_button = get_node("/root/Pixelorama").find_node_by_name(self, "VisibilityButton")
	lock_button = get_node("/root/Pixelorama").find_node_by_name(self, "LockButton")
	linked_button = get_node("/root/Pixelorama").find_node_by_name(self, "LinkButton")
	label = get_node("/root/Pixelorama").find_node_by_name(self, "Label")
	line_edit = get_node("/root/Pixelorama").find_node_by_name(self, "LineEdit")

	if get_node("/root/Pixelorama").current_project.layers[i].visible:
		get_node("/root/Pixelorama").change_button_texturerect(visibility_button.get_child(0), "layer_visible.png")
		visibility_button.get_child(0).rect_size = Vector2(24, 14)
		visibility_button.get_child(0).rect_position = Vector2(4, 9)
	else:
		get_node("/root/Pixelorama").change_button_texturerect(visibility_button.get_child(0), "layer_invisible.png")
		visibility_button.get_child(0).rect_size = Vector2(24, 8)
		visibility_button.get_child(0).rect_position = Vector2(4, 12)

	if get_node("/root/Pixelorama").current_project.layers[i].locked:
		get_node("/root/Pixelorama").change_button_texturerect(lock_button.get_child(0), "lock.png")
	else:
		get_node("/root/Pixelorama").change_button_texturerect(lock_button.get_child(0), "unlock.png")

	if get_node("/root/Pixelorama").current_project.layers[i].new_cels_linked: # If new layers will be linked
		get_node("/root/Pixelorama").change_button_texturerect(linked_button.get_child(0), "linked_layer.png")
	else:
		get_node("/root/Pixelorama").change_button_texturerect(linked_button.get_child(0), "unlinked_layer.png")


func _input(event : InputEvent) -> void:
	if (event.is_action_released("ui_accept") or event.is_action_released("ui_cancel")) and line_edit.visible and event.scancode != KEY_SPACE:
		save_layer_name(line_edit.text)


func _on_LayerContainer_pressed() -> void:
	pressed = !pressed
	label.visible = false
	line_edit.visible = true
	line_edit.editable = true
	line_edit.grab_focus()


func _on_LineEdit_focus_exited() -> void:
	save_layer_name(line_edit.text)


func save_layer_name(new_name : String) -> void:
	label.visible = true
	line_edit.visible = false
	line_edit.editable = false
	label.text = new_name
	get_node("/root/Pixelorama").layers_changed_skip = true
	get_node("/root/Pixelorama").current_project.layers[i].name = new_name


func _on_VisibilityButton_pressed() -> void:
	get_node("/root/Pixelorama").current_project.layers[i].visible = !get_node("/root/Pixelorama").current_project.layers[i].visible
	get_node("/root/Pixelorama").canvas.update()


func _on_LockButton_pressed() -> void:
	get_node("/root/Pixelorama").current_project.layers[i].locked = !get_node("/root/Pixelorama").current_project.layers[i].locked


func _on_LinkButton_pressed() -> void:
	get_node("/root/Pixelorama").current_project.layers[i].new_cels_linked = !get_node("/root/Pixelorama").current_project.layers[i].new_cels_linked
	if get_node("/root/Pixelorama").current_project.layers[i].new_cels_linked && !get_node("/root/Pixelorama").current_project.layers[i].linked_cels:
		# If button is pressed and there are no linked cels in the layer
		get_node("/root/Pixelorama").current_project.layers[i].linked_cels.append(get_node("/root/Pixelorama").current_project.frames[get_node("/root/Pixelorama").current_project.current_frame])
		get_node("/root/Pixelorama").current_project.layers[i].frame_container.get_child(get_node("/root/Pixelorama").current_project.current_frame)._ready()
