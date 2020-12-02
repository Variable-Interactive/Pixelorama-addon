tool
extends Node2D


var location := Vector2.ZERO
var isometric_polylines := [] # An array of PoolVector2Arrays

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

var has_inited = false

func _enter_tree():
	yield(get_tree(),"idle_frame")
	global = get_node(Constants.NODE_PATH_GLOBAL)
	if global.is_getting_edited(self):
		return
	has_inited = true

func _draw() -> void:
	if not has_inited:
		return
	if global.draw_grid:
		draw_grid(global.grid_type)


func draw_grid(grid_type : int) -> void:
	var size : Vector2 = global.transparent_checker.rect_size
	if grid_type == global.Grid_Types.CARTESIAN || grid_type == global.Grid_Types.ALL:
		for x in range(global.grid_width, size.x, global.grid_width):
			draw_line(Vector2(x, location.y), Vector2(x, size.y), global.grid_color, true)

		for y in range(global.grid_height, size.y, global.grid_height):
			draw_line(Vector2(location.x, y), Vector2(size.x, y), global.grid_color, true)

	if grid_type == global.Grid_Types.ISOMETRIC || grid_type == global.Grid_Types.ALL:
		var i := 0
		for x in range(global.grid_isometric_cell_size, size.x + 2, global.grid_isometric_cell_size * 2):
			for y in range(0, size.y + 1, global.grid_isometric_cell_size):
				draw_isometric_tile(i, Vector2(x, y))
				i += 1


func draw_isometric_tile(i : int, origin := Vector2.RIGHT, cell_size : int = global.grid_isometric_cell_size) -> void:
	# A random value I found by trial and error, I have no idea why it "works"
	var diff = 1.11754
	var approx_30_degrees = deg2rad(26.565)

	var pool := PoolVector2Array()
	if i < isometric_polylines.size():
		pool = isometric_polylines[i]
	else:
		var a = origin - Vector2(0, 0.5)
		var b = a + Vector2(cos(approx_30_degrees), sin(approx_30_degrees)) * cell_size * diff
		var c = a + Vector2.DOWN * cell_size
		var d = c - Vector2(cos(approx_30_degrees), sin(approx_30_degrees)) * cell_size * diff
		pool.append(a)
		pool.append(b)
		pool.append(c)
		pool.append(d)
		pool.append(a)
		isometric_polylines.append(pool)

	if pool.size() > 2:
		draw_polyline(pool, global.grid_color)
