extends Control

var app_name = "Tronchaditor"
var current_file = "Untitled"
var edited: bool = false

func _ready():
	
	get_tree().set_auto_accept_quit(false)
	DisplayServer.window_set_title(app_name + " - " + current_file)
	
	$MenuButtonFile.get_popup().add_item("New File")
	$MenuButtonFile.get_popup().add_item("Open File")
	$MenuButtonFile.get_popup().add_item("Save")
	$MenuButtonFile.get_popup().add_item("Save as")
	$MenuButtonFile.get_popup().add_item("Quit")
	$MenuButtonFile.get_popup().id_pressed.connect(_on_File_pressed)
	
	$MenuButtonHelp.get_popup().add_item("Godot Website")
	$MenuButtonHelp.get_popup().add_item("About")
	$MenuButtonHelp.get_popup().id_pressed.connect(_on_Help_pressed)

func update_window_title():
	DisplayServer.window_set_title(app_name + " - " + current_file)

func new_File():
	current_file = "Untitled"
	update_window_title()
	$CodeEdit.text = ""
 
func _on_File_pressed(id):
	var item_name = $MenuButtonFile.get_popup().get_item_text(id)
	if item_name == "New File":
		new_File()
	elif item_name == "Open File":
		$OpenFileDialog.popup()
	elif item_name == "Save":
		save_file()
	elif item_name == "Save File":
		$SaveFileDialog.popup()
	elif item_name == "Quit":
		_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	elif item_name == "About":
		$AcceptDialog.popup()

func _on_Help_pressed(id):
	var item_name = $MenuButtonHelp.get_popup().get_item_text(id)
	if item_name == "Godot Website":
		OS.shell_open("http://godotengine.org/")
	elif item_name == "About":
		$AcceptDialog.popup()

func _process(delta):
	pass

func _on_open_file_dialog_file_selected(path):
	var f = FileAccess.open(path,1)
	$CodeEdit.text = f.get_as_text()
	f.close()
	current_file = path
	update_window_title()

func _on_save_file_dialog_file_selected(path):
	var f = FileAccess.open(path,2)
	f.store_string($CodeEdit.text)
	f.close()
	edited = false
	current_file = path
	update_window_title()

func save_file():
	var path = current_file
	if path == "Untitled":
		$SaveFileDialog.popup()
	else:
		var f = FileAccess.open(path,2)
		f.store_string($CodeEdit.text)
		f.close()
		current_file = path
		update_window_title()


func _on_code_edit_text_changed():
	edited = true


func _on_tree_exiting():
	if edited:
		$ConfirmationDialog.popup()
		
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if edited:
			$ConfirmationDialog.popup()
		else:
			get_tree().quit()


func _on_confirmation_dialog_confirmed():
	get_tree().quit()
