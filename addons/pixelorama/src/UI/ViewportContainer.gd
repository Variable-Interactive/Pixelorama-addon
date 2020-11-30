extends ViewportContainer


func _on_ViewportContainer_mouse_entered() -> void:
	get_node("/root/Pixelorama").has_focus = true


func _on_ViewportContainer_mouse_exited() -> void:
	get_node("/root/Pixelorama").has_focus = false
