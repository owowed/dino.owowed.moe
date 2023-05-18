extends Label

func _process(delta):
	text = str(get_node("../../Dino").coin)
