tool
extends TextureButton


var setting_name : String
var value_type : String
var default_value
var node : Node

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

func _enter_tree():
	global = get_node(Constants.NODE_PATH_GLOBAL)
	# Handle themes
	if global.theme_type == global.Theme_Types.LIGHT:
		texture_normal = load("res://addons/pixelorama/assets/graphics/light_themes/misc/icon_reload.png")
	elif global.theme_type == global.Theme_Types.CARAMEL:
		texture_normal = load("res://addons/pixelorama/assets/graphics/caramel_themes/misc/icon_reload.png")


func _on_RestoreDefaultButton_pressed() -> void:
	global.set(setting_name, default_value)
	global.config_cache.set_value("preferences", setting_name, default_value)
	global.preferences_dialog.preference_update(setting_name)
	global.preferences_dialog.disable_restore_default_button(self, true)
	node.set(value_type, default_value)
