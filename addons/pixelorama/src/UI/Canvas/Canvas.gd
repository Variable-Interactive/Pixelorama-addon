class_name Canvas
extends Node2D


var location := Vector2.ZERO
var fill_color := Color(0, 0, 0, 0)
var current_pixel := Vector2.ZERO
var can_undo := true
var cursor_image_has_changed := false
var sprite_changed_this_frame := false # for optimization purposes

onready var grid = $Grid
onready var tile_mode = $TileMode
onready var indicators = $Indicators

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global = get_node(Constants.NODE_PATH_GLOBAL)
	var frame : Frame = new_empty_frame(true)
	global.current_project.frames.append(frame)
	yield(get_tree().create_timer(0.2), "timeout")
	camera_zoom()


func _draw() -> void:
	global.second_viewport.get_child(0).get_node("CanvasPreview").update()
	global.small_preview_viewport.get_child(0).get_node("CanvasPreview").update()

	var current_cels : Array = global.current_project.frames[global.current_project.current_frame].cels

	var _position := position
	var _scale := scale
	if global.mirror_view:
		_position.x = _position.x + global.current_project.size.x
		_scale.x = -1
	draw_set_transform(_position, rotation, _scale)
	# Draw current frame layers
	for i in range(global.current_project.layers.size()):
		var modulate_color := Color(1, 1, 1, current_cels[i].opacity)
		if global.current_project.layers[i].visible: # if it's visible
			draw_texture(current_cels[i].image_texture, location, modulate_color)

	if global.onion_skinning:
		onion_skinning()
	tile_mode.update()
	draw_set_transform(position, rotation, scale)


func _input(event : InputEvent) -> void:
	# Don't process anything below if the input isn't a mouse event, or Shift/Ctrl.
	# This decreases CPU/GPU usage slightly.
	if not event is InputEventMouse:
		if not event is InputEventKey:
			return
		elif not event.scancode in [KEY_SHIFT, KEY_CONTROL]:
			return
#	elif not get_viewport_rect().has_point(event.position):
#		return

	# Do not use self.get_local_mouse_position() because it return unexpected
	# value when shrink parameter is not equal to one. At godot version 3.2.3
	var tmp_transform = get_canvas_transform().affine_inverse()
	var tmp_position = global.main_viewport.get_local_mouse_position()
	current_pixel = tmp_transform.basis_xform(tmp_position) + tmp_transform.origin + location

	if global.has_focus:
		update()

	sprite_changed_this_frame = false

	var current_project : Project = global.current_project

	if global.has_focus:
		if !cursor_image_has_changed:
			cursor_image_has_changed = true
			if global.show_left_tool_icon:
				global.left_cursor.visible = true
			if global.show_right_tool_icon:
				global.right_cursor.visible = true
	else:
		if cursor_image_has_changed:
			cursor_image_has_changed = false
			global.left_cursor.visible = false
			global.right_cursor.visible = false

	global.get_tools().handle_draw(current_pixel.floor(), event)

	if sprite_changed_this_frame:
		update_texture(current_project.current_layer)


func camera_zoom() -> void:
	# Set camera zoom based on the sprite size
	var bigger_canvas_axis = max(global.current_project.size.x, global.current_project.size.y)
	var zoom_max := Vector2(bigger_canvas_axis, bigger_canvas_axis) * 0.01
	var cameras = [global.camera, global.camera2, global.camera_preview]
	for camera in cameras:
		if zoom_max > Vector2.ONE:
			camera.zoom_max = zoom_max
		else:
			camera.zoom_max = Vector2.ONE

		if camera == global.camera_preview:
			global.preview_zoom_slider.max_value = -camera.zoom_min.x
			global.preview_zoom_slider.min_value = -camera.zoom_max.x

		camera.fit_to_frame(global.current_project.size)
		camera.save_values_to_project()

	global.transparent_checker._ready() # To update the rect size


func new_empty_frame(first_time := false, single_layer := false, size := global.current_project.size) -> Frame:
	var frame := Frame.new()
	for l in global.current_project.layers: # Create as many cels as there are layers
		# The sprite itself
		var sprite := Image.new()
		if first_time:
			if global.config_cache.has_section_key("preferences", "default_image_width"):
				global.current_project.size.x = global.config_cache.get_value("preferences", "default_image_width")
			if global.config_cache.has_section_key("preferences", "default_image_height"):
				global.current_project.size.y = global.config_cache.get_value("preferences", "default_image_height")
			if global.config_cache.has_section_key("preferences", "default_fill_color"):
				fill_color = global.config_cache.get_value("preferences", "default_fill_color")
		sprite.create(size.x, size.y, false, Image.FORMAT_RGBA8)
		sprite.fill(fill_color)
		sprite.lock()
		frame.cels.append(Cel.new(sprite, 1))

		if single_layer:
			break

	return frame


func handle_undo(action : String, project : Project = global.current_project, layer_index := -2, frame_index := -2) -> void:
	if !can_undo:
		return

	if layer_index <= -2:
		layer_index = project.current_layer
	if frame_index <= -2:
		frame_index = project.current_frame

	var cels := []
	var frames := []
	var layers := []
	if frame_index == -1:
		frames = project.frames
	else:
		frames.append(project.frames[frame_index])

	if layer_index == -1:
		layers = project.layers
	else:
		layers.append(project.layers[layer_index])

	for f in frames:
		for l in layers:
			var index = project.layers.find(l)
			cels.append(f.cels[index])

	project.undos += 1
	project.undo_redo.create_action(action)
	for cel in cels:
		# If we don't unlock the image, it doesn't work properly
		cel.image.unlock()
		var data = cel.image.data
		cel.image.lock()
		project.undo_redo.add_undo_property(cel.image, "data", data)
	project.undo_redo.add_undo_method(global,
			 "undo", frame_index, layer_index, project)

	can_undo = false


func handle_redo(_action : String, project : Project = global.current_project, layer_index := -2, frame_index := -2) -> void:
	can_undo = true
	if project.undos < project.undo_redo.get_version():
		return

	if layer_index <= -2:
		layer_index = project.current_layer
	if frame_index <= -2:
		frame_index = project.current_frame

	var cels := []
	var frames := []
	var layers := []
	if frame_index == -1:
		frames = project.frames
	else:
		frames.append(project.frames[frame_index])

	if layer_index == -1:
		layers = project.layers
	else:
		layers.append(project.layers[layer_index])

	for f in frames:
		for l in layers:
			var index = project.layers.find(l)
			cels.append(f.cels[index])

	for cel in cels:
		project.undo_redo.add_do_property(cel.image, "data", cel.image.data)
	project.undo_redo.add_do_method(global,
			 "redo", frame_index, layer_index, project)
	project.undo_redo.commit_action()


func update_texture(layer_index : int, frame_index := -1, project : Project = global.current_project) -> void:
	if frame_index == -1:
		frame_index = project.current_frame
	var current_cel : Cel = project.frames[frame_index].cels[layer_index]
	current_cel.image_texture.create_from_image(current_cel.image, 0)

	if project == global.current_project:
		var frame_texture_rect : TextureRect
		frame_texture_rect = global.find_node_by_name(project.layers[layer_index].frame_container.get_child(frame_index), "CelTexture")
		frame_texture_rect.texture = current_cel.image_texture


func onion_skinning() -> void:
	# Past
	if global.onion_skinning_past_rate > 0:
		var color : Color
		if global.onion_skinning_blue_red:
			color = Color.blue
		else:
			color = Color.white
		for i in range(1, global.onion_skinning_past_rate + 1):
			if global.current_project.current_frame >= i:
				var layer_i := 0
				for layer in global.current_project.frames[global.current_project.current_frame - i].cels:
					if global.current_project.layers[layer_i].visible:
						color.a = 0.6 / i
						draw_texture(layer.image_texture, location, color)
					layer_i += 1

	# Future
	if global.onion_skinning_future_rate > 0:
		var color : Color
		if global.onion_skinning_blue_red:
			color = Color.red
		else:
			color = Color.white
		for i in range(1, global.onion_skinning_future_rate + 1):
			if global.current_project.current_frame < global.current_project.frames.size() - i:
				var layer_i := 0
				for layer in global.current_project.frames[global.current_project.current_frame + i].cels:
					if global.current_project.layers[layer_i].visible:
						color.a = 0.6 / i
						draw_texture(layer.image_texture, location, color)
					layer_i += 1
