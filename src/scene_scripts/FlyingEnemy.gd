class_name FlyingEnemy
extends StompableAreaEnemy

@export var speed: float = 90.0
@export var travel_distance: float = 220.0
@export var vertical_bob_amplitude: float = 8.0
@export var bob_speed: float = 2.5

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _origin: Vector2
var _direction: int = 1
var _time: float = 0.0
var _dead: bool = false
var _travelled: float = 0.0

func _ready() -> void:
	_origin = global_position
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	if sprite:
		sprite.play("flying")
		_update_sprite_direction()

func _physics_process(delta: float) -> void:
	if _dead:
		return
	_time += delta
	var step := speed * delta * _direction
	_travelled += step
	if abs(_travelled) >= travel_distance:
		var overflow: float = abs(_travelled) - travel_distance
		_direction *= -1
		_travelled = sign(_direction) * overflow
		step = speed * delta * _direction
		_update_sprite_direction()
	global_position.x += step
	var bob := sin(_time * bob_speed) * vertical_bob_amplitude
	global_position.y = _origin.y + bob

func _on_body_entered(body: Node) -> void:
	if _dead:
		return
	if body is Dino:
		_handle_dino(body as Dino)

func _on_area_entered(area: Area2D) -> void:
	if _dead:
		return
	if area.get_parent() is Dino:
		_handle_dino(area.get_parent() as Dino)

func _die() -> void:
	_dead = true
	queue_free()

func _update_sprite_direction() -> void:
	if sprite:
		sprite.flip_h = _direction > 0
