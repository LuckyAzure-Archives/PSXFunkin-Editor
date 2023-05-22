extends Button

var string

func _ready():
	pass

func _read_template():
	var f = File.new()
	f.open("res://CEconfig/template.c", File.READ)
	f.get_as_text()
	string = f.get_as_text()
	f.close()

func _on_Export_pressed():
	var anims
	var templatename = "template"
	if get_parent().get_parent().get_node("Properties/Player").pressed:
		templatename = "template_player"
		anims = Global.config.PlayerAnim
	else:
		anims = Global.config.CharAnim
	
	var charactername = get_parent().get_parent().get_node("Properties/Name").text
	var Structure = ""
	
	var iconsdata = [
		str(get_parent().get_parent().get_node("Properties/X1").value),
		str(get_parent().get_parent().get_node("Properties/Y1").value),
		str(get_parent().get_parent().get_node("Properties/W1").value),
		str(get_parent().get_parent().get_node("Properties/H1").value),
		str(get_parent().get_parent().get_node("Properties/X2").value),
		str(get_parent().get_parent().get_node("Properties/Y2").value),
		str(get_parent().get_parent().get_node("Properties/W2").value),
		str(get_parent().get_parent().get_node("Properties/H2").value)
	]
	
	var IconsHere = "	{" + iconsdata[0] + "," + iconsdata[1] + "," + iconsdata[2] + "," + iconsdata[3] + "},\n	{" + iconsdata[4] + "," + iconsdata[5] + "," + iconsdata[6] + "," + iconsdata[7] + "}"
	var TextureHere = ""
	var FramesHere = ""
	var AnimationsHere = ""
	var HB_Color = get_parent().get_parent().get_node("Properties/HB Color").text
	var CharSize = get_parent().get_parent().get_node("Properties/Size").value * 100
	var Focus_X = get_parent().get_parent().get_node("Properties/Focus X").value
	var Focus_Y = get_parent().get_parent().get_node("Properties/Focus Y").value
	var Focus_Zoom = get_parent().get_parent().get_node("Properties/Focus Zoom").value * 100
	
	var f = File.new()
	f.open("res://CEconfig/" + templatename + ".c", File.READ)
	f.get_as_text()
	var cfile = f.get_as_text()
	f.close()
	f.open("res://CEconfig/" + templatename + ".h", File.READ)
	f.get_as_text()
	var hfile = f.get_as_text()
	f.close()
	
	
	var file_data = ""
	var texturefiles = []
	var framescount = 0
	
	for i in Global.data.animations.size():
		var framesdata = Global.data.animations[i].data
		for j in framesdata.size():
			FramesHere += "	{" + charactername + "_ArcMain_" + framesdata[j][0] + ",{" 
			FramesHere += str(framesdata[j][1][0]) + "," + str(framesdata[j][1][1]) + "," + str(framesdata[j][1][2]) + "," + str(framesdata[j][1][3]) + "},{"
			FramesHere += str(framesdata[j][2][0]) + "," + str(framesdata[j][2][1]) + "}}, //" + str(framescount) + " " + Global.data.animations[i].name + "\n"
			
			framescount += 1
			
			
			var foundtexture = false
			for l in texturefiles.size():
				if texturefiles[l] == framesdata[j][0]:
					foundtexture = true
			if !foundtexture:
				texturefiles.append(framesdata[j][0])
		FramesHere += "	\n"
	for i in anims.size():
		var exist = false
		framescount = 0
		for j in Global.data.animations.size():
			var framesdata = Global.data.animations[j].data
			var frames = ""
			for k in framesdata.size():
				frames += str(framescount) + ", "
				framescount += 1
			if Global.data.animations[j].anim_type == i:
				exist = true
				AnimationsHere += "	{" + str(Global.data.animations[j].speed) + ", (const u8[]){ " + frames + " " + Global.data.animations[j].end + "}},		//" + anims[i] + "\n"
		if !exist:
			AnimationsHere += "	{0, (const u8[]){ASCR_CHGANI, CharAnim_Idle}},		//" + anims[i] + "\n"
	for i in texturefiles.size():
		Structure += "	" + charactername + "_ArcMain_" + texturefiles[i] + ",\n"
	for i in texturefiles.size():
		TextureHere += "		\"" + texturefiles[i] + ".tim\",\n"
	
	file_data += "iso/characters/" + charactername.to_lower() + "/main.arc: "
	for i in texturefiles.size():
		file_data += "iso/characters/" + charactername.to_lower() + "/" + texturefiles[i] + ".tim "
	file_data += "\n\n"
	
	#template.h
	
	#<CharacterName>
	hfile = hfile.replace("<CharacterName>",charactername)
	#<CHARACTERNAME>
	hfile = hfile.replace("<CHARACTERNAME>",charactername.to_upper())
	
	#template.c Editing
	
	#<charactername>
	cfile = cfile.replace("<charactername>",charactername.to_lower())
	#<CharacterName>
	cfile = cfile.replace("<CharacterName>",charactername)
	#<CHARACTERNAME>
	cfile = cfile.replace("<CHARACTERNAME>",charactername.to_upper())
	#<StructureHere>
	cfile = cfile.replace("<StructureHere>",Structure)
	#<IconsHere>
	cfile = cfile.replace("<IconsHere>",IconsHere)
	#<FramesHere>
	cfile = cfile.replace("<FramesHere>",FramesHere)
	#<AnimationsHere>
	cfile = cfile.replace("<AnimationsHere>",AnimationsHere)
	#<TextureHere>
	cfile = cfile.replace("<TextureHere>",TextureHere)
	#<HB Color>
	cfile = cfile.replace("<HB Color>",HB_Color)
	#<CharSize>
	cfile = cfile.replace("<CharSize>",str(CharSize))
	#<Focus X>
	cfile = cfile.replace("<Focus X>",str(Focus_X))
	#<Focus Y>
	cfile = cfile.replace("<Focus Y>",str(Focus_Y))
	#<Focus Zoom>
	cfile = cfile.replace("<Focus Zoom>",str(Focus_Zoom))
	
	var err = f.open(Global.config.output + "/" + charactername.to_lower() + "/" + charactername.to_lower() + ".c", File.WRITE)
	if err != OK:
		get_tree().get_current_scene().Error("Couldn't save animation file.")
		return
	f.store_string(cfile)
	f.close()
	
	err = f.open(Global.config.output + "/" + charactername.to_lower() + "/" + charactername.to_lower() + ".h", File.WRITE)
	if err != OK:
		get_tree().get_current_scene().Error("Couldn't save animation file.")
		return
	f.store_string(hfile)
	f.close()
	
	err = f.open(Global.path + "/" + charactername.to_lower() + ".char", File.WRITE)
	if err != OK:
		get_tree().get_current_scene().Error("Couldn't save animation file.")
		return
	f.store_string(file_data)
	f.close()
	
	print(hfile)
