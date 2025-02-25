extends Camera2D

@export var target: CharacterBody2D  
@export var follow_speed: float = 5.0  

func _ready():

	# 
	make_current()

func _process(delta):
	if target:
		var target_position = target.global_position
		
		global_position = global_position.lerp(target_position, follow_speed * delta)

		global_position.x = clamp(global_position.x, limit_left, limit_right)
		global_position.y = clamp(global_position.y, limit_top, limit_bottom)
