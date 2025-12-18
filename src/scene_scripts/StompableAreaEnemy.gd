class_name StompableAreaEnemy
extends Area2D

@export var crouch_kills: bool = true
@export var stomp_threshold: float = 4.0
@export var bounce_multiplier: float = 0.5
@export var stomp_sound: AudioStream = preload("res://audio/stomp.wav")
@onready var stomp_audio: AudioStreamPlayer2D = $StompAudio

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _on_body_entered(body: Node) -> void:
	if body is Dino:
		_handle_dino(body as Dino)

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Dino:
		_handle_dino(area.get_parent() as Dino)

func _handle_dino(dino: Dino) -> void:
	if crouch_kills and dino.crouching:
		_die_with_sound()
		return
	var stomp := dino.global_position.y < global_position.y - stomp_threshold and dino.velocity.y > 0.0
	if stomp:
		dino.velocity.y = dino.JUMP_VELOCITY * bounce_multiplier
		_die_with_sound()
	else:
		dino.die()

func _die_with_sound() -> void:
	if stomp_audio:
		stomp_audio.stream = stomp_sound
		stomp_audio.play()
	_die()

func _die() -> void:
	queue_free()
