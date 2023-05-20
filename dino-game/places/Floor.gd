extends StaticBody2D

func _ready():
	$ColorRect.size = $CollisionShape2D.shape.size
