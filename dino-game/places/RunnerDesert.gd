class_name RunnerDesert
extends Node2D

const Milk = preload("res://entities/Milk.tscn")
const Dino = preload("res://entities/Dino.tscn")

@onready var dino_last_pos = $Dino.position

var levelvar = LevelVar.new({
	"spawn_random_milk": TYPE_INT,
	"spawn_random_milka": TYPE_STRING,
	"clearmilk": TYPE_BOOL,
	"dino_coin": TYPE_INT,
	"dino_sprint": [TYPE_BOOL, false],
	"no_gravity": [TYPE_BOOL, false],
	"superspeed": [TYPE_BOOL, false],
	"flying": [TYPE_BOOL, false],
	"quit": [TYPE_BOOL, false],
	"tp": TYPE_STRING,
	"tpr": TYPE_STRING,
	"spawn": TYPE_BOOL,
	"respawn": TYPE_BOOL,
	"resetvar": TYPE_STRING,
	"camera_zoom": TYPE_FLOAT,
	"camera_offset_x": TYPE_FLOAT,
	"camera_offset_y": TYPE_FLOAT,
	"levelvar_bind": [TYPE_BOOL, true]
})

func _ready():
	levelvar.levelvar_changed.connect(command_handler)
	
	print($Dino.position, $Dino/Camera2D.position)
	
func _process(delta):
	if levelvar.get_var("levelvar_bind"):
		$Dino.can_sprint = levelvar.get_var("dino_sprint")
		$Dino.no_gravity = levelvar.get_var("no_gravity")
		$Dino.superspeed = levelvar.get_var("superspeed")
		$Dino.flying = levelvar.get_var("flying")
		$Dino/Camera2D.offset = Vector2(
			levelvar.get_var("camera_offset_x"),
			levelvar.get_var("camera_offset_y"))

func command_handler(name, value):
	match name:
		"spawn_random_milk":
			spawn_random_milk(
				[-1500, 1500],
				[-100, 0],
				value)
		"spawn_random_milka":
			var xyz = value.split(",")
			if xyz.size() < 5: return
			spawn_random_milk(
				[float(xyz[0]), float(xyz[1])],
				[float(xyz[2]), float(xyz[3])],
				int(xyz[4]))
		"dino_coin":
			$Dino.coin = value
		"tp":
			var xy = value.split(",")
			if xy.size() < 2: return
			$Dino.position = Vector2(float(xy[0]), float(xy[1]))
		"tpr":
			var xy = value.split(",")
			if xy.size() < 2: return
			$Dino.position += Vector2(float(xy[0]), float(xy[1]))
		"spawn":
			$Dino.position = dino_last_pos
		"clearmilk":
			for child in $Milks.get_children():
				child.queue_free()
		"camera_zoom":
			$Dino/Camera2D.zoom = Vector2(value, value)
		"quit":
			get_tree().quit()
		"resetvar":
			levelvar.reset_var(value)

func spawn_random_milk(x: Array[float], y: Array[float], amount: int):
	for i in range(0, amount):
		var vec = Vector2(randf_range(x[0], x[1]), randf_range(y[0], y[1]))
		var milk = Milk.instantiate()
		
		milk.position = $Dino.position + vec
		$Milks.add_child(milk)
