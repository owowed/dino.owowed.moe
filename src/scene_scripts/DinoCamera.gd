extends Camera2D

@export_node_path("Node2D") var target_path: NodePath = ".."
@export var smooth_speed: float = 4.0
@export var lead_strength: float = 0.12
@export var lead_follow_speed: float = 3.0
@export var max_lead: float = 80.0
@export var vertical_offset: float = -40.0
@export var pixel_snap: bool = true

var _target: Node2D
var _lead_x := 0.0

func _ready() -> void:
	top_level = true
	_resolve_target()
	make_current()

func _physics_process(delta: float) -> void:
	# Run follow logic in sync with physics to avoid jitter from mixed update rates.
	_update_target(delta)

func _update_target(delta: float) -> void:
	if _target == null:
		_resolve_target()
		return
	var target_pos := _target.global_position + Vector2(0, vertical_offset)
	var vel := Vector2.ZERO
	if _target is CharacterBody2D:
		vel = (_target as CharacterBody2D).velocity
	_lead_x = lerp(
		_lead_x,
		clamp(vel.x * lead_strength, -max_lead, max_lead),
		clamp(lead_follow_speed * delta, 0.0, 1.0)
	)
	target_pos.x += _lead_x
	var new_pos := global_position.lerp(
		target_pos,
		clamp(smooth_speed * delta, 0.0, 1.0)
	)
	if pixel_snap:
		new_pos = new_pos.round()
	global_position = new_pos

func _resolve_target() -> void:
	if has_node(target_path):
		_target = get_node(target_path) as Node2D
