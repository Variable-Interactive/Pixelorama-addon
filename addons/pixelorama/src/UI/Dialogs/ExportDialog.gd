extends AcceptDialog

# called when user resumes export after filename collision
signal resume_export_function()

var animated_preview_current_frame := 0
var animated_preview_frames = []

onready var tabs = $VBoxContainer/Tabs
onready var popups = $Popups
onready var file_exists_alert_popup = $Popups/FileExistsAlert
onready var path_validation_alert_popup = $Popups/PathValidationAlert
onready var path_dialog_popup = $Popups/PathDialog
onready var export_progress_popup = $Popups/ExportProgressBar
onready var export_progress_bar = $Popups/ExportProgressBar/MarginContainer/ProgressBar

onready var animation_options_multiple_animations_directories = $VBoxContainer/AnimationOptions/MultipleAnimationsDirectories
onready var previews = $VBoxContainer/PreviewPanel/PreviewScroll/Previews
onready var frame_timer = $FrameTimer

onready var frame_options = $VBoxContainer/FrameOptions
onready var frame_options_frame_number = $VBoxContainer/FrameOptions/FrameNumber/FrameNumber

onready var spritesheet_options = $VBoxContainer/SpritesheetOptions
onready var spritesheet_options_frames = $VBoxContainer/SpritesheetOptions/Frames/Frames
onready var spritesheet_options_orientation = $VBoxContainer/SpritesheetOptions/Orientation/Orientation
onready var spritesheet_options_lines_count = $VBoxContainer/SpritesheetOptions/Orientation/LinesCount
onready var spritesheet_options_lines_count_label = $VBoxContainer/SpritesheetOptions/Orientation/LinesCountLabel

onready var animation_options = $VBoxContainer/AnimationOptions
onready var animation_options_animation_type = $VBoxContainer/AnimationOptions/AnimationType
onready var animation_options_animation_options = $VBoxContainer/AnimationOptions/AnimatedOptions
onready var animation_options_direction = $VBoxContainer/AnimationOptions/AnimatedOptions/Direction


onready var options_resize = $VBoxContainer/Options/Resize
onready var options_interpolation = $VBoxContainer/Options/Interpolation
onready var path_container = $VBoxContainer/Path
onready var path_line_edit = $VBoxContainer/Path/PathLineEdit
onready var file_line_edit = $VBoxContainer/File/FileLineEdit
onready var file_file_format = $VBoxContainer/File/FileFormat

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

func _ready() -> void:
	global = get_node("/root/Pixelorama")
	tabs.add_tab("Frame")
	tabs.add_tab("Spritesheet")
	tabs.add_tab("Animation")
	if OS.get_name() == "Windows":
		add_button("Cancel", true, "cancel")
		file_exists_alert_popup.add_button("Cancel Export", true, "cancel")
	else:
		add_button("Cancel", false, "cancel")
		file_exists_alert_popup.add_button("Cancel Export", false, "cancel")

	# Remove close button from export progress bar
	export_progress_popup.get_close_button().hide()


func show_tab() -> void:
	frame_options.hide()
	spritesheet_options.hide()
	animation_options.hide()
	print(global.get_export().current_tab)
	match global.get_export().current_tab:
		Constants.ExportTab.FRAME:
			global.get_export().file_format = Constants.FileFormat.PNG
			file_file_format.selected = Constants.FileFormat.PNG
			frame_timer.stop()
			if not global.get_export().was_exported:
				global.get_export().frame_number = global.current_project.current_frame + 1
			frame_options_frame_number.max_value = global.current_project.frames.size() + 1
			var prev_frame_number = frame_options_frame_number.value
			frame_options_frame_number.value = global.get_export().frame_number
			if prev_frame_number == global.get_export().frame_number:
				global.get_export().process_frame()
			frame_options.show()
		Constants.global.ExportTab.SPRITESHEET:
			create_frame_tag_list()
			global.get_export().file_format = global.get_export().FileFormat.PNG
			if not global.get_export().was_exported:
				global.get_export().orientation = global.get_export().Orientation.ROWS
				global.get_export().lines_count = int(ceil(sqrt(global.get_export().number_of_frames)))
			global.get_export().process_spritesheet()
			file_file_format.selected = global.get_export().FileFormat.PNG
			spritesheet_options_frames.select(global.get_export().frame_current_tag)
			frame_timer.stop()
			spritesheet_options_orientation.selected = global.get_export().orientation
			spritesheet_options_lines_count.max_value = global.get_export().number_of_frames
			spritesheet_options_lines_count.value = global.get_export().lines_count
			spritesheet_options_lines_count_label.text = "Columns:"
			spritesheet_options.show()
		Constants.ExportTab.ANIMATION:
			set_file_format_selector()
			global.get_export().process_animation()
			animation_options_animation_type.selected = global.get_export().animation_type
			animation_options_direction.selected = global.get_export().direction
			animation_options.show()
	set_preview()
	tabs.current_tab = global.get_export().current_tab


func set_preview() -> void:
	remove_previews()
	if global.get_export().processed_images.size() == 1 and global.get_export().current_tab != Constants.ExportTab.ANIMATION:
		previews.columns = 1
		add_image_preview(global.get_export().processed_images[0])
	else:
		match global.get_export().animation_type:
			Constants.AnimationType.MULTIPLE_FILES:
				previews.columns = ceil(sqrt(global.get_export().processed_images.size()))
				for i in range(global.get_export().processed_images.size()):
					add_image_preview(global.get_export().processed_images[i], i + 1)
			Constants.AnimationType.ANIMATED:
				previews.columns = 1
				add_animated_preview()


func add_image_preview(image: Image, canvas_number: int = -1) -> void:
	var container = create_preview_container()
	var preview = create_preview_rect()
	preview.texture = ImageTexture.new()
	preview.texture.create_from_image(image, 0)
	container.add_child(preview)

	if canvas_number != -1:
		var label = Label.new()
		label.align = Label.ALIGN_CENTER
		label.text = String(canvas_number)
		container.add_child(label)

	previews.add_child(container)


func add_animated_preview() -> void:
	animated_preview_current_frame = global.get_export().processed_images.size() - 1 if global.get_export().direction == global.get_export().AnimationDirection.BACKWARDS else 0
	animated_preview_frames = []

	for processed_image in global.get_export().processed_images:
		var texture = ImageTexture.new()
		texture.create_from_image(processed_image, 0)
		animated_preview_frames.push_back(texture)

	var container = create_preview_container()
	container.name = "PreviewContainer"
	var preview = create_preview_rect()
	preview.name = "Preview"
	preview.texture = animated_preview_frames[animated_preview_current_frame]
	container.add_child(preview)

	previews.add_child(container)
	frame_timer.set_one_shot(true) #The wait_time it can't change correctly if it is playing
	frame_timer.wait_time = global.current_project.frame_duration[animated_preview_current_frame] * (1 / global.animation_timeline.fps)
	frame_timer.start()


func create_preview_container() -> VBoxContainer:
	var container = VBoxContainer.new()
	container.size_flags_horizontal = SIZE_EXPAND_FILL
	container.size_flags_vertical = SIZE_EXPAND_FILL
	container.rect_min_size = Vector2(0, 128)
	return container


func create_preview_rect() -> TextureRect:
	var preview = TextureRect.new()
	preview.expand = true
	preview.size_flags_horizontal = SIZE_EXPAND_FILL
	preview.size_flags_vertical = SIZE_EXPAND_FILL
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	return preview


func remove_previews() -> void:
	for child in previews.get_children():
		child.free()


func set_file_format_selector() -> void:
	animation_options_multiple_animations_directories.visible = false
	match global.get_export().animation_type:
		Constants.AnimationType.MULTIPLE_FILES:
			global.get_export().file_format = global.get_export().FileFormat.PNG
			file_file_format.selected = global.get_export().FileFormat.PNG
			frame_timer.stop()
			animation_options_animation_options.hide()
			animation_options_multiple_animations_directories.pressed = global.get_export().new_dir_for_each_frame_tag
			animation_options_multiple_animations_directories.visible = true
		Constants.AnimationType.ANIMATED:
			global.get_export().file_format = global.get_export().FileFormat.GIF
			file_file_format.selected = global.get_export().FileFormat.GIF
			animation_options_animation_options.show()


func create_frame_tag_list() -> void:
	# Clear existing tag list from entry if it exists
	spritesheet_options_frames.clear()
	spritesheet_options_frames.add_item("All Frames", 0) # Re-add removed 'All Frames' item

	# Repopulate list with current tag list
	for item in global.current_project.animation_tags:
		spritesheet_options_frames.add_item(item.name)


func open_path_validation_alert_popup() -> void:
	path_validation_alert_popup.popup_centered()


func open_file_exists_alert_popup(dialog_text: String) -> void:
	file_exists_alert_popup.dialog_text = dialog_text
	file_exists_alert_popup.popup_centered()


func toggle_export_progress_popup(open: bool) -> void:
	if open:
		export_progress_popup.popup_centered()
	else:
		export_progress_popup.hide()


func set_export_progress_bar(value: float) -> void:
	export_progress_bar.value = value


func _on_ExportDialog_about_to_show() -> void:
	# If we're on HTML5, don't let the user change the directory path
	if OS.get_name() == "HTML5":
		path_container.visible = false
		global.get_export().directory_path = "user://"

	if global.get_export().directory_path.empty():
		global.get_export().directory_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)

	# If export already occured - sets gui to show previous settings
	options_resize.value = global.get_export().resize
	options_interpolation.selected = global.get_export().interpolation
	path_line_edit.text = global.get_export().directory_path
	path_dialog_popup.current_dir = global.get_export().directory_path
	file_line_edit.text = global.get_export().file_name
	file_file_format.selected = global.get_export().file_format
	show_tab()

	for child in popups.get_children(): # Set the theme for the popups
		child.theme = global.control.theme

	global.get_export().file_exists_alert = tr("File %s already exists. Overwrite?") # Update translation

	# Set the size of the preview checker
	var checker = $VBoxContainer/PreviewPanel/TransparentChecker
	checker.rect_size = checker.get_parent().rect_size

func _on_Tabs_tab_clicked(tab : int) -> void:
	global.get_export().current_tab = tab
	show_tab()


func _on_Frame_value_changed(value: float) -> void:
	global.get_export().frame_number = value
	global.get_export().process_frame()
	set_preview()


func _on_Orientation_item_selected(id : int) -> void:
	global.get_export().orientation = id
	if global.get_export().orientation == global.get_export().Orientation.ROWS:
		spritesheet_options_lines_count_label.text = "Columns:"
	else:
		spritesheet_options_lines_count_label.text = "Rows:"
	spritesheet_options_lines_count.value = global.get_export().frames_divided_by_spritesheet_lines()
	global.get_export().process_spritesheet()
	set_preview()


func _on_LinesCount_value_changed(value : float) -> void:
	global.get_export().lines_count = value
	global.get_export().process_spritesheet()
	set_preview()


func _on_AnimationType_item_selected(id : int) -> void:
	global.get_export().animation_type = id
	set_file_format_selector()
	set_preview()


func _on_Direction_item_selected(id : int) -> void:
	global.get_export().direction = id
	match id:
		Constants.AnimationDirection.FORWARD:
			animated_preview_current_frame = 0
		Constants.AnimationDirection.BACKWARDS:
			animated_preview_current_frame = global.get_export().processed_images.size() - 1
		Constants.AnimationDirection.PING_PONG:
			animated_preview_current_frame = 0
			pingpong_direction = global.get_export().AnimationDirection.FORWARD


func _on_Resize_value_changed(value : float) -> void:
	global.get_export().resize = value


func _on_Interpolation_item_selected(id: int) -> void:
	global.get_export().interpolation = id


func _on_ExportDialog_confirmed() -> void:
	if global.get_export().export_processed_images(false, self):
		hide()


func _on_ExportDialog_custom_action(action : String) -> void:
	if action == "cancel":
		hide()


func _on_PathButton_pressed() -> void:
	path_dialog_popup.popup_centered()


func _on_PathLineEdit_text_changed(new_text : String) -> void:
	global.current_project.directory_path = new_text
	global.get_export().directory_path = new_text


func _on_FileLineEdit_text_changed(new_text : String) -> void:
	global.current_project.file_name = new_text
	global.get_export().file_name = new_text


func _on_FileDialog_dir_selected(dir : String) -> void:
	path_line_edit.text = dir
	global.current_project.directory_path = dir
	global.get_export().directory_path = dir


func _on_FileFormat_item_selected(id : int) -> void:
	global.current_project.file_format = id
	global.get_export().file_format = id


func _on_FileExistsAlert_confirmed() -> void:
	# Overwrite existing file
	file_exists_alert_popup.dialog_text = global.get_export().file_exists_alert
	global.get_export().stop_export = false
	emit_signal("resume_export_function")


func _on_FileExistsAlert_custom_action(action : String) -> void:
	if action == "cancel":
		# Cancel export
		file_exists_alert_popup.dialog_text = global.get_export().file_exists_alert
		global.get_export().stop_export = true
		emit_signal("resume_export_function")
		file_exists_alert_popup.hide()


var pingpong_direction = Constants.AnimationDirection.FORWARD
func _on_FrameTimer_timeout() -> void:
	$VBoxContainer/PreviewPanel/PreviewScroll/Previews/PreviewContainer/Preview.texture = animated_preview_frames[animated_preview_current_frame]

	match global.get_export().direction:
		Constants.AnimationDirection.FORWARD:
			if animated_preview_current_frame == animated_preview_frames.size() - 1:
				animated_preview_current_frame = 0
			else:
				animated_preview_current_frame += 1
			frame_timer.wait_time = global.current_project.frame_duration[(animated_preview_current_frame - 1) % (animated_preview_frames.size())] * (1 / global.animation_timeline.fps)
			frame_timer.start()
		Constants.AnimationDirection.BACKWARDS:
			if animated_preview_current_frame == 0:
				animated_preview_current_frame = global.get_export().processed_images.size() - 1
			else:
				animated_preview_current_frame -= 1
			frame_timer.wait_time = global.current_project.frame_duration[(animated_preview_current_frame + 1) % (animated_preview_frames.size())] * (1 / global.animation_timeline.fps)
			frame_timer.start()
		Constants.AnimationDirection.PING_PONG:
			match pingpong_direction:
				Constants.AnimationDirection.FORWARD:
					if animated_preview_current_frame == animated_preview_frames.size() - 1:
						pingpong_direction = global.get_export().AnimationDirection.BACKWARDS
						animated_preview_current_frame -= 1
						if animated_preview_current_frame <= 0:
							animated_preview_current_frame = 0
					else:
						animated_preview_current_frame += 1
					frame_timer.wait_time = global.current_project.frame_duration[(animated_preview_current_frame - 1) % (animated_preview_frames.size())] * (1 / global.animation_timeline.fps)
					frame_timer.start()
				Constants.AnimationDirection.BACKWARDS:
					if animated_preview_current_frame == 0:
						animated_preview_current_frame += 1
						if animated_preview_current_frame >= animated_preview_frames.size() - 1:
							animated_preview_current_frame = 0
						pingpong_direction = global.get_export().AnimationDirection.FORWARD
					else:
						animated_preview_current_frame -= 1
					frame_timer.wait_time = global.current_project.frame_duration[(animated_preview_current_frame + 1) % (animated_preview_frames.size())] * (1 / global.animation_timeline.fps)
					frame_timer.start()



func _on_ExportDialog_popup_hide() -> void:
	frame_timer.stop()


func _on_MultipleAnimationsDirectories_toggled(button_pressed : bool) -> void:
	global.get_export().new_dir_for_each_frame_tag = button_pressed


func _on_Frames_item_selected(id : int) -> void:
	global.get_export().frame_current_tag = id
	global.get_export().process_spritesheet()
	set_preview()
	spritesheet_options_lines_count.max_value = global.get_export().number_of_frames
	spritesheet_options_lines_count.value = global.get_export().lines_count
