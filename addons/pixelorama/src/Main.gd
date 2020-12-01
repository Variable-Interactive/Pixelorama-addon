tool
extends Control

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

var opensprite_file_selected := false
var redone := false
var is_quitting_on_save := false


# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	global = get_node(Constants.NODE_PATH_GLOBAL)
	get_tree().set_auto_accept_quit(false)
	setup_application_window_size()

	global.window_title = tr("untitled") + " - Pixelorama " + global.current_version
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	global.current_project.layers[0].name = tr("Layer") + " 0"
	global.layers_container.get_child(0).label.text = global.current_project.layers[0].name
	global.layers_container.get_child(0).line_edit.text = global.current_project.layers[0].name

	global.get_import().import_brushes(global.directory_module.get_brushes_search_path_in_order())
	global.get_import().import_patterns(global.directory_module.get_patterns_search_path_in_order())

	global.quit_and_save_dialog.add_button("Save & Exit", false, "Save")
	global.quit_and_save_dialog.get_ok().text = "Exit without saving"

	global.open_sprites_dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
	global.save_sprites_dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)

	var zstd_checkbox := CheckBox.new()
	zstd_checkbox.name = "ZSTDCompression"
	zstd_checkbox.pressed = true
	zstd_checkbox.text = "Use ZSTD Compression"
	zstd_checkbox.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	global.save_sprites_dialog.get_vbox().add_child(zstd_checkbox)

	if not global.config_cache.has_section_key("preferences", "startup"):
		global.config_cache.set_value("preferences", "startup", true)
	show_splash_screen()

	handle_backup()

	# If the user wants to run Pixelorama with arguments in terminal mode
	# or open files with Pixelorama directly, then handle that
	if OS.get_cmdline_args():
		global.get_open_save().handle_loading_files(OS.get_cmdline_args())
	get_tree().connect("files_dropped", self, "_on_files_dropped")


func _input(event : InputEvent) -> void:
	global.left_cursor.position = get_global_mouse_position() + Vector2(-32, 32)
	global.left_cursor.texture = global.left_cursor_tool_texture
	global.right_cursor.position = get_global_mouse_position() + Vector2(32, 32)
	global.right_cursor.texture = global.right_cursor_tool_texture

	if event is InputEventKey and (event.scancode == KEY_ENTER or event.scancode == KEY_KP_ENTER):
		if get_focus_owner() is LineEdit:
			get_focus_owner().release_focus()

	if event.is_action_pressed("redo_secondary"): # Shift + Ctrl + Z
		redone = true
		global.current_project.undo_redo.redo()
		redone = false


func setup_application_window_size() -> void:
	if OS.get_name() == "HTML5":
		return
	# Set a minimum window size to prevent UI elements from collapsing on each other.
	OS.min_window_size = Vector2(1024, 576)

	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_DISABLED,
		SceneTree.STRETCH_ASPECT_IGNORE, Vector2(1024,576), global.shrink)

	# Restore the window position/size if values are present in the configuration cache
	if global.config_cache.has_section_key("window", "screen"):
		OS.current_screen = global.config_cache.get_value("window", "screen")
	if global.config_cache.has_section_key("window", "maximized"):
		OS.window_maximized = global.config_cache.get_value("window", "maximized")

	if !OS.window_maximized:
		if global.config_cache.has_section_key("window", "position"):
			OS.window_position = global.config_cache.get_value("window", "position")
		if global.config_cache.has_section_key("window", "size"):
			OS.window_size = global.config_cache.get_value("window", "size")


func show_splash_screen() -> void:
	# Wait for the window to adjust itself, so the popup is correctly centered
	yield(get_tree().create_timer(0.2), "timeout")
	if global.config_cache.get_value("preferences", "startup"):
		$Dialogs/SplashDialog.popup_centered() # Splash screen
		modulate = Color(0.5, 0.5, 0.5)
	else:
		global.can_draw = true


func handle_backup() -> void:
	# If backup file exists then Pixelorama was not closed properly (probably crashed) - reopen backup
	var backup_confirmation : ConfirmationDialog = $Dialogs/BackupConfirmation
	backup_confirmation.get_cancel().text = tr("Delete")
	if global.config_cache.has_section("backups"):
		var project_paths = global.config_cache.get_section_keys("backups")
		if project_paths.size() > 0:
			# Get backup paths
			var backup_paths := []
			for p_path in project_paths:
				backup_paths.append(global.config_cache.get_value("backups", p_path))
			# Temporatily stop autosave until user confirms backup
			global.get_open_save().autosave_timer.stop()
			backup_confirmation.dialog_text = tr(backup_confirmation.dialog_text) % project_paths
			backup_confirmation.connect("confirmed", self, "_on_BackupConfirmation_confirmed", [project_paths, backup_paths])
			backup_confirmation.get_cancel().connect("pressed", self, "_on_BackupConfirmation_delete", [project_paths, backup_paths])
			backup_confirmation.popup_centered()
			global.can_draw = false
			modulate = Color(0.5, 0.5, 0.5)
		else:
			if global.open_last_project:
				load_last_project()
	else:
		if global.open_last_project:
			load_last_project()


func _notification(what : int) -> void:
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST: # Handle exit
		show_quit_dialog()


func _on_files_dropped(_files : PoolStringArray, _screen : int) -> void:
	global.get_open_save().handle_loading_files(_files)


func load_last_project() -> void:
	if OS.get_name() == "HTML5":
		return
	# Check if any project was saved or opened last time
	if global.config_cache.has_section_key("preferences", "last_project_path"):
		# Check if file still exists on disk
		var file_path = global.config_cache.get_value("preferences", "last_project_path")
		var file_check := File.new()
		if file_check.file_exists(file_path): # If yes then load the file
			global.get_open_save().open_pxo_file(file_path)
		else:
			# If file doesn't exist on disk then warn user about this
			global.error_dialog.set_text("Cannot find last project file.")
			global.error_dialog.popup_centered()
			global.dialog_open(true)


func load_recent_project_file(path : String) -> void:
	if OS.get_name() == "HTML5":
		return

	# Check if file still exists on disk
	var file_check := File.new()
	if file_check.file_exists(path): # If yes then load the file
		global.get_open_save().handle_loading_files([path])
	else:
		# If file doesn't exist on disk then warn user about this
		global.error_dialog.set_text("Cannot find project file.")
		global.error_dialog.popup_centered()
		global.dialog_open(true)


func _on_OpenSprite_file_selected(path : String) -> void:
	global.get_open_save().handle_loading_files([path])


func _on_SaveSprite_file_selected(path : String) -> void:
	var zstd = global.save_sprites_dialog.get_vbox().get_node("ZSTDCompression").pressed
	global.get_open_save().save_pxo_file(path, false, zstd)

	if is_quitting_on_save:
		_on_QuitDialog_confirmed()


func _on_SaveSpriteHTML5_confirmed() -> void:
	var file_name = global.save_sprites_html5_dialog.get_node("FileNameContainer/FileNameLineEdit").text
	file_name += ".pxo"
	var path = "user://".plus_file(file_name)
	global.get_open_save().save_pxo_file(path, false, false)


func _on_OpenSprite_popup_hide() -> void:
	if !opensprite_file_selected:
		_can_draw_true()


func _can_draw_true() -> void:
	global.dialog_open(false)


func show_quit_dialog() -> void:
	if !global.quit_dialog.visible:
		if !global.current_project.has_changed:
			global.quit_dialog.call_deferred("popup_centered")
		else:
			global.quit_and_save_dialog.call_deferred("popup_centered")

	global.dialog_open(true)


func _on_QuitAndSaveDialog_custom_action(action : String) -> void:
	if action == "Save":
		is_quitting_on_save = true
		global.save_sprites_dialog.popup_centered()
		global.quit_dialog.hide()
		global.dialog_open(true)


func _on_QuitDialog_confirmed() -> void:
	# Darken the UI to denote that the application is currently exiting
	# (it won't respond to user input in this state).
	modulate = Color(0.5, 0.5, 0.5)
	get_tree().quit()


func _on_BackupConfirmation_confirmed(project_paths : Array, backup_paths : Array) -> void:
	global.get_open_save().reload_backup_file(project_paths, backup_paths)
	global.get_open_save().autosave_timer.start()
	global.get_export().file_name = global.get_open_save().current_save_paths[0].get_file().trim_suffix(".pxo")
	global.get_export().directory_path = global.get_open_save().current_save_paths[0].get_base_dir()
	global.get_export().was_exported = false
	global.file_menu.get_popup().set_item_text(4, tr("Save") + " %s" % global.get_open_save().current_save_paths[0].get_file())
	global.file_menu.get_popup().set_item_text(6, tr("Export"))


func _on_BackupConfirmation_delete(project_paths : Array, backup_paths : Array) -> void:
	for i in range(project_paths.size()):
		global.get_open_save().remove_backup_by_path(project_paths[i], backup_paths[i])
	global.get_open_save().autosave_timer.start()
	# Reopen last project
	if global.open_last_project:
		load_last_project()
