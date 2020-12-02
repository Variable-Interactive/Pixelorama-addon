tool
extends ColorRect

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

func process_enter_tree():
	global = get_node("/root/Pixelorama")
	if not global:
		yield(get_tree(), "idle_frame")
		global = get_node("/root/Pixelorama")
	if not global.current_project:
		return
	rect_size = global.current_project.size
	if get_parent().get_parent().get_parent() == global.main_viewport:
		global.second_viewport.get_node("Viewport/Camera2D2/TransparentChecker")._enter_tree()
		global.small_preview_viewport.get_node("Viewport/CameraPreview/TransparentChecker")._enter_tree()
	material.set_shader_param("size", global.checker_size)
	material.set_shader_param("color1", global.checker_color_1)
	material.set_shader_param("color2", global.checker_color_2)
	material.set_shader_param("follow_movement", global.checker_follow_movement)
	material.set_shader_param("follow_scale", global.checker_follow_scale)
	_init_position(global.current_project.tile_mode)
	


func _enter_tree():
#	yield(get_tree(),"idle_frame")
	if not is_inside_tree():
		call_deferred("_enter_tree")
		return
	call_deferred("process_enter_tree")

func update_offset(offset : Vector2, scale : Vector2) -> void:
	material.set_shader_param("offset", offset)
	material.set_shader_param("scale", scale)


func _on_TransparentChecker_resized() -> void:
	material.set_shader_param("rect_size", rect_size)


func _init_position(id : int) -> void:
	match id:
		0:
			global.current_project.tile_mode = global.Tile_Mode.NONE
			global.transparent_checker.set_size(global.current_project.size)
			global.transparent_checker.set_position(Vector2.ZERO)
		1:
			global.current_project.tile_mode = global.Tile_Mode.BOTH
			global.transparent_checker.set_size(global.current_project.size*3)
			global.transparent_checker.set_position(-global.current_project.size)
		2:
			global.current_project.tile_mode = global.Tile_Mode.XAXIS
			global.transparent_checker.set_size(Vector2(global.current_project.size.x*3, global.current_project.size.y*1))
			global.transparent_checker.set_position(Vector2(-global.current_project.size.x, 0))
		3:
			global.current_project.tile_mode = global.Tile_Mode.YAXIS
			global.transparent_checker.set_size(Vector2(global.current_project.size.x*1, global.current_project.size.y*3))
			global.transparent_checker.set_position(Vector2(0, -global.current_project.size.y))
	if get_parent().name == "CelTexture":
		self.margin_bottom = 0
		self.margin_top = 0
		self.margin_left = 0
		self.margin_right = 0
