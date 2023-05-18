extends Label

func _process(delta):
	text = str(get_owner().get_node("Dino").coin)
