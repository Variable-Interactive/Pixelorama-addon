extends BaseButton


var brush := Brushes.Brush.new()

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

func _ready():
	global = get_node(Constants.NODE_PATH_GLOBAL)

func _on_BrushButton_pressed() -> void:
	# Delete the brush on middle mouse press
	if Input.is_action_just_released("middle_mouse"):
		_on_DeleteButton_pressed()
	else:
		global.brushes_popup.select_brush(brush)


func _on_DeleteButton_pressed() -> void:
	if brush.type != Brushes.CUSTOM:
		return

	global.brushes_popup.remove_brush(self)


func _on_BrushButton_mouse_entered() -> void:
	if brush.type == Brushes.CUSTOM:
		$DeleteButton.visible = true


func _on_BrushButton_mouse_exited() -> void:
	if brush.type == Brushes.CUSTOM:
		$DeleteButton.visible = false
