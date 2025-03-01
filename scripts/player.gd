extends CharacterBody2D

var already_jumped = false

const JUMP_VELOCITY = -7*32

var gravity = 0.09*32

var controllable = true

var trigger_scene = false

@onready var animated_sprite_2d = $AnimatedSprite2D

func _physics_process(delta):
	
	var time = get_node("../../HUD")
	
	var flag = get_node("../Area2D2/Flag")
	
	if time.clock > 0 and controllable == true:
		if not is_on_floor():
			velocity.y += gravity
		else:
			already_jumped = false
			
		if Input.is_action_just_pressed("ui_up") and is_on_floor() and not already_jumped:
			velocity.y = JUMP_VELOCITY
			already_jumped = true
			
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction > 0:
			velocity.x = max(velocity.x + 0.038*32, 2.0*32)
		elif direction < 0:
			velocity.x = min(velocity.x - 0.038*32, -2.0*32)
		else:
			velocity.x = move_toward(velocity.x, 0, 0.06*32)
			
		update_animation(direction)
		move_and_slide()
		
		if is_on_wall() and position.x > 6240 and position.x < 6288:
			flag.initial_touched = true
	
	if flag.initial_touched == true:
		if controllable:
			set_position(Vector2(6275, -305))
			set_velocity(Vector2(0,60))
			
		controllable = false
		animated_sprite_2d.play("small_end")
		move_and_slide()
		if position.y >= -48:
			animated_sprite_2d.flip_h = (position.y >= -48)
			position.x = 6300
			flag.initial_touched = false
			await get_tree().create_timer(0.5).timeout
			trigger_scene = true
		
	if trigger_scene == true:	
		velocity.x = 160
		velocity.y += gravity
		animated_sprite_2d.flip_h = (position.y < -33)
		animated_sprite_2d.play("small_move")
		move_and_slide()
			
	if position.x >= 6464:
		trigger_scene = false
		if animated_sprite_2d != null:
			animated_sprite_2d.queue_free()
			var offset = time.clock
			var fireworks = get_node("../../Fireworks1")
			while time.clock != 0:
				await get_tree().create_timer(0.1).timeout
				time.clock -= 1
				time.update_time()
			
			await get_tree().create_timer(2.0).timeout
			
			fireworks.trigger(offset)
			
			
	

func update_animation(direction):
	if already_jumped:
		animated_sprite_2d.play("small_jump")
	elif direction != 0:
		animated_sprite_2d.flip_h = (direction < 0)
		animated_sprite_2d.play("small_move")
	else:
		animated_sprite_2d.play("small_mario")
