extends Area2D

@onready var milk = get_parent()

func _on_area_entered(_area):
	var areas = get_overlapping_areas()
	var dino = areas[0].get_parent() as Dino
	
	dino.add_coin()
	milk.queue_free()
	
