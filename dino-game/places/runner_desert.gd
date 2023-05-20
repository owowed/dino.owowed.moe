class_name RunnerDesert
extends Node2D

const Milk = preload("res://entities/milk.tscn")

const MAX_MILK = 3000

var cvar = {
	"extreme_milk_spawner": false,
	"dino_sprint_enabled": false,
	"inc_coin": false,
	"inc_ten_coin": false
}

var spawned_milks: Array[Milk] = []

@onready var dino_last_pos = Vector2($Dino.position)

func _process(delta):
	if spawned_milks.size() < MAX_MILK and cvar.get("extreme_milk_spawner"):
		var vec = Vector2(randf_range(-1500, 1500), randf_range(-100, 0))
		
		var milk = Milk.instantiate()
		
		spawned_milks.append(milk)
		
		milk.position = dino_last_pos + vec
		add_child(milk)

	$Dino.can_sprint = cvar.get("dino_sprint_enabled")
	
	if cvar.get("inc_coin"):
		$Dino.add_coin(1)
	if cvar.get("inc_ten_coin"):
		$Dino.add_coin(10)
	
