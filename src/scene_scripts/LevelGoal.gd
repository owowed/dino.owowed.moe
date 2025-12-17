class_name LevelGoal
extends Area2D

@export var require_interact: bool = false

var _player_inside := false
var _triggered := false

signal goal_reached

func _ready() -> void:
	add_to_group("level_goal")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if _triggered:
		return
	if require_interact:
		if _player_inside and Input.is_action_just_pressed("ui_accept"):
			_trigger()
	elif _player_inside:
		_trigger()

func _on_body_entered(body: Node) -> void:
	if body is Dino:
		_player_inside = true

func _on_body_exited(body: Node) -> void:
	if body is Dino:
		_player_inside = false

func _trigger() -> void:
	_triggered = true
	goal_reached.emit()
