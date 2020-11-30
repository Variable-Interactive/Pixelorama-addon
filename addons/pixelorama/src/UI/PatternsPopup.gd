extends PopupPanel
class_name Patterns


class Pattern:
	var image : Image
	var index : int

signal pattern_selected(pattern)

var default_pattern : Pattern = null


func select_pattern(pattern : Pattern) -> void:
	emit_signal("pattern_selected", pattern)
	hide()


static func create_button(image : Image) -> Node:
	var button : BaseButton = load("res://addons/pixelorama/src/UI/PatternButton.tscn").instance()
	var tex := ImageTexture.new()
	tex.create_from_image(image, 0)
	button.get_child(0).texture = tex
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return button


static func add(patterns_popup, image : Image, hint := "") -> void:
	var button = create_button(image)
	button.pattern.image = image
	button.hint_tooltip = hint
	var container = patterns_popup.get_node("ScrollContainer/PatternContainer")
	container.add_child(button)
	button.pattern.index = button.get_index()

	if patterns_popup.default_pattern == null:
		patterns_popup.default_pattern = button.pattern


func get_pattern(index : int) -> Pattern:
	var container = get_node("/root/Pixelorama").patterns_popup.get_node("ScrollContainer/PatternContainer")
	var pattern = default_pattern
	if index < container.get_child_count():
		pattern = container.get_child(index).pattern
	return pattern
