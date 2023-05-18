class_name Dino
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var coin = 0

var crouching = false
var running = false

func _physics_process(delta):
	if not is_on_floor():
		process_gravity(delta)

	if Input.is_action_just_pressed("player.jump") and is_on_floor():
		jump()

	var direction = Input.get_axis("player.move.left", "player.move.right")
	move(direction)
			
	move_and_slide()

func process_gravity(delta):
	velocity.y += gravity * delta

func add_coin(num: int = 1):
	coin += num
	$PointAudio.play()

func jump():
	velocity.y = JUMP_VELOCITY
	$JumpAudio.play()
	
func move(direction):
	if direction:
		velocity.x = direction * SPEED
		
		$AnimatedSprite2D.flip_h = direction < 0
		
		if Input.is_action_pressed("player.crouch"):
			$AnimatedSprite2D.play("crouching")
		else:
			$AnimatedSprite2D.play("running")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
		if Input.is_action_pressed("player.crouch"):
			$AnimatedSprite2D.animation = "crouching"
			$AnimatedSprite2D.frame = 0
		else:
			$AnimatedSprite2D.play("idling")

		

