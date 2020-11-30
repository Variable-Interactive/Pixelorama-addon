extends TextureButton


var setting_name : String
var value_type : String
var default_value
var node : Node


func _ready() -> void:
	# Handle themes
	if get_node("/root/Pixelorama").theme_type == get_node("/root/Pixelorama").Theme_Types.LIGHT:
		texture_normal = load("res://addons/pixelorama/assets/graphics/light_themes/misc/icon_reload.png")
	elif get_node("/root/Pixelorama").theme_type == get_node("/root/Pixelorama").Theme_Types.CARAMEL:
		texture_normal = load("res://addons/pixelorama/assets/graphics/caramel_themes/misc/icon_reload.png")


func _on_RestoreDefaultButton_pressed() -> void:
	get_node("/root/Pixelorama").set(setting_name, default_value)
	get_node("/root/Pixelorama").config_cache.set_value("preferences", setting_name, default_value)
	get_node("/root/Pixelorama").preferences_dialog.preference_update(setting_name)
	get_node("/root/Pixelorama").preferences_dialog.disable_restore_default_button(self, true)
	node.set(value_type, default_value)
