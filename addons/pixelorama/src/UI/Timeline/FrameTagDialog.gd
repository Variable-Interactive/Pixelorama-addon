tool
extends AcceptDialog


var current_tag_id := 0
var tag_vboxes := []
var delete_tag_button : Button

var main_vbox_cont : VBoxContainer
var add_tag_button : Button
var options_dialog


func _enter_tree() -> void:
	main_vbox_cont = $VBoxContainer/ScrollContainer/VBoxTagContainer
	add_tag_button = $VBoxContainer/ScrollContainer/VBoxTagContainer/AddTag
	options_dialog = $TagOptions
	$"TagOptions/GridContainer/ColorPickerButton".get_picker().presets_visible = false

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

func _on_FrameTagDialog_about_to_show() -> void:
	global = get_node(Constants.NODE_PATH_GLOBAL)
	if global.is_getting_edited(self):
		return
	global.dialog_open(true)
	for vbox in tag_vboxes:
		vbox.queue_free()
	tag_vboxes.clear()

	var i := 0
	for tag in global.current_project.animation_tags:
		var vbox_cont := VBoxContainer.new()
		var hbox_cont := HBoxContainer.new()
		var tag_label := Label.new()
		if tag.from == tag.to:
			tag_label.text = tr("Tag %s (Frame %s)") % [i + 1, tag.from]
		else:
			tag_label.text = tr("Tag %s (Frames %s-%s)") % [i + 1, tag.from, tag.to]
		hbox_cont.add_child(tag_label)

		var edit_button := Button.new()
		edit_button.text = "Edit"
		edit_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		edit_button.connect("pressed", self, "_on_EditButton_pressed", [i])
		hbox_cont.add_child(edit_button)
		vbox_cont.add_child(hbox_cont)

		var name_label := Label.new()
		name_label.text = tag.name
		name_label.modulate = tag.color
		vbox_cont.add_child(name_label)

		var hsep := HSeparator.new()
		hsep.size_flags_horizontal = SIZE_EXPAND_FILL
		vbox_cont.add_child(hsep)

		main_vbox_cont.add_child(vbox_cont)
		tag_vboxes.append(vbox_cont)

		i += 1

	add_tag_button.visible = true
	main_vbox_cont.move_child(add_tag_button, main_vbox_cont.get_child_count() - 1)


func _on_FrameTagDialog_popup_hide() -> void:
	global.dialog_open(false)


func _on_AddTag_pressed() -> void:
	options_dialog.popup_centered()
	current_tag_id = global.current_project.animation_tags.size()
	options_dialog.get_node("GridContainer/FromSpinBox").value = global.current_project.current_frame + 1
	options_dialog.get_node("GridContainer/ToSpinBox").value = global.current_project.current_frame + 1


func _on_EditButton_pressed(_tag_id : int) -> void:
	options_dialog.popup_centered()
	current_tag_id = _tag_id
	options_dialog.get_node("GridContainer/NameLineEdit").text = global.current_project.animation_tags[_tag_id].name
	options_dialog.get_node("GridContainer/ColorPickerButton").color = global.current_project.animation_tags[_tag_id].color
	options_dialog.get_node("GridContainer/FromSpinBox").value = global.current_project.animation_tags[_tag_id].from
	options_dialog.get_node("GridContainer/ToSpinBox").value = global.current_project.animation_tags[_tag_id].to
	if !delete_tag_button:
		delete_tag_button = options_dialog.add_button("Delete", true, "delete_tag")
	else:
		delete_tag_button.visible = true


func _on_TagOptions_confirmed() -> void:
	var tag_name : String = options_dialog.get_node("GridContainer/NameLineEdit").text
	var tag_color : Color = options_dialog.get_node("GridContainer/ColorPickerButton").color
	var tag_from : int = options_dialog.get_node("GridContainer/FromSpinBox").value
	var tag_to : int = options_dialog.get_node("GridContainer/ToSpinBox").value

	if tag_to > global.current_project.frames.size():
		tag_to = global.current_project.frames.size()

	if tag_from > tag_to:
		tag_from = tag_to

	var new_animation_tags = global.current_project.animation_tags.duplicate()
	# Loop through the tags to create new classes for them, so that they won't be the same
	# as global.current_project.animation_tags's classes. Needed for undo/redo to work properly.
	for i in new_animation_tags.size():
		new_animation_tags[i] = AnimationTag.new(new_animation_tags[i].name, new_animation_tags[i].color, new_animation_tags[i].from, new_animation_tags[i].to)

	if current_tag_id == global.current_project.animation_tags.size():
		new_animation_tags.append(AnimationTag.new(tag_name, tag_color, tag_from, tag_to))
	else:
		new_animation_tags[current_tag_id].name = tag_name
		new_animation_tags[current_tag_id].color = tag_color
		new_animation_tags[current_tag_id].from = tag_from
		new_animation_tags[current_tag_id].to = tag_to

	# Handle Undo/Redo
	global.current_project.undos += 1
	global.current_project.undo_redo.create_action("Modify Frame Tag")
	global.current_project.undo_redo.add_do_method(global, "general_redo")
	global.current_project.undo_redo.add_undo_method(global, "general_undo")
	global.current_project.undo_redo.add_do_property(global.current_project, "animation_tags", new_animation_tags)
	global.current_project.undo_redo.add_undo_property(global.current_project, "animation_tags", global.current_project.animation_tags)
	global.current_project.undo_redo.commit_action()
	_on_FrameTagDialog_about_to_show()


func _on_TagOptions_custom_action(action : String) -> void:
	if action == "delete_tag":
		var new_animation_tags = global.current_project.animation_tags.duplicate()
		new_animation_tags.remove(current_tag_id)
		# Handle Undo/Redo
		global.current_project.undos += 1
		global.current_project.undo_redo.create_action("Delete Frame Tag")
		global.current_project.undo_redo.add_do_method(global, "general_redo")
		global.current_project.undo_redo.add_undo_method(global, "general_undo")
		global.current_project.undo_redo.add_do_property(global.current_project, "animation_tags", new_animation_tags)
		global.current_project.undo_redo.add_undo_property(global.current_project, "animation_tags", global.current_project.animation_tags)
		global.current_project.undo_redo.commit_action()

		options_dialog.hide()
		_on_FrameTagDialog_about_to_show()


func _on_TagOptions_popup_hide() -> void:
	if delete_tag_button:
		delete_tag_button.visible = false


func _on_PlayOnlyTags_toggled(button_pressed : bool) -> void:
	global.play_only_tags = button_pressed
