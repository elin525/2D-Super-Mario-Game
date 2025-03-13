extends CharacterBody2D

signal death

# mario states
enum { SMALL, BIG, FIRE }
var state = SMALL

# movement variables
const JUMP_VELOCITY = -7 * 32
var gravity = 0.09 * 35

# control state
var is_controllable = true
var is_triggering_scene = false
var is_dying = false
var already_jumped = false
var jump_released = false

# state prefix for animation
var current_state = "small"

# references
@onready var sprite = $AnimatedSprite2D
@onready var sounds = get_node("../../Animation Sounds")
@onready var music = get_node("../../AudioStreamPlayer2D")
@onready var time = get_node("../../HUD")
@onready var map = get_node("..")
@onready var flag = get_node("../../Area2D/Flag")

func _ready():
	change_state(SMALL)

func _physics_process(delta):
	if position.x < 0:
		position.x = 0

	var world = get_node("../..")
	
	if time.clock > 0 and is_controllable:
		apply_gravity()
		handle_jump()
		handle_movement()
		update_animation()
		move_and_slide()
		
		# check for death
		if position.y >= 80:
			die(world)

		# handle collisions
		handle_collision()
			
	if flag.initial_touched == true:
		handle_flag_animation()

	# flag animation handling
	if is_triggering_scene:
		handle_scene_transition()
		
	if position.x >= 6464:
		end_level()

# ---------------- MARIO STATE ---------------- #
func change_state(new_state):
	state = new_state
	match state:
		SMALL:
			current_state = "small"
		BIG:
			current_state = "big"
		FIRE:
			current_state = "fire"
	update_animation()

# ---------------- MOVEMENT ---------------- #
func apply_gravity():
	
	if not is_on_floor():
		if Input.is_action_just_released("ui_up") and position.y <= 0:
			jump_released = true
			velocity.y += gravity * 3
		elif jump_released:
			velocity.y += gravity * 3
		else:
			velocity.y += gravity
	else:
		already_jumped = false
		jump_released = false

func handle_jump():
	if Input.is_action_just_pressed("ui_up") and is_on_floor() and not already_jumped:
		play_sound("jump")
		velocity.y = JUMP_VELOCITY
		already_jumped = true

func handle_movement():
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction > 0:
		velocity.x = max(velocity.x + 0.038 * 32, 2.0 * 32)
	elif direction < 0:
		velocity.x = min(velocity.x - 0.038 * 32, -2.0 * 32)
	else:
		velocity.x = move_toward(velocity.x, 0, 0.06 * 32)

# ---------------- COLLISIONS ---------------- #
func handle_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider.is_in_group("enemies"):
			if position.y < collider.position.y:
				collider.queue_free()
				velocity.y = JUMP_VELOCITY * 0.5
				#play_sound("kill_mob")
			else:
				hurt()
				
	if is_on_wall() and position.x > 6240 and position.x < 6288:
			flag.initial_touched = true
			time.score += 100
			time.score -= 4000

# ---------------- FLAG & LEVEL END ---------------- #
func handle_flag_animation():
	
	if is_controllable:
		set_position(Vector2(6275, -305))
		set_velocity(Vector2(0, 300))

	is_controllable = false
	play_animation("end")
	move_and_slide()

	if position.y >= -50:
		sprite.flip_h = (position.y >= -50)
		position.x = 6300
		flag.initial_touched = true
		await get_tree().create_timer(0.5).timeout
		is_triggering_scene = true

func handle_scene_transition():
	velocity.x = 160
	velocity.y += gravity
	sprite.flip_h = (position.y < -33)
	play_animation("move")
	move_and_slide()
	

func end_level():
	is_triggering_scene = false
	if sprite != null:
		sprite.queue_free()
		var offset = time.clock
		var fireworks = get_node("../../Fireworks1")

		while time.clock > 0:
			play_sound("scorering")
			await get_tree().create_timer(0.01).timeout
			time.clock -= 1
			time.update_time()
			time.score += 50
			time.update_score()

		await get_tree().create_timer(2).timeout
		fireworks.trigger(offset)

# ---------------- DAMAGE & DEATH ---------------- #
func hurt():
	if state == FIRE:
		change_state(BIG)
	elif state == BIG:
		change_state(SMALL)
	else:
		die(get_node("../.."))
		return

	# temporary invincibility
	is_controllable = false
	for i in range(5):
		sprite.visible = false
		await get_tree().create_timer(0.2).timeout
		sprite.visible = true
		await get_tree().create_timer(0.2).timeout
	is_controllable = true

func die(world):
	if is_dying:
		return

	is_dying = true
	is_controllable = false

	# stop background music and play death sound
	music.playing = false
	play_sound("death")

	# play death animation
	play_animation("death")
	
	# jump up and fall down
	var start_position = position
	var up_position = start_position + Vector2(0, -200)
	var down_position = start_position + Vector2(0, 400)
	
	while position.y > up_position.y:
		position.y -= 4
		await get_tree().create_timer(0.01).timeout
		
	while position.y < down_position.y:
		position.y += 4
		await get_tree().create_timer(0.01).timeout

	# trigger game over
	world.death = true
	death.emit()

# ---------------- UTILITIES ---------------- #
func play_animation(sprite_name):
	var full_sprite_name = current_state + "_" + sprite_name
	sprite.play(full_sprite_name)

func play_sound(sound_name):
	sounds.stream = load("res://sounds/" + sound_name + ".wav")
	sounds.playing = true

func update_animation():
	if is_dying:
		return
	if already_jumped:
		play_animation("jump")
	elif velocity.x != 0:
		sprite.flip_h = (velocity.x < 0)
		play_animation("move")
	else:
		play_animation("idle")

# ---------------- LIFE MANAGEMENT ---------------- #
func _on_death() -> void:
	var l = ResourceLoad.LiveScene

	if l.lives == 0:
		play_sound("gameover")
		return

	ResourceLoad.world = self.duplicate()

	var tree = get_tree()
	l.lives -= 1
	l.update_lives()

	tree.root.add_child(l)
	l.triggered = true
	tree.root.remove_child(get_node("/root/world"))
