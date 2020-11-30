extends Panel


var file_menu : PopupMenu
var view_menu : PopupMenu
var zen_mode := false

var global

func _ready() -> void:
	global = get_node("/root/Pixelorama")
	setup_file_menu()
	setup_edit_menu()
	setup_view_menu()
	setup_image_menu()
	setup_help_menu()


func setup_file_menu() -> void:
	var file_menu_items := {
		"New..." : InputMap.get_action_list("new_file")[0].get_scancode_with_modifiers(),
		"Open..." : InputMap.get_action_list("open_file")[0].get_scancode_with_modifiers(),
		'Open last project...' : 0,
		"Recent projects": 0,
		"Save..." : InputMap.get_action_list("save_file")[0].get_scancode_with_modifiers(),
		"Save as..." : InputMap.get_action_list("save_file_as")[0].get_scancode_with_modifiers(),
		"Export..." : InputMap.get_action_list("export_file")[0].get_scancode_with_modifiers(),
		"Export as..." : InputMap.get_action_list("export_file_as")[0].get_scancode_with_modifiers(),
		"Quit" : InputMap.get_action_list("quit")[0].get_scancode_with_modifiers(),
		}
	file_menu = get_node("/root/Pixelorama").file_menu.get_popup()
	var i := 0

	for item in file_menu_items.keys():
		if item == "Recent projects":
			setup_recent_projects_submenu(item)
		else:
			file_menu.add_item(item, i, file_menu_items[item])
			i += 1

	file_menu.connect("id_pressed", self, "file_menu_id_pressed")

	if OS.get_name() == "HTML5":
		file_menu.set_item_disabled(2, true)
		file_menu.set_item_disabled(3, true)


func setup_recent_projects_submenu(item : String) -> void:
	get_node("/root/Pixelorama").recent_projects_submenu.connect("id_pressed", self, "on_recent_projects_submenu_id_pressed")
	get_node("/root/Pixelorama").update_recent_projects_submenu()

	file_menu.add_child(get_node("/root/Pixelorama").recent_projects_submenu)
	file_menu.add_submenu_item(item, get_node("/root/Pixelorama").recent_projects_submenu.get_name())


func setup_edit_menu() -> void:
	var edit_menu_items := {
		"Undo" : InputMap.get_action_list("undo")[0].get_scancode_with_modifiers(),
		"Redo" : InputMap.get_action_list("redo")[0].get_scancode_with_modifiers(),
		"Copy" : InputMap.get_action_list("copy")[0].get_scancode_with_modifiers(),
		"Cut" : InputMap.get_action_list("cut")[0].get_scancode_with_modifiers(),
		"Paste" : InputMap.get_action_list("paste")[0].get_scancode_with_modifiers(),
		"Delete" : InputMap.get_action_list("delete")[0].get_scancode_with_modifiers(),
		"Clear Selection" : 0,
		"Preferences" : 0
		}
	var edit_menu : PopupMenu = get_node("/root/Pixelorama").edit_menu.get_popup()
	var i := 0

	for item in edit_menu_items.keys():
		edit_menu.add_item(item, i, edit_menu_items[item])
		i += 1

	edit_menu.connect("id_pressed", self, "edit_menu_id_pressed")


func setup_view_menu() -> void:
	var view_menu_items := {
		"Tile Mode" : 0,
		"Mirror View" : InputMap.get_action_list("mirror_view")[0].get_scancode_with_modifiers(),
		"Show Grid" : InputMap.get_action_list("show_grid")[0].get_scancode_with_modifiers(),
		"Show Rulers" : InputMap.get_action_list("show_rulers")[0].get_scancode_with_modifiers(),
		"Show Guides" : InputMap.get_action_list("show_guides")[0].get_scancode_with_modifiers(),
		"Show Animation Timeline" : 0,
		"Zen Mode" : InputMap.get_action_list("zen_mode")[0].get_scancode_with_modifiers(),
		"Fullscreen Mode" : InputMap.get_action_list("toggle_fullscreen")[0].get_scancode_with_modifiers(),
		}
	view_menu = get_node("/root/Pixelorama").view_menu.get_popup()

	var i := 0
	for item in view_menu_items.keys():
		if item == "Tile Mode":
			setup_tile_mode_submenu(item)
		else:
			view_menu.add_check_item(item, i, view_menu_items[item])
		i += 1
	view_menu.set_item_checked(3, true) # Show Rulers
	view_menu.set_item_checked(4, true) # Show Guides
	view_menu.set_item_checked(5, true) # Show Animation Timeline
	view_menu.hide_on_checkable_item_selection = false
	view_menu.connect("id_pressed", self, "view_menu_id_pressed")


func setup_tile_mode_submenu(item : String):
	get_node("/root/Pixelorama").tile_mode_submenu.connect("id_pressed", self, "tile_mode_submenu_id_pressed")
	view_menu.add_child(get_node("/root/Pixelorama").tile_mode_submenu)
	view_menu.add_submenu_item(item, get_node("/root/Pixelorama").tile_mode_submenu.get_name())


func setup_image_menu() -> void:
	var image_menu_items := {
		"Scale Image" : 0,
		"Crop Image" : 0,
		"Resize Canvas" : 0,
		"Flip" : 0,
		"Rotate Image" : 0,
		"Invert Colors" : 0,
		"Desaturation" : 0,
		"Outline" : 0,
		"Adjust Hue/Saturation/Value" : 0,
		"Gradient" : 0,
		# "Shader" : 0
		}
	var image_menu : PopupMenu = get_node("/root/Pixelorama").image_menu.get_popup()

	var i := 0
	for item in image_menu_items.keys():
		image_menu.add_item(item, i, image_menu_items[item])
		if i == 2:
			image_menu.add_separator()
		i += 1

	image_menu.connect("id_pressed", self, "image_menu_id_pressed")


func setup_help_menu() -> void:
	var help_menu_items := {
		"View Splash Screen" : 0,
		"Online Docs" : InputMap.get_action_list("open_docs")[0].get_scancode_with_modifiers(),
		"Issue Tracker" : 0,
		"Changelog" : 0,
		"About Pixelorama" : 0
		}
	var help_menu : PopupMenu = get_node("/root/Pixelorama").help_menu.get_popup()

	var i := 0
	for item in help_menu_items.keys():
		help_menu.add_item(item, i, help_menu_items[item])
		i += 1

	help_menu.connect("id_pressed", self, "help_menu_id_pressed")


func file_menu_id_pressed(id : int) -> void:
	match id:
		0: # New
			on_new_project_file_menu_option_pressed()
		1: # Open
			open_project_file()
		2: # Open last project
			on_open_last_project_file_menu_option_pressed()
		3: # Save
			save_project_file()
		4: # Save as
			save_project_file_as()
		5: # Export
			export_file()
		6: # Export as
			get_node("/root/Pixelorama").export_dialog.popup_centered()
			get_node("/root/Pixelorama").dialog_open(true)
		7: # Quit
			get_node("/root/Pixelorama").control.show_quit_dialog()


func on_new_project_file_menu_option_pressed() -> void:
	get_node("/root/Pixelorama").new_image_dialog.popup_centered()
	get_node("/root/Pixelorama").dialog_open(true)


func open_project_file() -> void:
	if OS.get_name() == "HTML5":
		global.get_html5_file_exchange().load_image()
	else:
		get_node("/root/Pixelorama").open_sprites_dialog.popup_centered()
		get_node("/root/Pixelorama").dialog_open(true)
		get_node("/root/Pixelorama").control.opensprite_file_selected = false


func on_open_last_project_file_menu_option_pressed() -> void:
	# Check if last project path is set and if yes then open
	if get_node("/root/Pixelorama").config_cache.has_section_key("preferences", "last_project_path"):
		get_node("/root/Pixelorama").control.load_last_project()
	else: # if not then warn user that he didn't edit any project yet
		get_node("/root/Pixelorama").error_dialog.set_text("You haven't saved or opened any project in Pixelorama yet!")
		get_node("/root/Pixelorama").error_dialog.popup_centered()
		get_node("/root/Pixelorama").dialog_open(true)


func save_project_file() -> void:
	get_node("/root/Pixelorama").control.is_quitting_on_save = false
	var path = get_node("/root/Pixelorama").get_open_save().current_save_paths[get_node("/root/Pixelorama").current_project_index]
	if path == "":
		if OS.get_name() == "HTML5":
			get_node("/root/Pixelorama").save_sprites_html5_dialog.popup_centered()
		else:
			get_node("/root/Pixelorama").save_sprites_dialog.popup_centered()
		get_node("/root/Pixelorama").dialog_open(true)
	else:
		get_node("/root/Pixelorama").control._on_SaveSprite_file_selected(path)


func save_project_file_as() -> void:
	get_node("/root/Pixelorama").control.is_quitting_on_save = false
	if OS.get_name() == "HTML5":
		get_node("/root/Pixelorama").save_sprites_html5_dialog.popup_centered()
	else:
		get_node("/root/Pixelorama").save_sprites_dialog.popup_centered()
	get_node("/root/Pixelorama").dialog_open(true)


func export_file() -> void:
	if get_node("/root/Pixelorama").get_export().was_exported == false:
		get_node("/root/Pixelorama").export_dialog.popup_centered()
		get_node("/root/Pixelorama").dialog_open(true)
	else:
		get_node("/root/Pixelorama").get_export().external_export()


func on_recent_projects_submenu_id_pressed(id : int) -> void:
	get_node("/root/Pixelorama").control.load_recent_project_file(get_node("/root/Pixelorama").recent_projects[id])


func edit_menu_id_pressed(id : int) -> void:
	match id:
		0: # Undo
			get_node("/root/Pixelorama").current_project.undo_redo.undo()
		1: # Redo
			get_node("/root/Pixelorama").control.redone = true
			get_node("/root/Pixelorama").current_project.undo_redo.redo()
			get_node("/root/Pixelorama").control.redone = false
		2: # Copy
			get_node("/root/Pixelorama").selection_rectangle.copy()
		3: # cut
			get_node("/root/Pixelorama").selection_rectangle.cut()
		4: # paste
			get_node("/root/Pixelorama").selection_rectangle.paste()
		5: # Delete
			get_node("/root/Pixelorama").selection_rectangle.delete()
		6: # Clear selection
			get_node("/root/Pixelorama").selection_rectangle.set_rect(Rect2(0, 0, 0, 0))
			get_node("/root/Pixelorama").selection_rectangle.select_rect()
		7: # Preferences
			get_node("/root/Pixelorama").preferences_dialog.popup_centered(Vector2(400, 280))
			get_node("/root/Pixelorama").dialog_open(true)


func view_menu_id_pressed(id : int) -> void:
	match id:
		1: # Mirror View
			toggle_mirror_view()
		2: # Show grid
			toggle_show_grid()
		3: # Show rulers
			toggle_show_rulers()
		4: # Show guides
			toggle_show_guides()
		5: # Show animation timeline
			toggle_show_anim_timeline()
		6: # Zen mode
			toggle_zen_mode()
		7: # Fullscreen mode
			toggle_fullscreen()
	get_node("/root/Pixelorama").canvas.update()


func tile_mode_submenu_id_pressed(id : int):
	get_node("/root/Pixelorama").transparent_checker._init_position(id)
	for i in range(len(get_node("/root/Pixelorama").Tile_Mode)):
		if  i != id:
			get_node("/root/Pixelorama").tile_mode_submenu.set_item_checked(i, false)
		else:
			get_node("/root/Pixelorama").tile_mode_submenu.set_item_checked(i, true)
	get_node("/root/Pixelorama").canvas.tile_mode.update()
	get_node("/root/Pixelorama").canvas.grid.update()
	get_node("/root/Pixelorama").canvas.grid.set_position(get_node("/root/Pixelorama").transparent_checker.get_position())


func toggle_mirror_view() -> void:
	get_node("/root/Pixelorama").mirror_view = !get_node("/root/Pixelorama").mirror_view
	view_menu.set_item_checked(1, get_node("/root/Pixelorama").mirror_view)


func toggle_show_grid() -> void:
	get_node("/root/Pixelorama").draw_grid = !get_node("/root/Pixelorama").draw_grid
	view_menu.set_item_checked(2, get_node("/root/Pixelorama").draw_grid)
	get_node("/root/Pixelorama").canvas.grid.update()


func toggle_show_rulers() -> void:
	get_node("/root/Pixelorama").show_rulers = !get_node("/root/Pixelorama").show_rulers
	view_menu.set_item_checked(3, get_node("/root/Pixelorama").show_rulers)
	get_node("/root/Pixelorama").horizontal_ruler.visible = get_node("/root/Pixelorama").show_rulers
	get_node("/root/Pixelorama").vertical_ruler.visible = get_node("/root/Pixelorama").show_rulers


func toggle_show_guides() -> void:
	get_node("/root/Pixelorama").show_guides = !get_node("/root/Pixelorama").show_guides
	view_menu.set_item_checked(4, get_node("/root/Pixelorama").show_guides)
	for guide in get_node("/root/Pixelorama").canvas.get_children():
		if guide is Guide and guide in get_node("/root/Pixelorama").current_project.guides:
			guide.visible = get_node("/root/Pixelorama").show_guides
			if guide is SymmetryGuide:
				if guide.type == Guide.Types.HORIZONTAL:
					guide.visible = get_node("/root/Pixelorama").show_x_symmetry_axis and get_node("/root/Pixelorama").show_guides
				else:
					guide.visible = get_node("/root/Pixelorama").show_y_symmetry_axis and get_node("/root/Pixelorama").show_guides


func toggle_show_anim_timeline() -> void:
	if zen_mode:
		return
	get_node("/root/Pixelorama").show_animation_timeline = !get_node("/root/Pixelorama").show_animation_timeline
	view_menu.set_item_checked(5, get_node("/root/Pixelorama").show_animation_timeline)
	get_node("/root/Pixelorama").animation_timeline.visible = get_node("/root/Pixelorama").show_animation_timeline


func toggle_zen_mode() -> void:
	if get_node("/root/Pixelorama").show_animation_timeline:
		get_node("/root/Pixelorama").animation_timeline.visible = zen_mode
	get_node("/root/Pixelorama").control.get_node("MenuAndUI/UI/ToolPanel").visible = zen_mode
	get_node("/root/Pixelorama").control.get_node("MenuAndUI/UI/RightPanel").visible = zen_mode
	get_node("/root/Pixelorama").control.get_node("MenuAndUI/UI/CanvasAndTimeline/ViewportAndRulers/TabsContainer").visible = zen_mode
	zen_mode = !zen_mode
	view_menu.set_item_checked(6, zen_mode)


func toggle_fullscreen() -> void:
	OS.window_fullscreen = !OS.window_fullscreen
	view_menu.set_item_checked(7, OS.window_fullscreen)


func image_menu_id_pressed(id : int) -> void:
	if get_node("/root/Pixelorama").current_project.layers[get_node("/root/Pixelorama").current_project.current_layer].locked: # No changes if the layer is locked
		return
	var image : Image = get_node("/root/Pixelorama").current_project.frames[get_node("/root/Pixelorama").current_project.current_frame].cels[get_node("/root/Pixelorama").current_project.current_layer].image
	match id:
		0: # Scale Image
			show_scale_image_popup()

		1: # Crop Image
			DrawingAlgos.crop_image(image)

		2: # Resize Canvas
			show_resize_canvas_popup()

		3: # Flip
			get_node("/root/Pixelorama").control.get_node("Dialogs/ImageEffects/FlipImageDialog").popup_centered()
			get_node("/root/Pixelorama").dialog_open(true)

		4: # Rotate
			show_rotate_image_popup()

		5: # Invert Colors
			get_node("/root/Pixelorama").control.get_node("Dialogs/ImageEffects/InvertColorsDialog").popup_centered()
			get_node("/root/Pixelorama").dialog_open(true)

		6: # Desaturation
			get_node("/root/Pixelorama").control.get_node("Dialogs/ImageEffects/DesaturateDialog").popup_centered()
			get_node("/root/Pixelorama").dialog_open(true)

		7: # Outline
			show_add_outline_popup()

		8: # HSV
			show_hsv_configuration_popup()

		9: # Gradient
			get_node("/root/Pixelorama").control.get_node("Dialogs/ImageEffects/GradientDialog").popup_centered()
			get_node("/root/Pixelorama").dialog_open(true)

		10: # Shader
			get_node("/root/Pixelorama").control.get_node("Dialogs/ImageEffects/ShaderEffect").popup_centered()
			get_node("/root/Pixelorama").dialog_open(true)


func show_scale_image_popup() -> void:
	get_node("/root/Pixelorama").control.get_node("Dialogs/ImageEffects/ScaleImage").popup_centered()
	get_node("/root/Pixelorama").dialog_open(true)


func show_resize_canvas_popup() -> void:
	get_node("/root/Pixelorama").control.get_node("Dialogs/ImageEffects/ResizeCanvas").popup_centered()
	get_node("/root/Pixelorama").dialog_open(true)


func show_rotate_image_popup() -> void:
	get_node("/root/Pixelorama").control.get_node("Dialogs/ImageEffects/RotateImage").popup_centered()
	get_node("/root/Pixelorama").dialog_open(true)


func show_add_outline_popup() -> void:
	get_node("/root/Pixelorama").control.get_node("Dialogs/ImageEffects/OutlineDialog").popup_centered()
	get_node("/root/Pixelorama").dialog_open(true)


func show_hsv_configuration_popup() -> void:
	get_node("/root/Pixelorama").control.get_node("Dialogs/ImageEffects/HSVDialog").popup_centered()
	get_node("/root/Pixelorama").dialog_open(true)


func help_menu_id_pressed(id : int) -> void:
	match id:
		0: # Splash Screen
			get_node("/root/Pixelorama").control.get_node("Dialogs/SplashDialog").popup_centered()
			get_node("/root/Pixelorama").dialog_open(true)
		1: # Online Docs
			OS.shell_open("https://orama-interactive.github.io/Pixelorama-Docs/")
		2: # Issue Tracker
			OS.shell_open("https://github.com/Orama-Interactive/Pixelorama/issues")
		3: # Changelog
			if OS.get_name() == "OSX":
				OS.shell_open("https://github.com/Orama-Interactive/Pixelorama/blob/master/CHANGELOG.md")
			else:
				OS.shell_open("https://github.com/Orama-Interactive/Pixelorama/blob/master/CHANGELOG.md#v08---2020-10-14")
		4: # About Pixelorama
			get_node("/root/Pixelorama").control.get_node("Dialogs/AboutDialog").popup_centered()
			get_node("/root/Pixelorama").dialog_open(true)
