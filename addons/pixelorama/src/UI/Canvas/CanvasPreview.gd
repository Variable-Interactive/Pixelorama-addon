tool
extends Node2D


var frame : int = 0
var animation_timer : Timer

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

var has_inited

func _enter_tree():
#	if Engine.is_editor_hint():
	yield(get_tree(), "idle_frame")
	has_inited = true
	animation_timer = $AnimationTimer
	global = get_node(Constants.NODE_PATH_GLOBAL)
	if global.is_getting_edited(self):
		return

func _draw() -> void:
	if not has_inited:
		return
	var current_project : Project = global.current_project
	if frame >= current_project.frames.size():
		frame = current_project.current_frame

	$AnimationTimer.wait_time = current_project.frame_duration[frame] * (1 / global.animation_timeline.fps)

	if animation_timer.is_stopped():
		frame = current_project.current_frame
	var current_cels : Array = current_project.frames[frame].cels

	# Draw current frame layers
	for i in range(current_cels.size()):
		var modulate_color := Color(1, 1, 1, current_cels[i].opacity)
		if i < current_project.layers.size() and current_project.layers[i].visible:
			draw_texture(current_cels[i].image_texture, Vector2.ZERO, modulate_color)


func _on_AnimationTimer_timeout() -> void:
	var current_project : Project = global.current_project
	if frame < current_project.frames.size() - 1:
		frame += 1
	else:
		frame = 0

	$AnimationTimer.set_one_shot(true)
	$AnimationTimer.wait_time = global.current_project.frame_duration[frame] * (1 / global.animation_timeline.fps)
	$AnimationTimer.start()
	update()
