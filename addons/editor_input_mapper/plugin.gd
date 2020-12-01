tool
extends EditorPlugin

var KeyListFix = preload("res://addons/editor_input_mapper/KeyListFix.gd")

var AddTexture = preload("res://addons/editor_input_mapper/add_button.png")
var RemoveTexture = preload("res://addons/editor_input_mapper/remove_button.png")
var EditTexture = preload("res://addons/editor_input_mapper/edit_button.png")

var main_screen_panel : Control

func handles(object):
	print(object)

func has_main_screen():
	return true

func get_plugin_name():
	return "YOU MAKE LAEC"

func get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return get_editor_interface().get_base_control().get_icon("Node", "EditorIcons")

func make_visible(visible):
	if main_screen_panel:
		main_screen_panel.visible = visible


func read_input_event(inputEvent):
	var event = Dictionary()
	if inputEvent is InputEventKey:
		event["type"] = "Key"
		if KeyListFix.get_reverse_key_list().has(inputEvent.get_scancode_with_modifiers()):
			event["scancode"] = KeyListFix.get_reverse_key_list()[inputEvent.get_scancode_with_modifiers()]
		else:
			var key_string
			if KeyListFix.get_reverse_key_list().has(inputEvent["scancode"]):
				key_string = KeyListFix.get_reverse_key_list()[inputEvent["scancode"]]
			else:
				var scancode = inputEvent["scancode"]
				for modifier_key in KeyListFix.get_reverse_modifier_key_list():
					
					if scancode & modifier_key == modifier_key:
						scancode -= modifier_key
				key_string = KeyListFix.get_reverse_key_list()[scancode]
			for modifier_key in KeyListFix.get_reverse_modifier_key_list():
				if inputEvent.get_scancode_with_modifiers() & modifier_key == modifier_key:
					key_string += "+"+KeyListFix.get_reverse_modifier_key_list()[modifier_key]
			event["scancode"] = key_string
	elif inputEvent is InputEventMouseButton:
		event["type"] = "MouseButton"
		event["button_index"] = inputEvent["button_index"]
		event["factor"] = inputEvent["factor"]
		event["device"] = inputEvent["device"]
	elif inputEvent is InputEventJoypadButton:
		event["type"] = "JoypadButton"
		event["button_index"] = inputEvent["button_index"]
		event["device"] = inputEvent["device"]
	elif inputEvent is InputEventJoypadMotion:
		event["type"] = "JoypadMotion"
		event["axis"] = inputEvent["axis"]
		event["device"] = inputEvent["device"]
	else:
		print(inputEvent)
	return event

func _enter_tree():
	main_screen_panel = preload("res://addons/editor_input_mapper/TutorialPanel.tscn").instance()
	main_screen_panel.you_make_laec = self
	# Add the main panel to the editor's main viewport.
	
#	yield(get_tree(), "idle_frame")
	var tree : Tree = main_screen_panel.get_node("VBoxContainer/Tree")
	get_editor_interface().get_editor_viewport().add_child(main_screen_panel)
	make_visible(false)
	var root_item = tree.create_item()
	root_item.set_text(0, "input_map")
	for setting in ProjectSettings.get_property_list():
		
		if setting.name.begins_with("input/"):
			var item = tree.create_item(root_item)
			item.set_text(0, setting.name)
			item.add_button(2, AddTexture)
			var setting_data = ProjectSettings.get_setting(setting.name)
			print(ProjectSettings.get_setting(setting.name))
			for event in setting_data.events:
				
				var readable_event :Dictionary = read_input_event(event)
				if readable_event['type'] == "Key":
					var event_item = tree.create_item(item)
					print(readable_event.scancode)
					event_item.set_text(0, readable_event.scancode)
					event_item.add_button(2, EditTexture)
					event_item.add_button(2, RemoveTexture)
				elif readable_event['type'] == "MouseButton":
					var event_item = tree.create_item(item)
					event_item.set_text(0, 
						("MouseButton: %s" % [readable_event["button_index"]])
					)
					event_item.add_button(2, EditTexture)
					event_item.add_button(2, RemoveTexture)
					
#			for input_event in ProjectSettings.get_setting(setting):
#				var input_item = tree.create_item()
#				input_item.set_text(input_event)
			
	# Hide the main panel. Very much required.

func show_level_tutorial():
	
	pass

func show_item_tutorial():
	
	pass

func new_level_pressed():
	pass

func new_item_pressed():
	pass
#	connect("main_screen_changed", self, "on_main_scene_changed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
