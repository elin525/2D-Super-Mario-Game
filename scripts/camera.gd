extends Camera2D

@export var target: CharacterBody2D
@export var follow_speed: float = 4.0
@export var offset_x: float = 40  # viewside
@export var map_left_boundary: float = -44

var furthest_x: float = 0  # player furthest x position


func _ready():
	make_current()
	
	if target == null:
		var parent = get_parent()
		if parent is CharacterBody2D:
			target = parent

func _process(delta):
	if target:
		var target_position = target.global_position

		# mark the further x position on the left side, and update it
		if target_position.x > furthest_x:
			furthest_x = target_position.x
			limit_left = max(furthest_x - get_viewport_rect().size.x / 2 / zoom.x + offset_x, map_left_boundary)

		# follow player smoothly
		global_position.x = move_toward(global_position.x, target_position.x, follow_speed * delta)
		global_position.y = move_toward(global_position.y, target_position.y, follow_speed * delta)

		# limit camer moving range
		global_position.x = clamp(global_position.x, limit_left, limit_right)
		global_position.y = clamp(global_position.y, limit_top, limit_bottom)

		# if player want to go back, mario will hit the wall
		if target.global_position.x < limit_left:
			target.position.x = limit_left
			target.velocity.x = max(target.velocity.x, 0)
