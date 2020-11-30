extends Button

const RULER_WIDTH := 16

var font := preload("res://addons/pixelorama/assets/fonts/Roboto-Small.tres")
var major_subdivision := 2
var minor_subdivision := 4

var first : Vector2
var last : Vector2

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

func _ready():
	global = get_node(Constants.NODE_PATH_GLOBAL)
	global.main_viewport.connect("item_rect_changed", self, "update")


# Code taken and modified from Godot's source code
func _draw() -> void:
	var transform := Transform2D()
	var ruler_transform := Transform2D()
	var major_subdivide := Transform2D()
	var minor_subdivide := Transform2D()
	var zoom: float = 1 / global.camera.zoom.x
	transform.x = Vector2(zoom, zoom)

	transform.origin = global.main_viewport.rect_size / 2 + global.camera.offset * -zoom

	var basic_rule := 100.0
	var i := 0
	while(basic_rule * zoom > 100):
		basic_rule /= 5.0 if i % 2 else 2.0
		i += 1
	i = 0
	while(basic_rule * zoom < 100):
		basic_rule *= 2.0 if i % 2 else 5.0
		i += 1

	ruler_transform = ruler_transform.scaled(Vector2(basic_rule, basic_rule))

	major_subdivide = major_subdivide.scaled(Vector2(1.0 / major_subdivision, 1.0 / major_subdivision))
	minor_subdivide = minor_subdivide.scaled(Vector2(1.0 / minor_subdivision, 1.0 / minor_subdivision))

	first = (transform * ruler_transform * major_subdivide * minor_subdivide).affine_inverse().xform(Vector2.ZERO)
	last = (transform * ruler_transform * major_subdivide * minor_subdivide).affine_inverse().xform(global.main_viewport.rect_size)

	for j in range(ceil(first.x), ceil(last.x)):
		var position : Vector2 = (transform * ruler_transform * major_subdivide * minor_subdivide).xform(Vector2(j, 0))
		if j % (major_subdivision * minor_subdivision) == 0:
			draw_line(Vector2(position.x + RULER_WIDTH, 0), Vector2(position.x + RULER_WIDTH, RULER_WIDTH), Color.white)
			var val = (ruler_transform * major_subdivide * minor_subdivide).xform(Vector2(j, 0)).x
			draw_string(font, Vector2(position.x + RULER_WIDTH + 2, font.get_height() - 4), str(int(val)))
		else:
			if j % minor_subdivision == 0:
				draw_line(Vector2(position.x + RULER_WIDTH, RULER_WIDTH * 0.33), Vector2(position.x + RULER_WIDTH, RULER_WIDTH), Color.white)
			else:
				draw_line(Vector2(position.x + RULER_WIDTH, RULER_WIDTH * 0.66), Vector2(position.x + RULER_WIDTH, RULER_WIDTH), Color.white)


func _on_HorizontalRuler_pressed() -> void:
	if !global.show_guides:
		return
	var mouse_pos := get_local_mouse_position()
	if mouse_pos.x < RULER_WIDTH: # For double guides
		global.vertical_ruler._on_VerticalRuler_pressed()
	var guide := Guide.new()
	guide.type = guide.Types.HORIZONTAL
	guide.add_point(Vector2(-19999, global.canvas.current_pixel.y))
	guide.add_point(Vector2(19999, global.canvas.current_pixel.y))
	if guide.points.size() < 2:
		guide.queue_free()
		return
	global.canvas.add_child(guide)
	global.has_focus = false
	update()


func _on_HorizontalRuler_mouse_entered() -> void:
	var mouse_pos := get_local_mouse_position()
	if mouse_pos.x < RULER_WIDTH: # For double guides
		mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
	else:
		mouse_default_cursor_shape = Control.CURSOR_VSPLIT
