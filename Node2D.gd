extends Node2D

func _Fullscreen():
	# Toggles Fullscreen
	if Input.is_action_just_pressed("ui_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

var framesdata = []

func _process(delta):
	_Fullscreen()
	
	_Animation(delta)
	CameraMovements(delta)
	OffsetMovements()
	Offset()
	Status()

func Status():
	$Hud/Texts/Scale.text = "Position: " + str(stepify($Camera.position.x,1)) + ", " + str(stepify($Camera.position.y,1)) 
	$Hud/Texts/Scale.text += "\nScale: " + str(stepify($Camera.zoom.x * 100,1)) + "%"
	$ColorRect.rect_position = $Texture.position
	$ColorRect.rect_size.x = $Texture.region_rect.size.x
	$ColorRect.rect_size.y = $Texture.region_rect.size.y

func CameraMovements(delta):
	if Input.is_action_pressed("camera_left") and $Camera.position.x > -500:
		$Camera.position.x -= 200 * delta
	elif Input.is_action_pressed("camera_right") and $Camera.position.x < 500:
		$Camera.position.x += 200 * delta
	else:
		$Camera.position.x = stepify($Camera.position.x,10)
	if Input.is_action_pressed("camera_up") and $Camera.position.y > -500:
		$Camera.position.y -= 200 * delta
	elif Input.is_action_pressed("camera_down") and $Camera.position.y < 500:
		$Camera.position.y += 200 * delta
	else:
		$Camera.position.y = stepify($Camera.position.y,10)
	if Input.is_action_pressed("camera_zoom_out") and $Camera.zoom.x < 2:
		$Camera.zoom.x += 0.5 * delta
		$Camera.zoom.y += 0.5 * delta
	elif Input.is_action_pressed("camera_zoom_in") and $Camera.zoom.x > 0.2:
		$Camera.zoom.x -= 0.5 * delta
		$Camera.zoom.y -= 0.5 * delta
	else:
		$Camera.zoom.x = stepify($Camera.zoom.x,0.1)
		$Camera.zoom.y = stepify($Camera.zoom.y,0.1)

func OffsetMovements():
	var speed = 1
	if Input.is_action_pressed("offset_shift"):
		speed = 10
	if Input.is_action_just_pressed("offset_left") and $Texture.position.x > -500:
		$Texture.position.x -= 1 * speed
	elif Input.is_action_just_pressed("offset_right") and $Texture.position.x < 500:
		$Texture.position.x += 1 * speed
	if Input.is_action_just_pressed("offset_up") and $Texture.position.y > -500:
		$Texture.position.y -= 1 * speed
	elif Input.is_action_just_pressed("offset_down") and $Texture.position.y < 500:
		$Texture.position.y += 1 * speed

#---------------------------------------------------------------------

var path

func _on_Load_Folder_pressed():
	$"Hud/Popups/Popup(Load)".popup()

func _on_PopupLoad_dir_selected(dir):
	path = dir
	$"Hud/Texts/Animation Name".readonly = false
	$"Hud/Buttons/Load Animation".disabled = false
	$"Hud/Buttons/Save Animation".disabled = false
	$"Hud/Texts/Texture Name".readonly = false
	$"Hud/Buttons/Load Texture".disabled = false

#---------------------------------------------------------------------

var texturename

func _on_Load_Texutre_pressed():
	texturename = $"Hud/Texts/Texture Name".text
	# Texture Load (as an image)
	var image = Image.new()
	image.load(path + "/" + $"Hud/Texts/Texture Name".text + ".png")
	var texture = ImageTexture.new()
	texture.create_from_image(image, 0)
	$Texture.texture = texture
	$Hud/Texts/X.text = str(0)
	$Hud/Texts/Y.text = str(0)
	$Hud/Texts/W.text = str($Texture.texture.get_width())
	$Hud/Texts/H.text = str($Texture.texture.get_height())

#---------------------------------------------------------------------

func _on_Load_Animation_pressed():
	var f = File.new()
	var err = f.open(path + "/" + $"Hud/Texts/Animation Name".text + ".txt", File.READ)
	if err != OK:
		printerr("Could not open file, error code ", err)
		return ""
	var data = parse_json(f.get_as_text())
	f.close()
	framesdata = data.data
	reloadlist()

func _on_Save_Animation_pressed():
	var f = File.new()
	var err = f.open(path + "/" + $"Hud/Texts/Animation Name".text + ".txt", File.WRITE)
	if err != OK:
		printerr("Could not write file, error code ", err)
		return
	var file_data = {"data": framesdata}
	f.store_line(to_json(file_data))
	f.close()

#---------------------------------------------------------------------

func _on_Add_Frame_pressed():
	var data = [texturename,
	[$Texture.region_rect.position.x,$Texture.region_rect.position.y,$Texture.region_rect.size.x,$Texture.region_rect.size.y],
	[-$Texture.position.x,-$Texture.position.y]
	]
	framesdata.append(data)
	reloadlist()

func _on_Remove_Frame_pressed():
	framesdata.remove(listselected)
	reloadlist()

func _on_Replace_Frame_pressed():
	framesdata[listselected] = [texturename,
	[$Texture.region_rect.position.x,$Texture.region_rect.position.y,$Texture.region_rect.size.x,$Texture.region_rect.size.y],
	[-$Texture.position.x,-$Texture.position.y]
	]
	reloadlist()
	$Hud/Texts/FramesList.select(listselected)

func reloadlist():
	$Hud/Texts/FramesList.clear()
	for i in framesdata.size():
		$Hud/Texts/FramesList.add_item(str(framesdata[i]))

#---------------------------------------------------------------------

var offsets

func Offset():
	$Texture.region_rect.position.x = int($Hud/Texts/X.text)
	$Texture.region_rect.position.y = int($Hud/Texts/Y.text)
	$Texture.region_rect.size.x = int($Hud/Texts/W.text)
	$Texture.region_rect.size.y = int($Hud/Texts/H.text)

#---------------------------------------------------------------------

var listselected

func _on_FramesList_item_selected(index):
	listselected = index
	_reloadoffsets(framesdata[index])

#---------------------------------------------------------------------

func _reloadoffsets(data):
	# Texture Load (as an image)
	var image = Image.new()
	image.load(path + "/" + data[0] + ".png")
	var texture = ImageTexture.new()
	texture.create_from_image(image, 0)
	$Texture.texture = texture
	$Hud/Texts/X.text = str(data[1][0])
	$Hud/Texts/Y.text = str(data[1][1])
	$Hud/Texts/W.text = str(data[1][2])
	$Hud/Texts/H.text = str(data[1][3])
	$Texture.position.x = -data[2][0]
	$Texture.position.y = -data[2][1]
	texturename = data[0]

#---------------------------------------------------------------------

var animation = false
var animcooldown = 0
var animframe = 0

var animspeed = 0.1

func _on_Play_pressed():
	_reloadoffsets(framesdata[0])
	animation = true
	animcooldown = animspeed
	animframe = 0

func _Animation(delta):
	if animation:
		if animcooldown > 0:
			animcooldown -= delta
		else:
			if framesdata.size() - 1 > animframe: 
				animframe += 1
			else:
				animation = false
			_reloadoffsets(framesdata[animframe])
			animcooldown = animspeed

func _on_Export_C_pressed():
	var f = File.new()
	var err = f.open(path + "/" + $"Hud/Texts/Animation Name".text + ".c", File.WRITE)
	if err != OK:
		printerr("Could not write file, error code ", err)
		return
	var file_data = ""
	var animatname = "Char"
	for i in framesdata.size():
		file_data += "	{" + animatname + "_ArcMain_" + framesdata[i][0] + ",{" 
		file_data += str(framesdata[i][1][0]) + "," + str(framesdata[i][1][1]) + "," + str(framesdata[i][1][2]) + "," + str(framesdata[i][1][3]) + "},{"
		file_data += str(framesdata[i][2][0]) + "," + str(framesdata[i][2][1]) + "}},\n"
	print(file_data)
	f.store_string(file_data)
	f.close()
