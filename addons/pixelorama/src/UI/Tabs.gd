extends Tabs


func _on_Tabs_tab_changed(tab : int) -> void:
	get_node("/root/Pixelorama").current_project_index = tab


func _on_Tabs_tab_close(tab : int) -> void:
	if get_node("/root/Pixelorama").projects.size() == 1 or get_node("/root/Pixelorama").current_project_index != tab:
		return

	if get_node("/root/Pixelorama").current_project.has_changed:
		if !get_node("/root/Pixelorama").unsaved_changes_dialog.is_connected("confirmed", self, "delete_tab"):
			get_node("/root/Pixelorama").unsaved_changes_dialog.connect("confirmed", self, "delete_tab", [tab])
		get_node("/root/Pixelorama").unsaved_changes_dialog.popup_centered()
		get_node("/root/Pixelorama").dialog_open(true)
	else:
		delete_tab(tab)


func _on_Tabs_reposition_active_tab_request(idx_to : int) -> void:
	var temp = get_node("/root/Pixelorama").projects[get_node("/root/Pixelorama").current_project_index]
	get_node("/root/Pixelorama").projects.erase(temp)
	get_node("/root/Pixelorama").projects.insert(idx_to, temp)

	# Change save paths
	var temp_save_path = get_node("/root/Pixelorama").get_open_save().current_save_paths[get_node("/root/Pixelorama").current_project_index]
	get_node("/root/Pixelorama").get_open_save().current_save_paths[get_node("/root/Pixelorama").current_project_index] = get_node("/root/Pixelorama").get_open_save().current_save_paths[idx_to]
	get_node("/root/Pixelorama").get_open_save().current_save_paths[idx_to] = temp_save_path
	var temp_backup_path = get_node("/root/Pixelorama").get_open_save().backup_save_paths[get_node("/root/Pixelorama").current_project_index]
	get_node("/root/Pixelorama").get_open_save().backup_save_paths[get_node("/root/Pixelorama").current_project_index] = get_node("/root/Pixelorama").get_open_save().backup_save_paths[idx_to]
	get_node("/root/Pixelorama").get_open_save().backup_save_paths[idx_to] = temp_backup_path


func delete_tab(tab : int) -> void:
	remove_tab(tab)
	get_node("/root/Pixelorama").projects[tab].undo_redo.free()
	get_node("/root/Pixelorama").get_open_save().remove_backup(tab)
	get_node("/root/Pixelorama").get_open_save().current_save_paths.remove(tab)
	get_node("/root/Pixelorama").get_open_save().backup_save_paths.remove(tab)
	get_node("/root/Pixelorama").projects.remove(tab)
	if tab > 0:
		get_node("/root/Pixelorama").current_project_index -= 1
	else:
		get_node("/root/Pixelorama").current_project_index = 0
	if get_node("/root/Pixelorama").unsaved_changes_dialog.is_connected("confirmed", self, "delete_tab"):
		get_node("/root/Pixelorama").unsaved_changes_dialog.disconnect("confirmed", self, "delete_tab")
