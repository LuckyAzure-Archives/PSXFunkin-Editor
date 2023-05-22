extends Node

var CurrentAnimation
var SelectedAnimation = 0

func _on_AnimationList_item_selected(index):
	animation = false
	$Animation/Name.text = $AnimationList.get_item_text(index)
	SelectedAnimation = index
	load_anim()

func _process(_delta):
	if CurrentAnimation != null:
		$"Animation Player/Speed".editable = true
		$"Animation Player/Play".disabled = false
		$"Animation Player/Loop".disabled = false
		$"Animation/End".readonly = false
	else:
		$"Animation Player/Speed".editable = false
		$"Animation Player/Play".disabled = true
		$"Animation Player/Loop".disabled = true
		$"Animation/End".readonly = true
	
	if $AnimationList.is_anything_selected():
		$Animation/Remove.disabled = false
	else:
		$Animation/Remove.disabled = true

func _on_New_pressed():
	Global.data.animations.append({"name": $Animation/Name.text,"speed":24,"data":[],"anim_type":-1,"end":"ASCR_BACK, 1","loop":false})
	CurrentAnimation = $Animation/Name.text
	reloadlist()
	load_anim()

func load_anim():
	var data = Global.data.animations[SelectedAnimation]
	
	Global.framesdata = data.data
	$OptionButton.select(data.anim_type)
	CurrentAnimation = data.name
	$"Animation Player/Speed".value = data.speed
	$"Animation Player/Loop".pressed = data.loop
	$"Animation/End".text = data.end
	get_parent().get_node("Frames").reloadlist()
	if Global.framesdata.size() != 0:
		get_parent().get_node("Frames")._reloadoffsets(Global.framesdata[0])
		get_parent().get_node("Frames/FramesList").select(0)

func save_anim():
	for i in Global.data.animations.size():
		if Global.data.animations[i].name == CurrentAnimation:
			Global.data.animations[i].data = Global.framesdata
			Global.data.animations[i].name = $Animation/Name.text
			Global.data.animations[i].speed = $"Animation Player/Speed".value
			Global.data.animations[i].loop = $"Animation Player/Loop".pressed
			Global.data.animations[i].anim_type = $OptionButton.selected
			CurrentAnimation = $Animation/Name.text

func _on_Remove_pressed():
	if Global.data.animations[SelectedAnimation].name == CurrentAnimation:
		CurrentAnimation = null
		Global.framesdata = []
	Global.data.animations.remove(SelectedAnimation)
	reloadlist()

func reloadlist():
	$AnimationList.clear()
	for i in Global.data.animations.size():
		$AnimationList.add_item(str(Global.data.animations[i].name))

var animation = false
var animcooldown = 0
var animframe = 0

var animspeed = 0.1

func _on_Play_pressed():
	get_parent().get_node("Frames")._reloadoffsets(Global.framesdata[0])
	animation = true
	animcooldown = Global.data.animations[SelectedAnimation].speed
	animframe = 0

func _Animation(delta):
	if animation:
		if Global.framesdata.size() - 1 > animframe: 
			animframe += Global.data.animations[SelectedAnimation].speed / 30
		else:
			animation = false
		get_parent().get_node("Frames")._reloadoffsets(Global.framesdata[int(animframe)])
		animcooldown = Global.data.animations[SelectedAnimation].speed


func _on_OptionButton_item_selected(index):
	save_anim()

func _on_Speed_value_changed(value):
	print("aaaa")
	save_anim()

func _on_Loop_toggled(button_pressed):
	save_anim()


func _on_Button_pressed():
	for i in Global.data.animations.size():
		if Global.data.animations[i].name == CurrentAnimation:
			Global.data.animations[i].end = $"Animation/End".text
