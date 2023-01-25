extends SpinBox

func _process(_delta):
	if get_global_mouse_position().y < 540:
		release_focus()
