extends Node

var texturename
var listselected

func _on_Load_Texture_pressed():
	var directory = Directory.new()
	var doFileExists = directory.file_exists(Global.path + "/" + $Texture/Name.text + ".png")
	if !doFileExists:
		get_tree().get_current_scene().Error("Couldn't load texture file.")
		return
	# Texture Load (as an image)
	texturename = $Texture/Name.text
	var image = Image.new()
	image.load(Global.path + "/" + $Texture/Name.text + ".png")
	var texture = ImageTexture.new()
	texture.create_from_image(image, 0)
	get_tree().get_current_scene().get_node("Texture").texture = texture
	$Offsets/X.value = 0
	$Offsets/Y.value = 0
	$Offsets/W.value = get_tree().get_current_scene().get_node("Texture").texture.get_width()
	$Offsets/H.value = get_tree().get_current_scene().get_node("Texture").texture.get_height()

func _reloadoffsets(data):
	var directory = Directory.new()
	var doFileExists = directory.file_exists(Global.path + "/" + data[0] + ".png")
	if !doFileExists:
		get_tree().get_current_scene().Error("Couldn't load texture file.")
		return
	# Texture Load (as an image)
	var image = Image.new()
	image.load(Global.path + "/" + data[0] + ".png")
	var texture = ImageTexture.new()
	texture.create_from_image(image, 0)
	get_tree().get_current_scene().get_node("Texture").texture = texture
	$Offsets/X.value = data[1][0]
	$Offsets/Y.value = data[1][1]
	$Offsets/W.value = data[1][2]
	$Offsets/H.value = data[1][3]
	$Positions/X.value = data[2][0]
	$Positions/Y.value= data[2][1]
	texturename = data[0]

func _on_FramesList_item_selected(index):
	listselected = index
	_reloadoffsets(Global.framesdata[index])

func _on_Add_pressed():
	var data = [
		texturename,
	[
		$Offsets/X.value,
		$Offsets/Y.value,
		$Offsets/W.value,
		$Offsets/H.value
	],[
		$Positions/X.value,
		$Positions/Y.value
	]]
	Global.framesdata.append(data)
	reloadlist()
	get_parent().get_node("Animations").save_anim()

func _on_Remove_pressed():
	Global.framesdata.remove(listselected)
	reloadlist()
	get_parent().get_node("Animations").save_anim()

func _on_Replace_pressed():
	Global.framesdata[listselected] = [
		texturename,
	[
		$Offsets/X.value,
		$Offsets/Y.value,
		$Offsets/W.value,
		$Offsets/H.value
	],[
		$Positions/X.value,
		$Positions/Y.value
	]]
	reloadlist()
	$FramesList.select(listselected)
	get_parent().get_node("Animations").save_anim()

func reloadlist():
	$FramesList.clear()
	if Global.framesdata.size() == 0:
		return
	for i in Global.framesdata.size():
		$FramesList.add_item(str(Global.framesdata[i]))

func _process(_delta):
	var CurrentAnimation = get_parent().get_node("Animations").CurrentAnimation
	if CurrentAnimation != null:
		$Texture/Load.disabled = false
		$Texture/Name.readonly = false
		$Add.disabled = false
	else:
		$Texture/Load.disabled = true
		$Texture/Name.readonly = true
		$Add.disabled = true
	
	if $FramesList.is_anything_selected():
		$Remove.disabled = false
		$Replace.disabled = false
		$Up.disabled = false
		$Down.disabled = false
	else:
		$Remove.disabled = true
		$Replace.disabled = true
		$Up.disabled = true
		$Down.disabled = true

func OffsetMovements():
	var speed = 1
	if Input.is_action_pressed("offset_shift"):
		speed = 10
	if Input.is_action_just_pressed("offset_left") and $Positions/X.value > -500:
		$Positions/X.value += 1 * speed
	elif Input.is_action_just_pressed("offset_right") and $Positions/X.value < 500:
		$Positions/X.value -= 1 * speed
	if Input.is_action_just_pressed("offset_up") and $Positions/Y.value > -500:
		$Positions/Y.value += 1 * speed
	elif Input.is_action_just_pressed("offset_down") and $Positions/Y.value < 500:
		$Positions/Y.value -= 1 * speed
