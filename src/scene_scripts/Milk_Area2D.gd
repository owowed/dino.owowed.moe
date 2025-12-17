extends Area2D

@onready var milk = get_parent()

func _on_area_entered(_area):
	var areas = get_overlapping_areas()
	for area in areas:
		var parent = area.get_parent()
		if parent is Dino:
			(parent as Dino).add_coin()
			milk.queue_free()
			return
	
