extends Node

func _on_Player_toggled(button_pressed):
	_reload(button_pressed)

func _reload(pressed):
	get_parent().get_node("Animations/OptionButton").clear()
	if pressed:
		for i in Global.config.PlayerAnim.size():
			get_parent().get_node("Animations/OptionButton").add_item(Global.config.PlayerAnim[i])
	else:
		for i in Global.config.CharAnim.size():
			get_parent().get_node("Animations/OptionButton").add_item(Global.config.CharAnim[i])

