class_name FrogEnemy
extends StompableBodyEnemy

@export_node_path("Node2D") var target_path: NodePath
@export var hop_speed: float = 120.0
@export var chase_hop_speed: float = 160.0
@export var detection_distance: float = 260.0
@export var close_detection_distance: float = 80.0
@export var lose_distance: float = 340.0
@export var hop_interval: float = 1.0
@export var chase_hop_interval: float = 0.55
@export var jump_velocity: float = -260.0
@export var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var floor_ray_left: RayCast2D = $FloorRayLeft
@onready var floor_ray_right: RayCast2D = $FloorRayRight
@onready var hitbox: Area2D = $Hitbox
@onready var sight_ray: RayCast2D = $SightRay

var _direction: int = -1
var _target: Node2D
var _state: StringName = "patrol"
var _dead: bool = false
var _hop_timer: float = 0.0
var _flip_next_hop: bool = false

func _ready() -> void:
	_resolve_target()
	_enable_floor_rays()
	_enable_sight_ray()
	if hitbox:
		hitbox.body_entered.connect(_on_body_entered)
		hitbox.area_entered.connect(_on_area_entered)

func _enable_floor_rays() -> void:
	if floor_ray_left:
		floor_ray_left.enabled = true
		floor_ray_left.collision_mask = 2
	if floor_ray_right:
		floor_ray_right.enabled = true
		floor_ray_right.collision_mask = 2

func _enable_sight_ray() -> void:
	if sight_ray:
		sight_ray.enabled = true
		sight_ray.collision_mask = 1

func _physics_process(delta: float) -> void:
	if _dead:
		return
	_apply_gravity(delta)
	_resolve_target()
	_update_state()
	_handle_turns()
	_move(delta)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func _resolve_target() -> void:
	if _target == null and target_path != NodePath("") and has_node(target_path):
		_target = get_node(target_path) as Node2D

func _update_state() -> void:
	if _target == null:
		_state = "patrol"
		return
	var to_target := _target.global_position - global_position
	_update_sight_direction()
	var dist := to_target.length()
	var can_see := _has_line_of_sight(to_target)
	if (can_see and dist <= detection_distance) or dist <= close_detection_distance:
		_state = "chase"
	elif dist >= lose_distance:
		_state = "patrol"

func _handle_turns() -> void:
	var ray := floor_ray_left if _direction < 0 else floor_ray_right
	if ray and (not ray.is_colliding() or is_on_wall()):
		_direction *= -1

func _move(delta: float) -> void:
	_hop_timer = maxf(_hop_timer - delta, 0.0)
	if _state == "chase" and _target:
		_direction = sign(_target.global_position.x - global_position.x)
		if _direction == 0:
			_direction = 1
	var target_speed := hop_speed if _state == "patrol" else chase_hop_speed
	if is_on_floor() and _hop_timer <= 0.0:
		if _flip_next_hop or _wall_ahead() or not _ground_ahead():
			_direction *= -1
			_flip_next_hop = false
		else:
			velocity.y = jump_velocity
			velocity.x = _direction * target_speed
			_hop_timer = hop_interval if _state == "patrol" else chase_hop_interval
	move_and_slide()
	# If we collided with a wall during the hop, flag a flip for the next hop.
	if is_on_wall():
		_flip_next_hop = true

func _update_sight_direction() -> void:
	if sight_ray:
		sight_ray.target_position = Vector2(detection_distance * _direction, 0)

func _has_line_of_sight(to_target: Vector2) -> bool:
	if sight_ray == null:
		return false
	if to_target.x * _direction <= 0:
		return false
	sight_ray.target_position = to_target
	sight_ray.force_raycast_update()
	if not sight_ray.is_colliding():
		return false
	var collider := sight_ray.get_collider()
	return collider == _target or (collider is Node and collider.get_parent() == _target)

func _ground_ahead() -> bool:
	var ray := floor_ray_left if _direction < 0 else floor_ray_right
	return ray != null and ray.is_colliding()

func _wall_ahead() -> bool:
	var offset := Vector2(12 * _direction, 0)
	return test_move(global_transform, offset)

func _on_body_entered(body: Node) -> void:
	if body is Dino:
		_handle_collision(body as Dino)

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Dino:
		_handle_collision(area.get_parent() as Dino)

func _handle_collision(dino: Dino) -> void:
	if _dead:
		return
	if _handle_dino(dino):
		_dead = true
