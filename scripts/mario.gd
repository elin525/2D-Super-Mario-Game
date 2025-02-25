extends CharacterBody2D

class_name Player

enum PlayerMode{
	SMALL,
	BIG,
	SHOOTING
}

var is_jumping = false

const SPEED = 200.0
const JUMP_VELOCITY = -350.0

# Get the gravity from the project seetings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var area_collision_shape = $Area2D/AreaCollisionShape
@onready var body_collision_shape = $Area2D/BodyCollisionShape


func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false
	
	# Handle Jump
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		
	# Get the input direction and handle the movement/deceleration
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	update_animation(direction)
	move_and_slide()
	
func update_animation(direction):
		
	if is_jumping:
		animated_sprite_2d.play("smalll_jump")
	elif direction != 0:
		animated_sprite_2d.flip_h = (direction < 0)
		animated_sprite_2d.play("small_move")
	else:
		animated_sprite_2d.play("small_mario")
