extends Camera2D

@onready var dino = get_parent()
#@onready var viewport_rect = get_viewport_rect()
@onready var viewport_transform_scale = get_viewport_transform().get_scale()
#@onready var centered_to_dino = viewport_rect.size.x / viewport_transform_scale.x / 2

func _process(delta):
	position.x = -center_dino()
	position.y = -270
	
func center_dino():
	return get_viewport_rect().size.x / viewport_transform_scale.x / 2
