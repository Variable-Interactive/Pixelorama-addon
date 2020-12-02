tool
extends VBoxContainer


var left_picker
var right_picker

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

func _enter_tree() -> void:
	left_picker = $ColorButtonsVertical/ColorPickersCenter/ColorPickersHorizontal/LeftColorPickerButton
	right_picker = $ColorButtonsVertical/ColorPickersCenter/ColorPickersHorizontal/RightColorPickerButton
	global = get_node(Constants.NODE_PATH_GLOBAL)
	if global.is_getting_edited(self):
		return
	global.get_tools().connect("color_changed", self, "update_color")
	left_picker.get_picker().presets_visible = false
	right_picker.get_picker().presets_visible = false


func _on_ColorSwitch_pressed() -> void:
	global.get_tools().swap_color()


func _on_ColorPickerButton_color_changed(color : Color, right : bool):
	var button := BUTTON_RIGHT if right else BUTTON_LEFT
	global.get_tools().assign_color(color, button)


func _on_ColorPickerButton_pressed() -> void:
	global.can_draw = false


func _on_ColorPickerButton_popup_closed() -> void:
	global.can_draw = true


func _on_ColorDefaults_pressed() -> void:
	global.get_tools().default_color()


func update_color(color : Color, button : int) -> void:
	if button == BUTTON_LEFT:
		left_picker.color = color
	else:
		right_picker.color = color
