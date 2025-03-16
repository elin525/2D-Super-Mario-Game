extends Enemy

class_name Koopa

var in_a_shell = false

const IN_SHELL_OFFSET = 8
const KOOPA_SHELL_COLLISION_SHAPE_POSITION = Vector2(0, 10)
const KOOPA_FULL_COLLISION_SHAPE = preload("res://resources/collisionShapes/koopa_full_collision_shape.tres")
const KOOPA_SHELL_COLLISION_SHAPE = preload("res://resources/collisionShapes/koopa_shell_collision_shape.tres")

@onready var collision_shape_2d = $CollisionShape2D

@export var slide_speed = 200

func _ready() -> void:
	collision_shape_2d.shape = KOOPA_FULL_COLLISION_SHAPE
	kill_points = 150

func die():
	if !in_a_shell:
		super.die()
	
	collision_shape_2d.set_deferred("shape", KOOPA_SHELL_COLLISION_SHAPE)
	collision_shape_2d.set_deferred("position", KOOPA_SHELL_COLLISION_SHAPE_POSITION)
	animated_sprite_2d.offset.y = IN_SHELL_OFFSET
	in_a_shell = true

func on_stomp(player_position: Vector2):
	set_collision_mask_value(1, false)
	set_collision_layer_value(1, false)
	
	var movement_direction = 1 if player_position.x <= global_position.x else - 1
	horizontal_speed = -movement_direction * slide_speed
	
	var sound = get_node("../../Animation Sounds")
	sound.stream = load("res://sounds/smb_kick.wav")
	sound.playing = true
