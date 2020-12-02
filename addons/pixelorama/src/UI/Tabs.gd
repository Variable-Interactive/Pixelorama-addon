tool
extends Tabs

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

func _enter_tree():
	global = get_node(Constants.NODE_PATH_GLOBAL)
	if global.is_getting_edited(self):
		return

func _on_Tabs_tab_changed(tab : int) -> void:
	global.current_project_index = tab


func _on_Tabs_tab_close(tab : int) -> void:
	if global.projects.size() == 1 or global.current_project_index != tab:
		return

	if global.current_project.has_changed:
		if !global.unsaved_changes_dialog.is_connected("confirmed", self, "delete_tab"):
			global.unsaved_changes_dialog.connect("confirmed", self, "delete_tab", [tab])
		global.unsaved_changes_dialog.popup_centered()
		global.dialog_open(true)
	else:
		delete_tab(tab)


func _on_Tabs_reposition_active_tab_request(idx_to : int) -> void:
	var temp = global.projects[global.current_project_index]
	global.projects.erase(temp)
	global.projects.insert(idx_to, temp)

	# Change save paths
	var temp_save_path = global.get_open_save().current_save_paths[global.current_project_index]
	global.get_open_save().current_save_paths[global.current_project_index] = global.get_open_save().current_save_paths[idx_to]
	global.get_open_save().current_save_paths[idx_to] = temp_save_path
	var temp_backup_path = global.get_open_save().backup_save_paths[global.current_project_index]
	global.get_open_save().backup_save_paths[global.current_project_index] = global.get_open_save().backup_save_paths[idx_to]
	global.get_open_save().backup_save_paths[idx_to] = temp_backup_path


func delete_tab(tab : int) -> void:
	remove_tab(tab)
	global.projects[tab].undo_redo.free()
	global.get_open_save().remove_backup(tab)
	global.get_open_save().current_save_paths.remove(tab)
	global.get_open_save().backup_save_paths.remove(tab)
	global.projects.remove(tab)
	if tab > 0:
		global.current_project_index -= 1
	else:
		global.current_project_index = 0
	if global.unsaved_changes_dialog.is_connected("confirmed", self, "delete_tab"):
		global.unsaved_changes_dialog.disconnect("confirmed", self, "delete_tab")
