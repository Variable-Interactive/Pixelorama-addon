tool
extends ConfirmationDialog

var frame_num
var frame_dur

var Constants = preload("res://addons/pixelorama/src/Autoload/Constants.gd")

var global

func _enter_tree():
	frame_num = $VBoxContainer/GridContainer/FrameNum
	frame_dur = $VBoxContainer/GridContainer/FrameTime
	global = get_node(Constants.NODE_PATH_GLOBAL)
	if global.is_getting_edited(self):
		return

func set_frame_label(frame : int) -> void:
	frame_num.set_text(str(frame + 1))

func set_frame_dur(duration : float) -> void:
	frame_dur.set_value(duration)	

func _on_FrameProperties_popup_hide() -> void:
	global.dialog_open(false)


func _on_FrameProperties_confirmed():
	var frame : int = int(frame_num.get_text())
	var duration : float = frame_dur.get_value()
	var frame_duration = global.current_project.frame_duration.duplicate()
	frame_duration[frame - 1] = duration 

	global.current_project.undos += 1
	global.current_project.undo_redo.create_action("Change frame duration")

	global.current_project.undo_redo.add_do_property(global.current_project, "frame_duration", frame_duration)
	global.current_project.undo_redo.add_undo_property(global.current_project, "frame_duration", global.current_project.frame_duration)

	global.current_project.undo_redo.add_do_method(global, "redo")
	global.current_project.undo_redo.add_undo_method(global, "undo")
	global.current_project.undo_redo.commit_action()
