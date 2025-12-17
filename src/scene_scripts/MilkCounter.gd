extends Control

@onready var dino: Dino = get_owner().get_node("Dino")
@onready var labels = $HBoxContainer.get_children()

func _process(_delta):
	$HBoxContainer/MilkCounter.text = str(dino.coin)
	
func _on_dino_ten_coin_reached():
	for label in labels:
		label.add_theme_color_override("font_color", Color.GREEN)

	get_tree().create_timer(1.0).timeout.connect(func():
		for label in labels:
			label.remove_theme_color_override("font_color")
	)
