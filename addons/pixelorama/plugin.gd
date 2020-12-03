tool
extends EditorPlugin

var KeyListFix = preload("res://addons/editor_input_mapper/KeyListFix.gd")

var AddTexture = preload("res://addons/editor_input_mapper/add_button.png")
var RemoveTexture = preload("res://addons/editor_input_mapper/remove_button.png")
var EditTexture = preload("res://addons/editor_input_mapper/edit_button.png")

var InputEventEditor = preload("res://addons/editor_input_mapper/InputEventEditor.tscn")

var main_screen_panel : Control

#func forward_canvas_gui_input(event):
#	print(event)
#	var consumed = false
##	on_canvas_editor_input(event)
#	return consumed

func handles(object):
	if main_screen_panel.visible:
		return true
	return false

func has_main_screen():
	return true

func get_plugin_name():
	return "Pixelorama"

func get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return get_editor_interface().get_base_control().get_icon("Node", "EditorIcons")

func make_visible(visible):
	if main_screen_panel:
		main_screen_panel.visible = visible



var PixeloramaMain = preload("res://addons/pixelorama/src/Main.tscn")

var PixeloramaSingleton = preload("res://addons/pixelorama/src/Autoload/Global.tscn")

var pixelorama_singleton

func _enter_tree():
	print("editor frame")
	yield(get_tree(), "idle_frame")
	if Engine.is_editor_hint():
		for setting in ProjectSettings.get_property_list():
			if setting.name.begins_with("input/"):
				var action_name = setting.name.substr(6)
#				print(action_name)
				InputMap.add_action(action_name)
				var action = ProjectSettings.get(setting.name)
				for event  in action.events:
					InputMap.action_add_event(action_name, event)
	print("post editor frame")
	main_screen_panel = PixeloramaMain.instance()
	print("adding main")
	get_editor_interface().get_editor_viewport().add_child(main_screen_panel)
	print("adding singleton")
#	pixelorama_singleton = PixeloramaSingleton.instance()
#	get_tree().get_root().add_child(pixelorama_singleton)
##
##	yield(get_tree(), "idle_frame")
#
#	yield(get_tree(), "idle_frame")
#	main_screen_panel.custom_init()
	make_visible(false)
	print("main inited")
#
func _exit_tree():
	main_screen_panel.queue_free()
	if has_node("/root/Pixelorama"):
		get_node("/root/Pixelorama").queue_free()
