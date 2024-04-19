extends Control

var app_name := "Tronchaditor"
var current_file := "Untitled"
var edited := false
var changed := false
var string_array = PackedStringArray(["func", "print"])
@onready var code_editor: CodeEdit = $MarginContainer/VBoxContainer/CodeEdit;
@onready var error_box: Label = $MarginContainer/VBoxContainer/ErrorBox;

func _ready():
	get_tree().set_auto_accept_quit(false)
	update_window_title()
	
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
	DisplayServer.window_set_title(app_name + " - " + current_file.get_file())

func new_file():
	current_file = "Untitled"
	update_window_title()
	code_editor.text = ""
 
func _on_File_pressed(id):
	var item_name = $MenuButtonFile.get_popup().get_item_text(id)
	if item_name == "New File":
		new_file()
	elif item_name == "Open File":
		$OpenFileDialog.popup()
	elif item_name == "Save":
		save_file(current_file)
	elif item_name == "Save as":
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

func _on_open_file_dialog_file_selected(path):
	var f = FileAccess.open(path, FileAccess.READ)
	code_editor.text = f.get_as_text()
	f.close()
	current_file = path
	update_window_title()

func _on_save_file_dialog_file_selected(path):
	save_file(path);

func save_file(path: String) -> void:
	clear_errors()
	if path == "Untitled":
		$SaveFileDialog.popup()
	else:
		var f = FileAccess.open(path, FileAccess.WRITE)
		f.store_string(code_editor.text)
		f.close()
		edited = false
		current_file = path
		update_window_title()


func _on_code_edit_text_changed():
	edited = true


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if edited:
			$ConfirmationDialog.popup()
		else:
			get_tree().quit()


func _on_confirmation_dialog_confirmed():
	get_tree().quit()

func get_virtual_text_position(line_size: int, start: Vector2) -> Vector2:
	return Vector2(line_size, start.y);


func clear_errors() -> void:
	for x in range(code_editor.get_line_count()):
		code_editor.set_line_background_color(x, Color(0, 0, 0, 0))
	error_box.text = "";


func report_error(filename: String, column: int, line: int, message: String) -> void:
	var ln = max(0, line-1)
	code_editor.set_line_background_color(ln, code_editor.colors.error);
	var format_string = "{filename}:{line}:{column}: {message}\n";
	var actual_string = format_string.format({"filename": filename.get_file(), "line": line, "column": column, "message": message});
	error_box.text += actual_string;

const PARSE_ERROR = 1;
func _on_button_pressed():
	clear_errors();
	save_file(current_file);

	var args = ["-file", current_file, "-json-output"];
	var output = [];
	var status = OS.execute("minigo", PackedStringArray(args), output, true);

	if status == PARSE_ERROR:
		var error_data = JSON.parse_string(output[0]);
		if error_data != null:
			for error in error_data:
				report_error(error.fileName, error.column, error.line, error.message);
