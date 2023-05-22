extends WindowDialog

func _on_Properties_pressed():
	show()

func _ready():
	var image = Image.new()
	image.load(Global.config.icons)
	var texture = ImageTexture.new()
	texture.create_from_image(image, 0)
	get_node("Icons").texture = texture

func _process(delta):
	$Icons/Normal.rect_position = Vector2($X1.value,$Y1.value)
	$Icons/Normal.rect_size = Vector2($W1.value,$H1.value)
	
	$Icons/Losing.rect_position = Vector2($X2.value,$Y2.value)
	$Icons/Losing.rect_size = Vector2($W2.value,$H2.value)
