tool
extends PanelContainer


var canvas_preview
var camera : CanvasLayer
var play_button : Button

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

func _enter_tree():
	canvas_preview = $HBoxContainer/PreviewViewportContainer/Viewport/CameraPreview/CanvasPreview
	camera = $HBoxContainer/PreviewViewportContainer/Viewport/CameraPreview
	play_button = $HBoxContainer/VBoxContainer/PlayButton
	global = get_node(Constants.NODE_PATH_GLOBAL)

func _on_PreviewZoomSlider_value_changed(value : float) -> void:
	camera.scale = -Vector2(value, value)
	camera.save_values_to_project()
	camera.update_transparent_checker_offset()


func _on_PlayButton_toggled(button_pressed : bool) -> void:
	if button_pressed:
		if global.current_project.frames.size() <= 1:
			play_button.pressed = false
			return
		canvas_preview.animation_timer.start()
		global.change_button_texturerect(play_button.get_child(0), "pause.png")
	else:
		canvas_preview.animation_timer.stop()
		global.change_button_texturerect(play_button.get_child(0), "play.png")
