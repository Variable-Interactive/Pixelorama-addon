tool
class_name LayerButton
extends Button

var i := 0
var visibility_button : BaseButton
var lock_button : BaseButton
var linked_button : BaseButton
var label : Label
var line_edit : LineEdit

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

func _enter_tree():
	if Engine.is_editor_hint():
		yield(get_tree(), "idle_frame")
	global = get_node(Constants.NODE_PATH_GLOBAL)
	print("Layer container global: %s" % [global])
	visibility_button = global.find_node_by_name(self, "VisibilityButton")
	lock_button = global.find_node_by_name(self, "LockButton")
	linked_button = global.find_node_by_name(self, "LinkButton")
	label = global.find_node_by_name(self, "Label")
	line_edit = global.find_node_by_name(self, "LineEdit")
	if global.current_project.layers[i].visible:
		global.change_button_texturerect(visibility_button.get_child(0), "layer_visible.png")
		visibility_button.get_child(0).rect_size = Vector2(24, 14)
		visibility_button.get_child(0).rect_position = Vector2(4, 9)
	else:
		global.change_button_texturerect(visibility_button.get_child(0), "layer_invisible.png")
		visibility_button.get_child(0).rect_size = Vector2(24, 8)
		visibility_button.get_child(0).rect_position = Vector2(4, 12)

	if global.current_project.layers[i].locked:
		global.change_button_texturerect(lock_button.get_child(0), "lock.png")
	else:
		global.change_button_texturerect(lock_button.get_child(0), "unlock.png")

	if global.current_project.layers[i].new_cels_linked: # If new layers will be linked
		global.change_button_texturerect(linked_button.get_child(0), "linked_layer.png")
	else:
		global.change_button_texturerect(linked_button.get_child(0), "unlinked_layer.png")


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
	global.layers_changed_skip = true
	global.current_project.layers[i].name = new_name


func _on_VisibilityButton_pressed() -> void:
	global.current_project.layers[i].visible = !global.current_project.layers[i].visible
	global.canvas.update()


func _on_LockButton_pressed() -> void:
	global.current_project.layers[i].locked = !global.current_project.layers[i].locked


func _on_LinkButton_pressed() -> void:
	global.current_project.layers[i].new_cels_linked = !global.current_project.layers[i].new_cels_linked
	if global.current_project.layers[i].new_cels_linked && !global.current_project.layers[i].linked_cels:
		# If button is pressed and there are no linked cels in the layer
		global.current_project.layers[i].linked_cels.append(global.current_project.frames[global.current_project.current_frame])
		global.current_project.layers[i].frame_container.get_child(global.current_project.current_frame)._enter_tree()
