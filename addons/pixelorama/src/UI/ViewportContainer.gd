tool
extends ViewportContainer

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var has_inited = false

var global

func _enter_tree():
	yield(get_tree(),"idle_frame")
	global = get_node(Constants.NODE_PATH_GLOBAL)
	if global.is_getting_edited(self):
		return
	has_inited = true

func _on_ViewportContainer_mouse_entered() -> void:
	if not has_inited:
		return
	global.has_focus = true


func _on_ViewportContainer_mouse_exited() -> void:
	if not has_inited:
		return
	global.has_focus = false
