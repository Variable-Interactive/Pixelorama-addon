extends ColorRect


func _ready() -> void:
	rect_size = get_node("/root/Pixelorama").current_project.size
	if get_parent().get_parent() == get_node("/root/Pixelorama").main_viewport:
		get_node("/root/Pixelorama").second_viewport.get_node("Viewport/TransparentChecker")._ready()
		get_node("/root/Pixelorama").small_preview_viewport.get_node("Viewport/TransparentChecker")._ready()
	material.set_shader_param("size", get_node("/root/Pixelorama").checker_size)
	material.set_shader_param("color1", get_node("/root/Pixelorama").checker_color_1)
	material.set_shader_param("color2", get_node("/root/Pixelorama").checker_color_2)
	material.set_shader_param("follow_movement", get_node("/root/Pixelorama").checker_follow_movement)
	material.set_shader_param("follow_scale", get_node("/root/Pixelorama").checker_follow_scale)
	_init_position(get_node("/root/Pixelorama").current_project.tile_mode)


func update_offset(offset : Vector2, scale : Vector2) -> void:
	material.set_shader_param("offset", offset)
	material.set_shader_param("scale", scale)


func _on_TransparentChecker_resized() -> void:
	material.set_shader_param("rect_size", rect_size)


func _init_position(id : int) -> void:
	match id:
		0:
			get_node("/root/Pixelorama").current_project.tile_mode = get_node("/root/Pixelorama").Tile_Mode.NONE
			get_node("/root/Pixelorama").transparent_checker.set_size(get_node("/root/Pixelorama").current_project.size)
			get_node("/root/Pixelorama").transparent_checker.set_position(Vector2.ZERO)
		1:
			get_node("/root/Pixelorama").current_project.tile_mode = get_node("/root/Pixelorama").Tile_Mode.BOTH
			get_node("/root/Pixelorama").transparent_checker.set_size(get_node("/root/Pixelorama").current_project.size*3)
			get_node("/root/Pixelorama").transparent_checker.set_position(-get_node("/root/Pixelorama").current_project.size)
		2:
			get_node("/root/Pixelorama").current_project.tile_mode = get_node("/root/Pixelorama").Tile_Mode.XAXIS
			get_node("/root/Pixelorama").transparent_checker.set_size(Vector2(get_node("/root/Pixelorama").current_project.size.x*3, get_node("/root/Pixelorama").current_project.size.y*1))
			get_node("/root/Pixelorama").transparent_checker.set_position(Vector2(-get_node("/root/Pixelorama").current_project.size.x, 0))
		3:
			get_node("/root/Pixelorama").current_project.tile_mode = get_node("/root/Pixelorama").Tile_Mode.YAXIS
			get_node("/root/Pixelorama").transparent_checker.set_size(Vector2(get_node("/root/Pixelorama").current_project.size.x*1, get_node("/root/Pixelorama").current_project.size.y*3))
			get_node("/root/Pixelorama").transparent_checker.set_position(Vector2(0, -get_node("/root/Pixelorama").current_project.size.y))
