tool
extends Button

var frame := 0
var layer := 0

var popup_menu : PopupMenu
var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

func _enter_tree() -> void:
	popup_menu = $PopupMenu
	global = get_node(Constants.NODE_PATH_GLOBAL)
	if global.is_getting_edited(self):
		return
	hint_tooltip = tr("Frame: %s, Layer: %s") % [frame + 1, layer]
	if global.current_project.frames[frame] in global.current_project.layers[layer].linked_cels:
		get_node("LinkedIndicator").visible = true
		popup_menu.set_item_text(4, "Unlink Cel")
		popup_menu.set_item_metadata(4, "Unlink Cel")
	else:
		get_node("LinkedIndicator").visible = false
		popup_menu.set_item_text(4, "Link Cel")
		popup_menu.set_item_metadata(4, "Link Cel")

	# Reset the checkers size because it assumes you want the same size as the canvas
	var checker = $CelTexture/TransparentChecker
	checker.rect_size = checker.get_parent().rect_size


func _on_CelButton_pressed() -> void:
	if Input.is_action_just_released("left_mouse"):
		global.current_project.current_frame = frame
		global.current_project.current_layer = layer
	elif Input.is_action_just_released("right_mouse"):
		if global.current_project.frames.size() == 1:
			popup_menu.set_item_disabled(0, true)
			popup_menu.set_item_disabled(2, true)
			popup_menu.set_item_disabled(3, true)
		else:
			popup_menu.set_item_disabled(0, false)
			if frame > 0:
				popup_menu.set_item_disabled(2, false)
			if frame < global.current_project.frames.size() - 1:
				popup_menu.set_item_disabled(3, false)
		popup_menu.popup(Rect2(get_global_mouse_position(), Vector2.ONE))
		pressed = !pressed
	elif Input.is_action_just_released("middle_mouse"): # Middle mouse click
		pressed = !pressed
		global.animation_timeline._on_DeleteFrame_pressed(frame)
	else: # An example of this would be Space
		pressed = !pressed


func _on_PopupMenu_id_pressed(ID : int) -> void:
	match ID:
		0: # Remove Frame
			global.animation_timeline._on_DeleteFrame_pressed(frame)
		1: # Clone Frame
			global.animation_timeline._on_CopyFrame_pressed(frame)
		2: # Move Left
			change_frame_order(-1)
		3: # Move Right
			change_frame_order(1)
		4: # Unlink Cel
			var cel_index : int = global.current_project.layers[layer].linked_cels.find(global.current_project.frames[frame])
			var f = global.current_project.frames[frame]
			var new_layers : Array = global.current_project.layers.duplicate()
			# Loop through the array to create new classes for each element, so that they
			# won't be the same as the original array's classes. Needed for undo/redo to work properly.
			for i in new_layers.size():
				var new_linked_cels = new_layers[i].linked_cels.duplicate()
				new_layers[i] = Layer.new(new_layers[i].name, new_layers[i].visible, new_layers[i].locked, new_layers[i].frame_container, new_layers[i].new_cels_linked, new_linked_cels)
			var new_cels : Array = f.cels.duplicate()
			for i in new_cels.size():
				new_cels[i] = Cel.new(new_cels[i].image, new_cels[i].opacity)

			if popup_menu.get_item_metadata(4) == "Unlink Cel":
				new_layers[layer].linked_cels.remove(cel_index)
				var sprite := Image.new()
				sprite.copy_from(global.current_project.frames[frame].cels[layer].image)
				sprite.lock()
				new_cels[layer].image = sprite

				global.current_project.undo_redo.create_action("Unlink Cel")
				global.current_project.undo_redo.add_do_property(global.current_project, "layers", new_layers)
				global.current_project.undo_redo.add_do_property(f, "cels", new_cels)
				global.current_project.undo_redo.add_undo_property(global.current_project, "layers", global.current_project.layers)
				global.current_project.undo_redo.add_undo_property(f, "cels", f.cels)

				global.current_project.undo_redo.add_undo_method(global, "undo")
				global.current_project.undo_redo.add_do_method(global, "redo")
				global.current_project.undo_redo.commit_action()
			elif popup_menu.get_item_metadata(4) == "Link Cel":
				new_layers[layer].linked_cels.append(global.current_project.frames[frame])
				global.current_project.undo_redo.create_action("Link Cel")
				global.current_project.undo_redo.add_do_property(global.current_project, "layers", new_layers)
				if new_layers[layer].linked_cels.size() > 1:
					# If there are already linked cels, set the current cel's image
					# to the first linked cel's image
					new_cels[layer].image = new_layers[layer].linked_cels[0].cels[layer].image
					new_cels[layer].image_texture = new_layers[layer].linked_cels[0].cels[layer].image_texture
					global.current_project.undo_redo.add_do_property(f, "cels", new_cels)
					global.current_project.undo_redo.add_undo_property(f, "cels", f.cels)

				global.current_project.undo_redo.add_undo_property(global.current_project, "layers", global.current_project.layers)
				global.current_project.undo_redo.add_undo_method(global, "undo")
				global.current_project.undo_redo.add_do_method(global, "redo")
				global.current_project.undo_redo.commit_action()
		5: #Frame Properties
				global.frame_properties.popup_centered()
				global.dialog_open(true)
				global.frame_properties.set_frame_label(frame)
				global.frame_properties.set_frame_dur(global.current_project.frame_duration[frame])

func change_frame_order(rate : int) -> void:
	var change = frame + rate
	var frame_duration : Array = global.current_project.frame_duration.duplicate()
	if rate > 0: #There is no function in the class Array in godot to make this quickly and this is the fastest way to swap positions I think of
		frame_duration.insert(change + 1, frame_duration[frame])
		frame_duration.remove(frame)
	else:
		frame_duration.insert(change, frame_duration[frame])
		frame_duration.remove(frame + 1)

	var new_frames : Array = global.current_project.frames.duplicate()
	var temp = new_frames[frame]
	new_frames[frame] = new_frames[change]
	new_frames[change] = temp

	global.current_project.undo_redo.create_action("Change Frame Order")
	global.current_project.undo_redo.add_do_property(global.current_project, "frames", new_frames)
	global.current_project.undo_redo.add_do_property(global.current_project, "frame_duration", frame_duration)

	if global.current_project.current_frame == frame:
		global.current_project.undo_redo.add_do_property(global.current_project, "current_frame", change)
		global.current_project.undo_redo.add_undo_property(global.current_project, "current_frame", global.current_project.current_frame)

	global.current_project.undo_redo.add_undo_property(global.current_project, "frames", global.current_project.frames)
	global.current_project.undo_redo.add_undo_property(global.current_project, "frame_duration", global.current_project.frame_duration)

	global.current_project.undo_redo.add_undo_method(global, "undo")
	global.current_project.undo_redo.add_do_method(global, "redo")
	global.current_project.undo_redo.commit_action()
