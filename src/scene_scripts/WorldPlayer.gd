class_name WorldPlayer
extends CharacterBody2D

@export var speed: float = 220.0
@export var acceleration: float = 12.0

@onready var sprite: Sprite2D = $Sprite2D

var _last_direction := Vector2.RIGHT

func _physics_process(delta: float) -> void:
	var input_direction := Input.get_vector(
		"world.move.left",
		"world.move.right",
		"world.move.up",
		"world.move.down"
	)
	if input_direction.length_squared() > 0:
		_last_direction = input_direction.normalized()
	var target_velocity := Vector2.ZERO
	if input_direction.length_squared() > 0:
		target_velocity = input_direction.normalized() * speed
	velocity = velocity.lerp(target_velocity, clamp(acceleration * delta, 0.0, 1.0))
	move_and_slide()
	_update_sprite(input_direction)

func _update_sprite(input_direction: Vector2) -> void:
	if input_direction.x != 0:
		var base_scale := absf(sprite.scale.x)
		sprite.scale.x = base_scale if input_direction.x >= 0 else -base_scale

func reset_to(target_position: Vector2) -> void:
	global_position = target_position
	velocity = Vector2.ZERO
