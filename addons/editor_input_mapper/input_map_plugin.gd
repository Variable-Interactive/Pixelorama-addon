tool
extends Node

#bool action_has_event(action: String, event: InputEvent)
#void action_set_deadzone(action: String, deadzone: float)
#void erase_action(action: String)
#bool event_is_action(event: InputEvent, action: String)
#bool has_action(action: String) 
#void load_from_globals()

export(Array) var actions setget ,get_actions



func action_erase_event(action: String, event: InputEvent):
	var action_index = find_action_by_name(action)
	if action_index == -1:
		print("There is no action named %s." % [action])
		return
	if actions[action_index].events.find(event) == -1:
		print("There is no action event similar to %s." % [event])
		return
	actions[action_index].events.erase(event)
		
func action_erase_events(action: String):
	var action_index = find_action_by_name(action)
	if action_index == -1:
		print("There is no action named %s." % [action])
		return
	actions[action_index].events = []

func action_add_event(action: String, event: InputEvent):
	var action_index = find_action_by_name(action)
	if action_index == -1:
		print("There is no action named %s." % [action])
		return
	actions[action_index].events.push_back(event)
	
func action_set_events(action: String, events: Array):
	var action_index = find_action_by_name(action)
	if action_index == -1:
		print("There is no action named %s." % [action])
		return
	actions[action_index].events = events
	

func find_action_by_name(action : String):
	var i = 0
	for a in actions:
		if a.name == action:
			return i
		i += 1
	return -1

func get_action_list(action :String) -> Array:
	if find_action_by_name(action) != -1:
		return actions[find_action_by_name(action)].events
	return []

func add_action(action: String, deadzone: float = 0.5) -> void:
	var event_action := Dictionary()
	event_action.name = action
	event_action.deadzone = deadzone
	event_action.events = Array()
	if find_action_by_name(action) == -1:
		actions.push_back(event_action)
	else:
		print("[InputMapPlugin]: This action has already been added.")

func get_raw_actions() -> Array:
	return actions

func get_actions() -> Array:
	var action_names = []
	for action in actions:
		action_names.push_back(action.name)
	return action_names

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	print("#################################################################")
	print(InputMap.get_actions())
	for action in InputMap.get_actions():
		add_action(action, 0.5)
		action_set_events(action, InputMap.get_action_list(action))
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
