extends BaseButton


var pattern := Patterns.Pattern.new()


func _on_PatternButton_pressed() -> void:
	get_node(Constants.NODE_PATH_GLOBAL).patterns_popup.select_pattern(pattern)
