extends Node2D

@export var world_player: WorldPlayer
@export var level_label: Label
@export var prompt_label: Label
@export var map_bounds := Rect2(-480, -270, 960, 540)

var _active_node: WorldLevelNode

func _ready() -> void:
	if world_player == null:
		world_player = $WorldPlayer
	for node in get_tree().get_nodes_in_group("world_level_node"):
		if node is WorldLevelNode:
			node.focus_started.connect(_on_node_focus)
			node.focus_ended.connect(_on_node_unfocus)
	_update_ui()

func _process(_delta: float) -> void:
	_clamp_player()
	if _active_node and Input.is_action_just_pressed("world.interact"):
		_enter_level(_active_node)

func _clamp_player() -> void:
	if world_player == null:
		return
	var min := map_bounds.position
	var max := map_bounds.position + map_bounds.size
	world_player.global_position = world_player.global_position.clamp(min, max)

func _on_node_focus(node: WorldLevelNode) -> void:
	_active_node = node
	_update_ui()

func _on_node_unfocus(node: WorldLevelNode) -> void:
	if node == _active_node:
		_active_node = null
	_update_ui()

func _enter_level(node: WorldLevelNode) -> void:
	if not node.is_available():
		return
	get_tree().change_scene_to_file(node.level_scene)

func _update_ui() -> void:
	if level_label:
		level_label.text = _active_node.level_name if _active_node else "Walk up to a level node"
	if prompt_label:
		if _active_node == null:
			prompt_label.visible = false
		elif _active_node.is_available():
			prompt_label.visible = true
			prompt_label.text = "Press Space/Enter to play"
		else:
			prompt_label.visible = true
			prompt_label.text = "Locked"
