class_name WorldLevelNode
extends Area2D

@export_file("*.tscn") var level_scene: String
@export var level_name: String = "Level"
@export var unlocked: bool = true

@onready var label: Label = $Label
@onready var icon: Sprite2D = $Sprite2D

signal focus_started(node: WorldLevelNode)
signal focus_ended(node: WorldLevelNode)

func _ready() -> void:
	add_to_group("world_level_node")
	label.text = level_name
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_visual_state()

func is_available() -> bool:
	return unlocked and level_scene != ""

func _on_body_entered(body: Node) -> void:
	if body is WorldPlayer:
		focus_started.emit(self)

func _on_body_exited(body: Node) -> void:
	if body is WorldPlayer:
		focus_ended.emit(self)

func _update_visual_state() -> void:
	icon.modulate = Color.WHITE if unlocked else Color(0.6, 0.6, 0.6, 0.9)
	label.modulate = Color.WHITE if unlocked else Color(0.7, 0.7, 0.7, 0.8)
