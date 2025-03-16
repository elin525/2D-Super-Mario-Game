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
@onready var world = get_node("../..")
@onready var sprite = $AnimatedSprite2D
@onready var sounds = get_node("../../Animation Sounds")
@onready var music = get_node("../../AudioStreamPlayer2D")
@onready var hud = get_node("../../HUD")
@onready var map = get_node("..")
@onready var flag = get_node("../../Area2D/Flag")

const POINTS_LABEL_SCENE = preload("res://UI/points_label.tscn")
@export_group("Stomping enemies")
@export var min_stomp_degree = 20#35
@export var max_stomp_degree = 130#145
@export var stomp_y_velocity = -150 
@export_group("")

func _ready():
	change_state(SMALL)

func _physics_process(delta):
	
	if position.x < 0:
		position.x = 0
	
	if hud.clock > 0 and is_controllable:
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
			hud.score += 100
			hud.score -= 4000

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
		var offset = hud.clock
		var fireworks = get_node("../../Fireworks1")

		while hud.clock > 0:
			play_sound("scorering")
			await get_tree().create_timer(0.01).timeout
			hud.clock -= 1
			hud.update_time()
			hud.score += 50
			hud.update_score()

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
	var l = ResourceLoad.LiveScene
	
	if is_dying:
		return

	world.death = true

	is_dying = true
	is_controllable = false
	#velocity = Vector2.ZERO
	#set_physics_process(false)
	#set_collision_layer_value(1, false)

	# stop background music and play death sound
	music.playing = false
	if l.lives > 0:
		play_sound("death")
	else:
		play_sound("gameover")

	# play death animation
	play_animation("death")
	
	# jump up and fall down
	#position.y -= 250
	#await get_tree().create_timer(0.8).timeout
	#position.y += 300
	#await get_tree().create_timer(1.2).timeout
	var start_position = position
	var up_position = start_position + Vector2(0, -200)
	var down_position = start_position + Vector2(0, 400)
	
	while position.y > up_position.y:
		var collision = move_and_collide(Vector2(0, -4))
		await get_tree().create_timer(0.01).timeout
		if collision:
			break
	
	while position.y < down_position.y:
		var collision = move_and_collide(Vector2(0,4))
		await get_tree().create_timer(0.01).timeout
		if collision:
			break

	# trigger game over
	await sounds.finished
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
		return

	ResourceLoad.world = self.duplicate()

	var tree = get_tree()
	l.lives -= 1
	l.update_lives()

	tree.root.add_child(l)
	l.triggered = true
	tree.root.remove_child(get_node("/root/world"))


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Enemy:
		handle_enemy_collision(area)
		
func handle_enemy_collision(enemy: Enemy):
	if enemy == null:
		return
	
	if is_instance_of(enemy, Koopa) && (enemy as Koopa).in_a_shell:
		(enemy as Koopa).on_stomp(global_position)
	
	else:
		var angle_of_collisison = rad_to_deg(position.angle_to_point(enemy.position))
	
		if angle_of_collisison > min_stomp_degree && max_stomp_degree > angle_of_collisison: 
			enemy.die()
			on_enemy_stomped()
			spawn_points_label(enemy)
		else: 
			die(world)

func on_enemy_stomped():
	velocity.y = stomp_y_velocity
	
func spawn_points_label(enemy):
	var points_label = POINTS_LABEL_SCENE.instantiate()
	points_label.text = str(enemy.kill_points)
	points_label.position = enemy.position + Vector2(-20, -20)
	get_tree().root.add_child(points_label)
	hud.score += enemy.kill_points
	hud.update_score()
