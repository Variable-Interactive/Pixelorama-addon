tool
extends EditorPlugin

var KeyListFix = preload("res://addons/editor_input_mapper/KeyListFix.gd")

var AddTexture = preload("res://addons/editor_input_mapper/add_button.png")
var RemoveTexture = preload("res://addons/editor_input_mapper/remove_button.png")
var EditTexture = preload("res://addons/editor_input_mapper/edit_button.png")

var InputEventEditor = preload("res://addons/editor_input_mapper/InputEventEditor.tscn")

var main_screen_panel : Control

func forward_canvas_gui_input(event):
	print(event)
	var consumed = false
#	on_canvas_editor_input(event)
	return consumed

func handles(object):
	if input_event_editor:
		return true
	return false

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

var tree : Tree
var EditorInputMap = preload("res://addons/editor_input_mapper/InputMapPlugin.tscn")
var editor_input_map

func _enter_tree():
	editor_input_map = EditorInputMap.instance()

	
#	get_tree().get_root().call_deferred("add_child", editor_input_map)
	main_screen_panel = preload("res://addons/editor_input_mapper/TutorialPanel.tscn").instance()
	main_screen_panel.you_make_laec = self
	# Add the main panel to the editor's main viewport.
	
#	yield(get_tree(), "idle_frame")
	tree = main_screen_panel.get_node("VBoxContainer/Tree")
	get_editor_interface().get_editor_viewport().add_child(main_screen_panel)
	make_visible(false)
	var root_item = tree.create_item()
	root_item.set_text(0, "input_map")
	for setting in ProjectSettings.get_property_list():
		
		if setting.name.begins_with("input/"):
			var item :TreeItem = tree.create_item(root_item)
			item.set_text(0, setting.name)
			item.add_button(2, AddTexture)
			item.set_metadata(0, setting.name)
			var setting_data = ProjectSettings.get_setting(setting.name)
#			print(ProjectSettings.get_setting(setting.name))
			for event in setting_data.events:
				
				var readable_event :Dictionary = read_input_event(event)
				if readable_event['type'] == "Key":
					var event_item = tree.create_item(item)
#					print(readable_event.scancode)
					event_item.set_text(0, readable_event.scancode)
					event_item.add_button(2, EditTexture)
					event_item.add_button(2, RemoveTexture)
					event_item.set_metadata(0, event)
				elif readable_event['type'] == "MouseButton":
					var event_item = tree.create_item(item)
					event_item.set_text(0, 
						("MouseButton: %s" % [readable_event["button_index"]])
					)
					event_item.add_button(2, EditTexture)
					event_item.add_button(2, RemoveTexture)
					event_item.set_metadata(0, event)
	tree.connect("button_pressed", self, "on_button_pressed")
	
#			for input_event in ProjectSettings.get_setting(setting):
#				var input_item = tree.create_item()
#				input_item.set_text(input_event)
			
	# Hide the main panel. Very much required.

var input_event_editor
var texture_progress

var edited_input_event_item

func on_button_pressed(item: TreeItem, column: int, id: int):
#	print("Item: %s" % [item])
#	print("Column: %s" % [column])
#	print("Id: %s" % [id])
#	print(item.get_metadata(0))
	if item.get_metadata(0) is String and id == 0:
		print("Clicked on add InputEvent to %s" % [item.get_metadata(0)])
	elif item.get_metadata(0) is InputEvent:
		match id:
			0:
				input_event_editor = InputEventEditor.instance()
				print("Clicked on edit InputEvent %s" % [item.get_metadata(0)])
				main_screen_panel.add_child(input_event_editor)
				var bg = input_event_editor.get_node("CenterContainer")
				var input_box = bg.get_node("VBoxContainer")
				bg.connect("gui_input", self, "on_dark_panel_input")
				input_box.connect("gui_input", self, "on_input_box_input")
				texture_progress = input_box.get_node("TextureProgress")
				edited_input_event_item = item
				
			1:
				print("Clicked on remove InputEvent %s" % [item.get_metadata(0)])


func on_dark_panel_input(event):
	
	if event is InputEventMouseButton:
		print(event.button_index)
		if event.button_index == 1:
			input_event_editor.queue_free()

const MAX_CHARGE_TIME = 2.0

var charge_time = 0.0
var last_event
var was_events_similar
var last_tick

func on_input_box_input(event):
	var are_events_similar = false
	var re = read_input_event(event) # readable_event
	var last_re = read_input_event(last_event)
	if re.has("type") and last_re.has('type'):
		if re['type'] == 'Key' and last_re['type'] == 'Key':
			if re.scancode == last_re.scancode:
				are_events_similar = true
		if re['type'] == 'MouseButton' and last_re['type'] == 'MouseButton':
			if re.button_index == last_re.button_index:
				are_events_similar = true
		if not was_events_similar and are_events_similar:
			charge_time = 0.0
		
		if was_events_similar and are_events_similar:
			print(event.is_pressed())
			if event.is_pressed():
				charge_time += (OS.get_ticks_msec() - last_tick) / 1000.0
			else:
				charge_time = 0.0
		texture_progress.value = charge_time / MAX_CHARGE_TIME * 100.0
		if event is InputEventMouseButton:
			print(read_input_event(event))
		elif event is InputEventKey:
			print(read_input_event(event))
		print(charge_time)
		if (charge_time > MAX_CHARGE_TIME) and (event is InputEventKey):
			print(edited_input_event_item)
			edited_input_event_item.set_text(0, re['scancode'])
			edited_input_event_item.set_metadata(0, event)
			input_event_editor.queue_free()
	else: 
		was_events_similar = false
	was_events_similar = are_events_similar
	last_event = event
	last_tick = OS.get_ticks_msec()

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
