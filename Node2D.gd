extends Node2D

func _Fullscreen():
	# Toggles Fullscreen
	if Input.is_action_just_pressed("ui_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func _process(delta):
	_Fullscreen()
	
	$Camera.CameraMovements(delta)
	$Hud/Frames.OffsetMovements()
	$Texture.Offset($Hud/Frames/Offsets/X.value,$Hud/Frames/Offsets/Y.value,$Hud/Frames/Offsets/W.value,$Hud/Frames/Offsets/H.value)
	$Texture.Position($Hud/Frames/Positions/X.value,$Hud/Frames/Positions/Y.value, $Hud/Character/Size.value)
	Status(delta)

func _physics_process(delta):
	$Hud/Animations._Animation(delta)

func Status(delta):
	$Hud/ErrorText.modulate.a -= 0.25 * delta
	$TextureBack.TextureBack($Texture.position,$Texture.region_rect.size,$Hud/Character/Size.value)
	$Hud/Info.text = "Position: " + str(stepify($Camera.position.x,1)) + ", " + str(stepify($Camera.position.y,1)) + "\n"
	$Hud/Info.text += "Scale: " + str(stepify($Camera.zoom.x * 100,1)) + "%\n"
	$Hud/Info.text += "Animation: " + str($Hud/Animations.CurrentAnimation) + "\n"
	if Global.framesdata.size() == 0:
		$Hud/Frames/Remove.disabled = true
		$Hud/Frames/Replace.disabled = true
		$"Hud/Animations/Animation Player/Play".disabled = true
		
		$Hud/Frames/Up.disabled = true
		$Hud/Frames/Down.disabled = true
	else:
		$"Hud/Animations/Animation Player/Play".disabled = false
		
		if $Hud/Frames/FramesList.is_anything_selected():
			$Hud/Frames/Remove.disabled = false
			$Hud/Frames/Replace.disabled = false
			$Hud/Frames/Up.disabled = false
			$Hud/Frames/Down.disabled = false
		else:
			$Hud/Frames/Remove.disabled = true
			$Hud/Frames/Replace.disabled = true
			$Hud/Frames/Up.disabled = true
			$Hud/Frames/Down.disabled = true

#---------------------------------------------------------------------

func Load(loaddata):
	Global.data = loaddata
	
	#backward compatibility with the older characters
	if !"hb_color" in Global.data:
		get_tree().get_current_scene().Error("This character was made in a older version of this tool.")
		Global.data.merge({"hb_color":"080808"},false)
	if !"size" in Global.data:
		Global.data.merge({"size":1},false)
	if !"player" in Global.data:
		Global.data.merge({"player":false},false)
	
	UnlockButtons()
	$Hud/Character/Name.text = Global.data.name
	$"Hud/Character/HB Color".text = Global.data.hb_color
	$Hud/Character/Size.value = Global.data.size
	$Hud/Character/Player.pressed = Global.data.player
	$Hud/Character._reload(Global.data.player)
	$Hud/Animations.reloadlist()

func Save():
	Global.data.name = $Hud/Character/Name.text
	Global.data.hb_color = $"Hud/Character/HB Color".text
	Global.data.size = $Hud/Character/Size.value
	Global.data.player = $Hud/Character/Player.pressed
	return Global.data

func UnlockButtons():
	$Hud/File/Save.disabled = false
	$Hud/File/Export.disabled = false
	
	$Hud/Character/Name.readonly = false
	$"Hud/Character/HB Color".readonly = false
	$"Hud/Character/Size".editable = true
	
	$Hud/Animations/Animation/New.disabled = false
	$Hud/Animations/Animation/Name.readonly = false

#---------------------------------------------------------------------

func Error(text):
	$Hud/ErrorText.modulate.a = 1
	$Hud/ErrorText.text = text
