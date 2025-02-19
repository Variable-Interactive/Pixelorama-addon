tool
extends ImageEffect


var hue_slider
var sat_slider
var val_slider

var hue_spinbox
var sat_spinbox
var val_spinbox


func set_nodes() -> void:
	hue_slider = $VBoxContainer/HBoxContainer/Sliders/Hue
	sat_slider = $VBoxContainer/HBoxContainer/Sliders/Saturation
	val_slider = $VBoxContainer/HBoxContainer/Sliders/Value

	hue_spinbox = $VBoxContainer/HBoxContainer/TextBoxes/Hue
	sat_spinbox = $VBoxContainer/HBoxContainer/TextBoxes/Saturation
	val_spinbox = $VBoxContainer/HBoxContainer/TextBoxes/Value
	preview = $VBoxContainer/Preview
	selection_checkbox = $VBoxContainer/AffectHBoxContainer/SelectionCheckBox
	affect_option_button = $VBoxContainer/AffectHBoxContainer/AffectOptionButton


func _confirmed() -> void:
	._confirmed()
	reset()


func commit_action(_cel : Image, _pixels : Array, _project : Project = get_node("/root/Pixelorama").current_project) -> void:
	global.get_drawing_algos().adjust_hsv(_cel, hue_slider.value, sat_slider.value, val_slider.value, _pixels)


func reset() -> void:
	disconnect_signals()
	hue_slider.value = 0
	sat_slider.value = 0
	val_slider.value = 0
	hue_spinbox.value = 0
	sat_spinbox.value = 0
	val_spinbox.value = 0
	reconnect_signals()


func disconnect_signals() -> void:
	hue_slider.disconnect("value_changed",self,"_on_Hue_value_changed")
	sat_slider.disconnect("value_changed",self,"_on_Saturation_value_changed")
	val_slider.disconnect("value_changed",self,"_on_Value_value_changed")
	hue_spinbox.disconnect("value_changed",self,"_on_Hue_value_changed")
	sat_spinbox.disconnect("value_changed",self,"_on_Saturation_value_changed")
	val_spinbox.disconnect("value_changed",self,"_on_Value_value_changed")


func reconnect_signals() -> void:
	hue_slider.connect("value_changed",self,"_on_Hue_value_changed")
	sat_slider.connect("value_changed",self,"_on_Saturation_value_changed")
	val_slider.connect("value_changed",self,"_on_Value_value_changed")
	hue_spinbox.connect("value_changed",self,"_on_Hue_value_changed")
	sat_spinbox.connect("value_changed",self,"_on_Saturation_value_changed")
	val_spinbox.connect("value_changed",self,"_on_Value_value_changed")


func _on_Hue_value_changed(value : float) -> void:
	hue_spinbox.value = value
	hue_slider.value = value
	update_preview()


func _on_Saturation_value_changed(value : float) -> void:
	sat_spinbox.value = value
	sat_slider.value = value
	update_preview()


func _on_Value_value_changed(value : float) -> void:
	val_spinbox.value = value
	val_slider.value = value
	update_preview()
