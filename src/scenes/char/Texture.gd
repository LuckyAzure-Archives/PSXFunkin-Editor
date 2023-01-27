extends Sprite

func Offset(x,y,w,h):
	region_rect.position = Vector2(x,y)
	region_rect.size = Vector2(w,h)

func Position(x,y,size):
	position = Vector2(-x * size,-y * size)
	scale = Vector2(size,size)
