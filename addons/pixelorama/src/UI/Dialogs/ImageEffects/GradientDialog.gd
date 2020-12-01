tool
extends ImageEffect


var color1 : ColorPickerButton
var color2 : ColorPickerButton
var steps : SpinBox
var direction : OptionButton


func _enter_tree() -> void:
	color1 = $VBoxContainer/OptionsContainer/ColorsContainer/ColorPickerButton
	color2 = $VBoxContainer/OptionsContainer/ColorsContainer/ColorPickerButton2
	steps = $VBoxContainer/OptionsContainer/StepSpinBox
	direction = $VBoxContainer/OptionsContainer/DirectionOptionButton
	color1.get_picker().presets_visible = false
	color2.get_picker().presets_visible = false


func set_nodes() -> void:
	preview = $VBoxContainer/Preview
	selection_checkbox = $VBoxContainer/OptionsContainer/SelectionCheckBox
	affect_option_button = $VBoxContainer/OptionsContainer/AffectOptionButton


func commit_action(_cel : Image, _pixels : Array, _project : Project = get_node("/root/Pixelorama").current_project) -> void:
	DrawingAlgos.generate_gradient(_cel, [color1.color, color2.color], steps.value, direction.selected, _pixels)


func _on_ColorPickerButton_color_changed(_color : Color) -> void:
	update_preview()


func _on_ColorPickerButton2_color_changed(_color : Color) -> void:
	update_preview()


func _on_StepSpinBox_value_changed(_value : int) -> void:
	update_preview()


func _on_DirectionOptionButton_item_selected(_index : int) -> void:
	update_preview()
