extends Camera2D

func CameraMovements(delta):
	if Input.is_action_pressed("camera_left") and position.x > -500:
		position.x -= 200 * delta
	elif Input.is_action_pressed("camera_right") and position.x < 500:
		position.x += 200 * delta
	else:
		position.x = stepify(position.x,10)
	if Input.is_action_pressed("camera_up") and position.y > -500:
		position.y -= 200 * delta
	elif Input.is_action_pressed("camera_down") and position.y < 500:
		position.y += 200 * delta
	else:
		position.y = stepify(position.y,10)
	if Input.is_action_pressed("camera_zoom_out") and zoom.x < 2:
		zoom.x += 0.5 * delta
		zoom.y += 0.5 * delta
	elif Input.is_action_pressed("camera_zoom_in") and zoom.x > 0.2:
		zoom.x -= 0.5 * delta
		zoom.y -= 0.5 * delta
	else:
		zoom.x = stepify(zoom.x,0.1)
		zoom.y = stepify(zoom.y,0.1)
