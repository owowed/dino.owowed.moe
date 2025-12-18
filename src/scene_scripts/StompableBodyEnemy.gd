class_name StompableBodyEnemy
extends CharacterBody2D

@export var crouch_kills: bool = true
@export var stomp_threshold: float = 8.0
@export var bounce_multiplier: float = 0.35
@export var stomp_sound: AudioStream = preload("res://audio/stomp.wav")
@onready var stomp_audio: AudioStreamPlayer2D = $StompAudio

func _handle_dino(dino: Dino) -> bool:
	if crouch_kills and dino.crouching:
		_die_with_sound()
		return true
	var stomp: bool = dino.global_position.y < global_position.y - stomp_threshold and dino.velocity.y > 0.0
	if stomp:
		dino.velocity.y = dino.JUMP_VELOCITY * bounce_multiplier
		_die_with_sound()
		return true
	dino.die()
	return false

func _die_with_sound() -> void:
	if stomp_audio:
		stomp_audio.stream = stomp_sound
		stomp_audio.play()
	_die()

func _die() -> void:
	queue_free()
