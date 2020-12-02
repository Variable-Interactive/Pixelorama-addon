tool
extends ImageEffect


var type_option_button : OptionButton
var angle_hslider : HSlider
var angle_spinbox : SpinBox


func _enter_tree() -> void:
	type_option_button = $VBoxContainer/HBoxContainer2/TypeOptionButton
	angle_hslider = $VBoxContainer/AngleOptions/AngleHSlider
	angle_spinbox = $VBoxContainer/AngleOptions/AngleSpinBox
	type_option_button.add_item("Rotxel")
	type_option_button.add_item("Upscale, Rotate and Downscale")
	type_option_button.add_item("Nearest neighbour")


func set_nodes() -> void:
	preview = $VBoxContainer/Preview
	selection_checkbox = $VBoxContainer/OptionsContainer/SelectionCheckBox
	affect_option_button = $VBoxContainer/OptionsContainer/AffectOptionButton


func _about_to_show() -> void:
	._about_to_show()
	angle_hslider.value = 0


func commit_action(_cel : Image, _pixels : Array, _project : Project = get_node("/root/Pixelorama").current_project) -> void:
	var angle : float = deg2rad(angle_hslider.value)
	match type_option_button.text:
		"Rotxel":
			global.get_drawing_algos().rotxel(_cel, angle, _pixels)
		"Nearest neighbour":
			global.get_drawing_algos().nn_rotate(_cel, angle, _pixels)
		"Upscale, Rotate and Downscale":
			global.get_drawing_algos().fake_rotsprite(_cel, angle, _pixels)


func _confirmed() -> void:
	._confirmed()
	angle_hslider.value = 0


func _on_HSlider_value_changed(_value : float) -> void:
	update_preview()
	angle_spinbox.value = angle_hslider.value


func _on_SpinBox_value_changed(_value : float) -> void:
	angle_hslider.value = angle_spinbox.value


func _on_TypeOptionButton_item_selected(_id : int) -> void:
	update_preview()
