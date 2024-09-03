extends CharacterBody2D


const SPEED = 1000.0

func _physics_process(delta: float) -> void:
	var verticalDirection := Input.get_axis("up", "down")
	if verticalDirection:
		velocity.y = verticalDirection * SPEED
	else:
		velocity.y = move_toward(velocity.x, 0, SPEED)

	var horizontalDirection := Input.get_axis("left", "right")
	if horizontalDirection:
		velocity.x = horizontalDirection * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
