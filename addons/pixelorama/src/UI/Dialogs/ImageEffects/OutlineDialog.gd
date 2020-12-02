tool
extends ImageEffect


var color := Color.red
var thickness := 1
var diagonal := false
var inside_image := false

var outline_color


func _enter_tree() -> void:
	outline_color = $VBoxContainer/OptionsContainer/OutlineColor
	outline_color.get_picker().presets_visible = false
	color = outline_color.color


func set_nodes() -> void:
	preview = $VBoxContainer/Preview
	selection_checkbox = $VBoxContainer/OptionsContainer/SelectionCheckBox
	affect_option_button = $VBoxContainer/OptionsContainer/AffectOptionButton


func commit_action(_cel : Image, _pixels : Array, _project : Project = get_node("/root/Pixelorama").current_project) -> void:
	global.get_drawing_algos().generate_outline(_cel, _pixels, color, thickness, diagonal, inside_image)


func _on_ThickValue_value_changed(value : int) -> void:
	thickness = value
	update_preview()


func _on_OutlineColor_color_changed(_color : Color) -> void:
	color = _color
	update_preview()


func _on_DiagonalCheckBox_toggled(button_pressed : bool) -> void:
	diagonal = button_pressed
	update_preview()


func _on_InsideImageCheckBox_toggled(button_pressed : bool) -> void:
	inside_image = button_pressed
	update_preview()
