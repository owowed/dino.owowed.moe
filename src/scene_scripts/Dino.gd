class_name Dino
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -360.0

const GRAVITY_MULTIPLIER = 2
const CROUCH_GRAVITY_MULTIPLIER = 2
const CROUCH_SPEED_REDUCTION = 0.9
const NO_GRAVITY_REDUCTION = 0.5
const LONG_JUMP_MULTIPLIER = 0.4
const SPRINT_SPEED_MULTIPLIER = 2

const MAX_GRAVITY = 655
const MAX_GRAVITY_CROUCHING = 876

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var spawn_location = position
var died = false
var can_move = true
var can_sprint = OS.is_debug_build()

var crouching = false
var sprinting = false
var moving = false

@export var coin = 0
var deaths = 0
var no_gravity = false
var superspeed = false
var flying = false

signal ten_coin_reached()

func jump():
	if not can_move: return
	velocity.y = JUMP_VELOCITY
	$JumpAudio.play()

func add_coin(num: int = 1):
	coin += num
	
	if coin % 10 == 0:
		$TenPointAudio.play()
		ten_coin_reached.emit()
	else:
		$PointAudio.play()

func _physics_process(delta: float):
	if died: return
	if not is_on_floor():
		process_gravity(delta)
	if Input.is_action_just_pressed("player.jump") and (is_on_floor() or flying):
		jump()

	var direction = Input.get_axis("player.move.left", "player.move.right")
	move(direction)
	
	if position.y > 1000: die()

	move_and_slide()

func process_gravity(delta: float):
	var offset = gravity * GRAVITY_MULTIPLIER
	
	if crouching: offset *= CROUCH_GRAVITY_MULTIPLIER
	if not crouching and Input.is_action_pressed("player.jump"): offset *= LONG_JUMP_MULTIPLIER
	if no_gravity: offset *= NO_GRAVITY_REDUCTION
	
	offset *= delta
	
	velocity.y += offset
	
	if not crouching: velocity.y = min(velocity.y, MAX_GRAVITY)
	else: velocity.y = min(velocity.y, MAX_GRAVITY_CROUCHING)

func move(direction: float):
	sprinting = false
	crouching = false
	
	if not can_move: return
	
	if direction:
		var offset = direction * SPEED
		
		$AnimatedSprite2D.flip_h = direction < 0
		
		if Input.is_action_pressed("player.crouch"):
			if is_on_floor():
				offset *= CROUCH_SPEED_REDUCTION
			crouching = true
			$AnimatedSprite2D.play("crouching")
		else:
			$AnimatedSprite2D.play("running")
		
		if can_sprint and Input.is_action_pressed("player.sprint"):
			sprinting = true
			offset *= SPRINT_SPEED_MULTIPLIER
		
		if superspeed:
			velocity.x += offset
		else:
			velocity.x = offset
	else:
		if is_on_floor() or absf(velocity.x) < absf(SPEED):
			velocity.x = move_toward(velocity.x, 0, SPEED)
		else:
			velocity.x = move_toward(velocity.x, 0, 1)
			
		if Input.is_action_pressed("player.crouch"):
			$AnimatedSprite2D.animation = "crouching"
			$AnimatedSprite2D.frame = 0
			crouching = true
		else:
			$AnimatedSprite2D.play("idling")

	moving = absf(velocity.x) > 0
	$StandingCollision.disabled = crouching
	$CrouchingCollision.disabled = !crouching

func die():
	deaths += 1
	can_move = false
	died = true
	$DieAudio.play()
	$AnimatedSprite2D.play("die")
	await $AnimatedSprite2D.animation_looped
	respawn()
	
func respawn():
	coin = 0
	can_move = true
	died = false
	position = spawn_location
	velocity = Vector2.ZERO
	$AnimatedSprite2D.flip_h = false
	$AnimatedSprite2D.play("idling")
