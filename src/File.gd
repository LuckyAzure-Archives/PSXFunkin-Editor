extends Node

func _on_New_Data_pressed():
	get_parent().get_node("New").popup()

func _on_New_dir_selected(dir):
	var directory = Directory.new()
	var doFileExists = directory.file_exists(dir + "/data.json")
	if doFileExists:
		get_tree().get_current_scene().Error("Data file already exist in this folder")
		return
	Global.path = dir
	var f = File.new()
	f.open(dir + "/data.json", File.WRITE)
	var file_data = {"name":"Char","hb_color":"808080","size":1,"animations":[],"player":false}
	f.store_line(to_json(file_data))
	f.close()
	get_tree().get_current_scene().Load({"name":"Char","hb_color":"808080","size":1,"animations":[],"player":false})

func _on_Load_Data_pressed():
	get_parent().get_node("Load").popup()

func _on_Load_dir_selected(dir):
	var directory = Directory.new()
	var doFileExists = directory.file_exists(dir + "/data.json")
	if !doFileExists:
		get_tree().get_current_scene().Error("Data not found.")
		return
	Global.path = dir
	var f = File.new()
	f.open(dir + "/data.json", File.READ)
	var data = parse_json(f.get_as_text())
	f.close()
	get_tree().get_current_scene().Load(data)


func _on_Save_pressed():
	var f = File.new()
	var err = f.open(Global.path + "/data.json", File.WRITE)
	if err != OK:
		get_tree().get_current_scene().Error("Couldn't save animation file.")
		return
	var file_data = get_tree().get_current_scene().Save()
	f.store_line(to_json(file_data))
	f.close()


