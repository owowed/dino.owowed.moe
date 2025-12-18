class_name GroundEnemy
extends CharacterBody2D

@export_node_path("Node2D") var target_path: NodePath
@export var patrol_speed: float = 60.0
@export var dash_speed: float = 180.0
@export var detection_distance: float = 260.0
@export var lose_distance: float = 340.0
@export var jump_velocity: float = -260.0
@export var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var floor_ray_left: RayCast2D = $FloorRayLeft
@onready var floor_ray_right: RayCast2D = $FloorRayRight
@onready var hitbox: Area2D = $Hitbox
@onready var sight_ray: RayCast2D = $SightRay

var _direction: int = -1
var _target: Node2D
var _state: StringName = "patrol"

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
	if _has_line_of_sight(to_target) and to_target.length() <= detection_distance:
		_state = "chase"
	elif to_target.length() >= lose_distance:
		_state = "patrol"

func _handle_turns() -> void:
	var ray := floor_ray_left if _direction < 0 else floor_ray_right
	if ray and (not ray.is_colliding() or is_on_wall()):
		_direction *= -1

func _move(delta: float) -> void:
	if _state == "chase" and _target:
		_direction = sign(_target.global_position.x - global_position.x)
		if _direction == 0:
			_direction = 1
	else:
		_update_sight_direction()
	var target_speed := dash_speed if _state == "chase" else patrol_speed
	velocity.x = _direction * target_speed
	if _state == "chase" and is_on_floor():
		velocity.y = jump_velocity
	move_and_slide()

func _update_sight_direction() -> void:
	if sight_ray:
		sight_ray.target_position = Vector2(detection_distance * _direction, 0)

func _has_line_of_sight(to_target: Vector2) -> bool:
	if sight_ray == null:
		return false
	sight_ray.target_position = to_target
	sight_ray.force_raycast_update()
	if not sight_ray.is_colliding():
		return false
	var collider := sight_ray.get_collider()
	return collider == _target or (collider is Node and collider.get_parent() == _target)

func _on_body_entered(body: Node) -> void:
	if body is Dino:
		_handle_dino(body as Dino)

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Dino:
		_handle_dino(area.get_parent() as Dino)

func _handle_dino(dino: Dino) -> void:
	if dino.crouching:
		queue_free()
		return
	var stomp := dino.global_position.y < global_position.y - 6 and dino.velocity.y > 0.0
	if stomp:
		queue_free()
		dino.velocity.y = dino.JUMP_VELOCITY * 0.35
	else:
		dino.die()
