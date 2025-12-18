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
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var _direction: int = -1
var _target: Node2D
var _state: StringName = "patrol"
var _dead: bool = false
var _hop_timer: float = 0.0
var _flip_next_hop: bool = false
var _was_on_floor: bool = false
var _current_anim: StringName = &""
var _stuck_timer: float = 0.0
const STUCK_THRESHOLD := 0.25
var _locked_dir: int = 1
var _facing: int = 1

func _ready() -> void:
	_resolve_target()
	_enable_floor_rays()
	_enable_sight_ray()
	if hitbox:
		hitbox.body_entered.connect(_on_body_entered)
		hitbox.area_entered.connect(_on_area_entered)
	if anim:
		anim.play("idling")

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
	_update_animation_state()

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
	_stuck_timer = maxf(_stuck_timer - delta, 0.0)
	if _state == "chase" and _target and is_on_floor():
		_direction = sign(_target.global_position.x - global_position.x)
		if _direction == 0:
			_direction = 1
	if not is_on_floor():
		_direction = _locked_dir
	_update_facing()
	var target_speed := hop_speed if _state == "patrol" else chase_hop_speed
	if is_on_floor() and _hop_timer <= 0.0:
		if _flip_next_hop or _wall_ahead() or not _ground_ahead() or _blocked_above_forward():
			_direction *= -1
			_flip_next_hop = false
		else:
			if anim:
				anim.play("jump_prepare")
			velocity.y = jump_velocity
			velocity.x = _direction * target_speed
			_hop_timer = hop_interval if _state == "patrol" else chase_hop_interval
			_locked_dir = _direction
	move_and_slide()
	if is_on_wall():
		velocity.x = 0
		if is_on_floor():
			_direction *= -1
		else:
			_flip_next_hop = true
		_stuck_timer = STUCK_THRESHOLD
	if is_on_ceiling():
		velocity.y = 0
		_flip_next_hop = true
		_hop_timer = 0.0
	if _stuck_timer <= 0.0 and is_on_floor() and absf(velocity.x) < 2.0:
		_direction *= -1
		_stuck_timer = STUCK_THRESHOLD

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

func _blocked_above_forward() -> bool:
	var offset := Vector2(12 * _direction, -12)
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

func _update_animation_state() -> void:
	if anim == null:
		return
	if not is_on_floor():
		_play_anim("jump_midair")
	else:
		if _hop_timer > (hop_interval if _state == "patrol" else chase_hop_interval) * 0.5:
			_play_anim("jump_prepare")
		else:
			_play_anim("idling")

func _update_facing() -> void:
	if anim == null:
		return
	var desired := _direction
	if not is_on_floor():
		desired = _locked_dir
	if _facing == desired:
		return
	_facing = desired
	anim.flip_h = _facing > 0

func _play_anim(name: StringName) -> void:
	if _current_anim == name:
		return
	_current_anim = name
	anim.play(name)
