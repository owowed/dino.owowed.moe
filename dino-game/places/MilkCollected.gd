extends Control

@onready var dino: Dino = get_owner().get_node("Dino")
@onready var labels = $HBoxContainer.get_children()

func _ready():
	dino.ten_coin_reached.connect(func():
		for label in labels:
			label.add_theme_color_override("font_color", Color.GREEN)

		get_tree().create_timer(1.0).timeout.connect(func():
			for label in labels:
				label.remove_theme_color_override("font_color")
		)
	)

func _process(delta):
	$HBoxContainer/MilkCounter.text = str(dino.coin)
	
