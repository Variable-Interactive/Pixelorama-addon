tool
extends Node2D

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

var has_inited = false

func _enter_tree():
	yield(get_tree(),"idle_frame")
	global = get_node(Constants.NODE_PATH_GLOBAL)
	if global.is_getting_edited(self):
		return
	has_inited = true

func _input(event : InputEvent) -> void:
	if not has_inited:
		return
	if global.has_focus and event is InputEventMouseMotion:
		update()


func _draw() -> void:
	if not has_inited:
		return
	# Draw rectangle to indicate the pixel currently being hovered on
	if global.has_focus and global.can_draw:
		global.get_tools().draw_indicator()
