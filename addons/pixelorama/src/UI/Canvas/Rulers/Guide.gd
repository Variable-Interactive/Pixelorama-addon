tool
class_name Guide extends Line2D

enum Types {HORIZONTAL, VERTICAL}

var font := preload("res://addons/pixelorama/assets/fonts/Roboto-Regular.tres")
var has_focus := true
var mouse_pos := Vector2.ZERO
var type = Types.HORIZONTAL
var project
var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

var has_inited = false

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		yield(get_tree(), "idle_frame")
	has_inited = true
	global = get_node(Constants.NODE_PATH_GLOBAL)
	if global.is_getting_edited(self):
		return
	project = global.current_project
	width = global.camera.scale.x
	default_color = global.guide_color
	project.guides.append(self)


func _input(_event : InputEvent):
	if not has_inited:
		return
	print(_event)
	mouse_pos = get_local_mouse_position()
	if points.size() < 2:
		return
	var point0 := points[0]
	var point1 := points[1]
	if type == Types.HORIZONTAL:
		point0.y -= width * 3
		point1.y += width * 3
	else:
		point0.x -= width * 3
		point1.x += width * 3
	if global.can_draw and global.has_focus and point_in_rectangle(mouse_pos, point0, point1) and Input.is_action_just_pressed("left_mouse") and visible:
		if !point_in_rectangle(global.canvas.current_pixel, global.canvas.location, global.canvas.location + project.size):
			has_focus = true
			global.has_focus = false
			update()
	if has_focus and visible:
		if Input.is_action_pressed("left_mouse"):
			if type == Types.HORIZONTAL:
				var yy = stepify(mouse_pos.y, 0.5)
				points[0].y = yy
				points[1].y = yy
			else:
				var xx = stepify(mouse_pos.x, 0.5)
				points[0].x = xx
				points[1].x = xx
		if Input.is_action_just_released("left_mouse"):
			global.has_focus = true
			has_focus = false
			if !outside_canvas():
				update()


func _draw() -> void:
	if not has_inited:
		return
	if has_focus:
		var viewport_size: Vector2 = global.main_viewport.rect_size
		var zoom: Vector2 = global.camera.zoom
		if type == Types.HORIZONTAL:
			draw_set_transform(Vector2(global.camera.offset.x - (viewport_size.x / 2) * zoom.x, points[0].y + font.get_height() * zoom.x * 2), rotation, zoom * 2)
			draw_string(font, Vector2.ZERO, "%spx" % str(stepify(mouse_pos.y, 0.5)))
		else:
			draw_set_transform(Vector2(points[0].x + font.get_height() * zoom.y, global.camera.offset.y - (viewport_size.y / 2.25) * zoom.y), rotation, zoom * 2)
			draw_string(font, Vector2.ZERO, "%spx" % str(stepify(mouse_pos.x, 0.5)))


func outside_canvas() -> bool:
	if type == Types.HORIZONTAL:
		if points[0].y < 0 || points[0].y > project.size.y:
			project.guides.erase(self)
			queue_free()
			return true
	else:
		if points[0].x < 0 || points[0].x > project.size.x:
			project.guides.erase(self)
			queue_free()
			return true
	return false


func point_in_rectangle(p : Vector2, coord1 : Vector2, coord2 : Vector2) -> bool:
	return p.x > coord1.x && p.y > coord1.y && p.x < coord2.x && p.y < coord2.y
