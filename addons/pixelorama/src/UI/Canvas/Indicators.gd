tool
extends Node2D

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

func _enter_tree():
	global = get_node(Constants.NODE_PATH_GLOBAL)

func _input(event : InputEvent) -> void:
	if global.has_focus and event is InputEventMouseMotion:
		update()


func _draw() -> void:
	# Draw rectangle to indicate the pixel currently being hovered on
	if global.has_focus and global.can_draw:
		global.get_tools().draw_indicator()
