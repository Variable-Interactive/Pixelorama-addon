tool
extends AcceptDialog

# Preferences table: [Prop name in Global, relative node path, value type, default value]
func get_preferences():
	return [
		["open_last_project", "Startup/StartupContainer/OpenLastProject", "pressed", global.open_last_project],
		["shrink", "Interface/ShrinkContainer/ShrinkHSlider", "value", global.shrink],
		["smooth_zoom", "Canvas/ZoomOptions/SmoothZoom", "pressed", global.smooth_zoom],
		["pressure_sensitivity_mode", "Startup/PressureSentivity/PressureSensitivityOptionButton", "selected", global.pressure_sensitivity_mode],
		["show_left_tool_icon", "Indicators/IndicatorsContainer/LeftToolIconCheckbox", "pressed", global.show_left_tool_icon],
		["show_right_tool_icon", "Indicators/IndicatorsContainer/RightToolIconCheckbox", "pressed", global.show_right_tool_icon],
		["left_square_indicator_visible", "Indicators/IndicatorsContainer/LeftIndicatorCheckbox", "pressed", global.left_square_indicator_visible],
		["right_square_indicator_visible", "Indicators/IndicatorsContainer/RightIndicatorCheckbox", "pressed", global.right_square_indicator_visible],
		["autosave_interval", "Backup/AutosaveContainer/AutosaveInterval", "value", global.autosave_interval],
		["enable_autosave", "Backup/AutosaveContainer/EnableAutosave", "pressed", global.enable_autosave],

		["default_image_width", "Image/ImageOptions/ImageDefaultWidth", "value", global.default_image_width],
		["default_image_height", "Image/ImageOptions/ImageDefaultHeight", "value", global.default_image_height],
		["default_fill_color", "Image/ImageOptions/DefaultFillColor", "color", global.default_fill_color],

		["grid_type", "Canvas/GridOptions/GridType", "selected", global.grid_type],
		["grid_width", "Canvas/GridOptions/GridWidthValue", "value", global.grid_width],
		["grid_height", "Canvas/GridOptions/GridHeightValue", "value", global.grid_height],
		["grid_isometric_cell_size", "Canvas/GridOptions/IsometricCellSizeValue", "value", global.grid_isometric_cell_size],
		["grid_color", "Canvas/GridOptions/GridColor", "color", global.grid_color],
		["guide_color", "Canvas/GuideOptions/GuideColor", "color", global.guide_color],
		["checker_size", "Canvas/CheckerOptions/CheckerSizeValue", "value", global.checker_size],
		["checker_color_1", "Canvas/CheckerOptions/CheckerColor1", "color", global.checker_color_1],
		["checker_color_2", "Canvas/CheckerOptions/CheckerColor2", "color", global.checker_color_2],
		["checker_follow_movement", "Canvas/CheckerOptions/CheckerFollowMovement", "pressed", global.checker_follow_movement],
		["checker_follow_scale", "Canvas/CheckerOptions/CheckerFollowScale", "pressed", global.checker_follow_scale],
		["tilemode_opacity", "Canvas/CheckerOptions/TileModeOpacity", "value", global.tilemode_opacity],
	]

var selected_item := 0

var list : ItemList
var right_side : VBoxContainer
var autosave_interval : SpinBox
var restore_default_button_scene = preload("res://addons/pixelorama/src/Preferences/RestoreDefaultButton.tscn")
var shrink_label : Label

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

func _enter_tree() -> void:
	yield(get_tree(), "idle_frame")
	global = get_node(Constants.NODE_PATH_GLOBAL)
	if global.is_getting_edited(self):
		return
	list = $HSplitContainer/List
	right_side = $HSplitContainer/ScrollContainer/VBoxContainer
	autosave_interval = $HSplitContainer/ScrollContainer/VBoxContainer/Backup/AutosaveContainer/AutosaveInterval
	shrink_label = $HSplitContainer/ScrollContainer/VBoxContainer/Interface/ShrinkContainer/ShrinkLabel
	
	# Replace OK with Close since preference changes are being applied immediately, not after OK confirmation
	get_ok().text = tr("Close")

	if OS.get_name() == "HTML5":
		right_side.get_node("Startup").queue_free()
		right_side.get_node("Languages").visible = true
		global.open_last_project = false

	for pref in get_preferences():
		var node = right_side.get_node(pref[1])
		var node_position = node.get_index()

		var restore_default_button : BaseButton = restore_default_button_scene.instance()
		restore_default_button.setting_name = pref[0]
		restore_default_button.value_type = pref[2]
		restore_default_button.default_value = pref[3]
		restore_default_button.node = node
		node.get_parent().add_child(restore_default_button)
		node.get_parent().move_child(restore_default_button, node_position)

		match pref[2]:
			"pressed":
				node.connect("toggled", self, "_on_Preference_toggled", [pref[0], pref[3], restore_default_button])
			"value":
				node.connect("value_changed", self, "_on_Preference_value_changed", [pref[0], pref[3], restore_default_button])
			"color":
				node.get_picker().presets_visible = false
				node.connect("color_changed", self, "_on_Preference_color_changed", [pref[0], pref[3], restore_default_button])
			"selected":
				node.connect("item_selected", self, "_on_Preference_item_selected", [pref[0], pref[3], restore_default_button])

		if global.config_cache.has_section_key("preferences", pref[0]):
			var value = global.config_cache.get_value("preferences", pref[0])
			global.set(pref[0], value)
			node.set(pref[2], value)

			# This is needed because color_changed doesn't fire if the color changes in code
			if pref[2] == "color":
				preference_update(pref[0])
				disable_restore_default_button(restore_default_button, global.get(pref[0]).is_equal_approx(pref[3]))
			elif pref[2] == "selected":
				preference_update(pref[0])
				disable_restore_default_button(restore_default_button, global.get(pref[0]) == pref[3])


func _on_Preference_toggled(button_pressed : bool, prop : String, default_value, restore_default_button : BaseButton) -> void:
	global.set(prop, button_pressed)
	global.config_cache.set_value("preferences", prop, button_pressed)
	preference_update(prop)
	disable_restore_default_button(restore_default_button, global.get(prop) == default_value)


func _on_Preference_value_changed(value : float, prop : String, default_value, restore_default_button : BaseButton) -> void:
	global.set(prop, value)
	global.config_cache.set_value("preferences", prop, value)
	preference_update(prop)
	disable_restore_default_button(restore_default_button, global.get(prop) == default_value)


func _on_Preference_color_changed(color : Color, prop : String, default_value, restore_default_button : BaseButton) -> void:
	global.set(prop, color)
	global.config_cache.set_value("preferences", prop, color)
	preference_update(prop)
	disable_restore_default_button(restore_default_button, global.get(prop).is_equal_approx(default_value))


func _on_Preference_item_selected(id : int, prop : String, default_value, restore_default_button : BaseButton) -> void:
	global.set(prop, id)
	global.config_cache.set_value("preferences", prop, id)
	preference_update(prop)
	disable_restore_default_button(restore_default_button, global.get(prop) == default_value)


func preference_update(prop : String) -> void:
	if prop in ["autosave_interval", "enable_autosave"]:
		global.get_open_save().update_autosave()
		autosave_interval.editable = global.enable_autosave
		if autosave_interval.editable:
			autosave_interval.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		else:
			autosave_interval.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN

	if prop in ["grid_type", "grid_width", "grid_height", "grid_isometric_cell_size", "grid_color"]:
		global.canvas.grid.isometric_polylines.clear()
		global.canvas.grid.update()

	if prop in ["checker_size", "checker_color_1", "checker_color_2", "checker_follow_movement", "checker_follow_scale"]:
		global.transparent_checker._enter_tree()

	if prop in ["guide_color"]:
		for guide in global.canvas.get_children():
			if guide is Guide:
				guide.default_color = global.guide_color

	global.config_cache.save("user://cache.ini")


func disable_restore_default_button(button : BaseButton, disable : bool) -> void:
	button.disabled = disable
	if disable:
		button.mouse_default_cursor_shape = Control.CURSOR_ARROW
		button.hint_tooltip = ""
	else:
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.hint_tooltip = "Restore default value"


func _on_PreferencesDialog_about_to_show(changed_language := false) -> void:
	if OS.get_name() != "HTML5":
		list.add_item("  " + tr("Startup"))
	list.add_item("  " + tr("Language"))
	list.add_item("  " + tr("Interface"))
	list.add_item("  " + tr("Canvas"))
	list.add_item("  " + tr("Image"))
	list.add_item("  " + tr("Shortcuts"))
	list.add_item("  " + tr("Backup"))
	list.add_item("  " + tr("Indicators"))

	list.select(1 if changed_language else selected_item)
	autosave_interval.suffix = tr("minute(s)")


func _on_PreferencesDialog_popup_hide() -> void:
	list.clear()


func _on_List_item_selected(index : int) -> void:
	selected_item = index
	for child in right_side.get_children():
		var content_list = ["Startup", "Languages", "Interface", "Canvas", "Image", "Shortcuts", "Backup", "Indicators"]
		if OS.get_name() == "HTML5":
			content_list.erase("Startup")
		child.visible = child.name == content_list[index]


func _on_ShrinkHSlider_value_changed(value : float) -> void:
	shrink_label.text = str(value)


func _on_ShrinkApplyButton_pressed() -> void:
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED,
		SceneTree.STRETCH_ASPECT_IGNORE, Vector2(1024,576), global.shrink)
	hide()
	popup_centered(Vector2(400, 280))
	global.dialog_open(true)
	yield(global.get_tree().create_timer(0.01), "timeout")
	global.camera.fit_to_frame(global.current_project.size)
