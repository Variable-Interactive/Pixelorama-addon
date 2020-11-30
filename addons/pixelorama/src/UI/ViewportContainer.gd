extends ViewportContainer

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

func _ready():
	global = get_node(Constants.NODE_PATH_GLOBAL)

func _on_ViewportContainer_mouse_entered() -> void:
	global.has_focus = true


func _on_ViewportContainer_mouse_exited() -> void:
	global.has_focus = false
