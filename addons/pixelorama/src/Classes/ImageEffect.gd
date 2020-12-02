tool
class_name ImageEffect extends AcceptDialog
# Parent class for all image effects
# Methods that have "pass" are meant to be replaced by the inherited Scripts


enum {CEL, FRAME, ALL_FRAMES, ALL_PROJECTS}

var affect : int = CEL
var pixels := []
var current_cel : Image
var current_frame : Image
var preview_image : Image
var preview_texture : ImageTexture
var preview : TextureRect
var selection_checkbox : CheckBox
var affect_option_button : OptionButton

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

func _enter_tree() -> void:
#	if Engine.is_editor_hint():
	yield(get_tree(), "idle_frame")
	global = get_node(Constants.NODE_PATH_GLOBAL)
	if global.is_getting_edited(self):
		return
	set_nodes()
	current_cel = Image.new()
	current_frame = Image.new()
	current_frame.create(global.current_project.size.x, global.current_project.size.y, false, Image.FORMAT_RGBA8)
	preview_image = Image.new()
	preview_texture = ImageTexture.new()
	connect("about_to_show", self, "_about_to_show")
	connect("popup_hide", self, "_popup_hide")
	connect("confirmed", self, "_confirmed")
	if selection_checkbox:
		selection_checkbox.connect("toggled", self, "_on_SelectionCheckBox_toggled")
	if affect_option_button:
		affect_option_button.connect("item_selected", self, "_on_AffectOptionButton_item_selected")


func _about_to_show() -> void:
	current_cel = global.current_project.frames[global.current_project.current_frame].cels[global.current_project.current_layer].image
	current_frame.resize(global.current_project.size.x, global.current_project.size.y)
	current_frame.fill(Color(0, 0, 0, 0))
	var frame = global.current_project.frames[global.current_project.current_frame]
	global.get_export().blend_layers(current_frame, frame)
	if selection_checkbox:
		_on_SelectionCheckBox_toggled(selection_checkbox.pressed)
	else:
		update_preview()
	update_transparent_background_size()


func _confirmed() -> void:
	if affect == CEL:
		global.canvas.handle_undo("Draw")
		commit_action(current_cel, pixels)
		global.canvas.handle_redo("Draw")
	elif affect == FRAME:
		global.canvas.handle_undo("Draw", global.current_project, -1)
		for cel in global.current_project.frames[global.current_project.current_frame].cels:
			commit_action(cel.image, pixels)
		global.canvas.handle_redo("Draw", global.current_project, -1)

	elif affect == ALL_FRAMES:
		global.canvas.handle_undo("Draw", global.current_project, -1, -1)
		for frame in global.current_project.frames:
			for cel in frame.cels:
				commit_action(cel.image, pixels)
		global.canvas.handle_redo("Draw", global.current_project, -1, -1)

	elif affect == ALL_PROJECTS:
		for project in global.projects:
			var _pixels := []
			if selection_checkbox.pressed:
				_pixels = project.selected_pixels.duplicate()
			else:
				for x in project.size.x:
					for y in project.size.y:
						_pixels.append(Vector2(x, y))

			global.canvas.handle_undo("Draw", project, -1, -1)
			for frame in project.frames:
				for cel in frame.cels:
					commit_action(cel.image, _pixels, project)
			global.canvas.handle_redo("Draw", project, -1, -1)


func commit_action(_cel : Image, _pixels : Array, _project : Project = global.current_project) -> void:
	pass


func set_nodes() -> void:
	pass


func _on_SelectionCheckBox_toggled(button_pressed : bool) -> void:
	pixels.clear()
	if button_pressed:
		pixels = global.current_project.selected_pixels.duplicate()
	else:
		for x in global.current_project.size.x:
			for y in global.current_project.size.y:
				pixels.append(Vector2(x, y))

	update_preview()


func _on_AffectOptionButton_item_selected(index : int) -> void:
	affect = index
	update_preview()


func update_preview() -> void:
	match affect:
		CEL:
			preview_image.copy_from(current_cel)
		_:
			preview_image.copy_from(current_frame)
	commit_action(preview_image, pixels)
	preview_texture.create_from_image(preview_image, 0)
	preview.texture = preview_texture


func update_transparent_background_size() -> void:
	if !preview:
		return
	var image_size_y = preview.rect_size.y
	var image_size_x = preview.rect_size.x
	if preview_image.get_size().x > preview_image.get_size().y:
		var scale_ratio = preview_image.get_size().x / image_size_x
		image_size_y = preview_image.get_size().y / scale_ratio
	else:
		var scale_ratio = preview_image.get_size().y / image_size_y
		image_size_x = preview_image.get_size().x / scale_ratio

	preview.get_node("TransparentChecker").rect_size.x = image_size_x
	preview.get_node("TransparentChecker").rect_size.y = image_size_y


func _popup_hide() -> void:
	global.dialog_open(false)
