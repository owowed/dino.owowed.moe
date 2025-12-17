class_name LevelBase
extends Node2D

const Milk = preload("res://entities/Milk.tscn")

@export var dino: Dino
@export var main_camera: Camera2D

@onready var levelvar = LevelVar.new({
	"spawn_random_milk": TYPE_INT,
	"spawn_random_milk_advanced": TYPE_STRING,
	"spawn_random_milka": TYPE_STRING,
	"spwrm": TYPE_INT,
	"spwrma": TYPE_STRING,
	"clearmilk": TYPE_BOOL,
	"dino_coin": TYPE_INT,
	"dino_sprint": [TYPE_BOOL, false],
	"no_gravity": [TYPE_BOOL, false],
	"superspeed": [TYPE_BOOL, false],
	"flying": [TYPE_BOOL, false],
	"quit": [TYPE_BOOL, false],
	"pause": [TYPE_BOOL, false],
	"teleport": TYPE_STRING,
	"teleport_relative": TYPE_STRING,
	"tp": TYPE_STRING,
	"tpr": TYPE_STRING,
	"spawn": TYPE_BOOL,
	"resetvar": TYPE_STRING,
	"resetvel": TYPE_BOOL,
	"camera_zoom": TYPE_FLOAT,
	"camera_zoom_x": [TYPE_FLOAT, main_camera.zoom.x],
	"camera_zoom_y": [TYPE_FLOAT, main_camera.zoom.y],
	"camera_offset_x": TYPE_FLOAT,
	"camera_offset_y": TYPE_FLOAT,
	"levelvar_bind": [TYPE_BOOL, true],
	"die": TYPE_BOOL,
	"debuginfo": [TYPE_STRING, "levelvar"]
})

func _ready():
	levelvar.levelvar_changed.connect(command_handler)

func _process(_delta):
	if levelvar.get_var("levelvar_bind"):
		dino.can_sprint = levelvar.get_var("dino_sprint")
		dino.no_gravity = levelvar.get_var("no_gravity")
		dino.superspeed = levelvar.get_var("superspeed")
		dino.flying = levelvar.get_var("flying")
		main_camera.offset = Vector2(
			levelvar.get_var("camera_offset_x"),
			levelvar.get_var("camera_offset_y"))
		main_camera.zoom = Vector2(
			levelvar.get_var("camera_zoom_x"),
			levelvar.get_var("camera_zoom_y"))


func command_handler(name, value):
	match name:
		"spawn_random_milk", "spwrm":
			spawn_random_milk(
				[-1500, 1500],
				[-100, 0],
				value)
		"spawn_random_milka", "spawn_random_milk_advanced", "spwrma":
			var xyz = value.split(",")
			if xyz.size() < 5: return
			spawn_random_milk(
				[float(xyz[0]), float(xyz[1])],
				[float(xyz[2]), float(xyz[3])],
				int(xyz[4]))
		"dino_coin":
			dino.coin = value
		"teleport", "tp":
			var xy = value.split(",")
			if xy.size() < 2: return
			dino.position = Vector2(float(xy[0]), float(xy[1]))
		"teleportr", "teleport_relative", "tpr":
			var xy = value.split(",")
			if xy.size() < 2: return
			dino.position += Vector2(float(xy[0]), float(xy[1]))
		"spawn":
			dino.respawn()
		"clearmilk":
			for child in $Milks.get_children():
				child.queue_free()
		"camera_zoom":
			levelvar.set_var("camera_zoom_x", value)
			levelvar.set_var("camera_zoom_y", value)
		"camera_zoom_x", "camera_zoom_y":
			if value == 0:
				levelvar.set_var("camera_zoom_x", 1.5)
				levelvar.set_var("camera_zoom_y", 1.5)
		"quit":
			get_tree().quit()
		"pause":
			get_tree().paused = levelvar.get_var("pause")
		"resetvar":
			levelvar.reset_var(value)
		"resetvel":
			dino.velocity = Vector2.ZERO
		"die":
			dino.die()

func spawn_random_milk(x: Array[float], y: Array[float], amount: int):
	for i in range(0, amount):
		var vec = Vector2(randf_range(x[0], x[1]), randf_range(y[0], y[1]))
		var milk = Milk.instantiate()

		milk.position = dino.position + vec
		$Milks.add_child(milk)
