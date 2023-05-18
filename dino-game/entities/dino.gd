extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("player.jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$JumpAudio.play()

	var direction = Input.get_axis("player.move.left", "player.move.right")
	if direction:
		velocity.x = direction * SPEED
		
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
			
	move_and_slide()
