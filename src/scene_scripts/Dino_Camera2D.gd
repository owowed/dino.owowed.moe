extends Camera2D

func _process(_delta):
	position = -get_dino_center_pos()
	position.y = -270
	
func get_dino_center_pos():
	return get_viewport_rect().size / zoom / 2
