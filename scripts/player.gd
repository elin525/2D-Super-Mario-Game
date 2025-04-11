extends CharacterBody2D

signal death

# mario states
enum player_state { SMALL, BIG, FIRE }
var state = player_state.SMALL

const PLAYER_SMALL_COLLISION_SHAPE = preload("res://resources/collisionShapes/player_small_collision_shape.tres")
const PLAYER_BIG_COLLISION_SHAPE = preload("res://resources/collisionShapes/player_big_collision_shape.tres")

# movement variables
const JUMP_VELOCITY = -7 * 32
var gravity = 0.09 * 35
var direction: int

# control state
var is_controllable = true
var is_triggering_scene = false
var is_dying = false
var already_jumped = false
var jump_released = false
var blocks_interacted = 0
var level_up = false
var cooldown = false
var jumped_after_enemy = false

# state prefix for animation
var current_state = "small"

# references
@onready var world = get_node("../..")
@onready var sprite = $AnimatedSprite2D
@onready var area_collision = $Area2D/AreaCollisionShape
@onready var body_collision = $BodyCollisionShape
@onready var sounds = get_node("../../Animation Sounds")
@onready var music = get_node("../../AudioStreamPlayer2D")
@onready var hud = get_node("../../HUD")
@onready var map = get_node("..")
@onready var flag = get_node("../../Flag Pole/Flag")
@onready var flag_area = get_node("../../Flag Pole")

const POINTS_LABEL_SCENE = preload("res://UI/points_label.tscn")
@export_group("Stomping enemies")
@export var min_stomp_degree = 10#35
@export var max_stomp_degree = 170#145
@export var stomp_y_velocity = -150 
@export_group("")

func _ready():
	call_deferred("change_state", player_state.SMALL)
	if ResourceLoad.checkpoint_reached:
		position.x = 162*16
	
	set_player_collision_shape(true)
	
func _physics_process(delta):
	
	if world.death == true:
		return
	
	if position.x < 0:
		position.x = 0
	
	if hud.clock > 0 and is_controllable:
		var input = Input.get_axis("ui_left", "ui_right")
		
		if input > 0:
			direction = 1
		elif input < 0:
			direction = -1
		else:
			direction = 0
		
		apply_gravity()
		handle_jump()
		handle_movement()
		if level_up == false:
			update_animation()
		move_and_slide()
		
		# check for death
		if position.y >= 80:
			die(world)
			
		if position.x >= 162*16:
			ResourceLoad.checkpoint_reached = true
			if ResourceLoad.saved == false:
				ResourceLoad.checkpointReached.emit()
				ResourceLoad.saved = true

		# handle collisions
		handle_collision()
			
	if flag.initial_touched == true:
		handle_flag_animation()

	# flag animation handling
	if is_triggering_scene:
		handle_scene_transition()
		
	if position.x >= 6464:
		end_level()
		
	if Input.is_action_just_pressed("ui_select") and state == player_state.FIRE:
		play_sound("fireball")
		var fireball = preload("res://fireball.tscn").instantiate()
		fireball.global_position = global_position
		get_tree().root.call_deferred("add_child", fireball)

# ---------------- MARIO STATE ---------------- #
func change_state(new_state):
	state = new_state
	match state:
		player_state.SMALL:
			current_state = "small"
			print("small")
		player_state.BIG:
			current_state = "big"
			print("big")
		player_state.FIRE:
			current_state = "fire"
			print("fire")
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
		ResourceLoad.stomped = false
		ResourceLoad.consecutive = 0
		jumped_after_enemy = false

func handle_jump():
	if Input.is_action_just_pressed("ui_up") and is_on_floor() and not already_jumped:
		if state == player_state.SMALL:
			play_sound("jump")
		else:
			play_sound("jumpbig")
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
			flag_area.block_touched = true
			flag.initial_touched = true
			hud.score += 100
			hud.score -= 4000
			var points_label = preload("res://UI/points_label.tscn").instantiate()
			points_label.text = str(100)
			points_label.position = global_position + Vector2(10, 0)
			points_label.setPosition(points_label.position)
			get_tree().root.add_child(points_label)

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
		var fireworks = get_node("../../Fireworks/Fireworks1")

		while hud.clock > 0:
			play_sound("scorering")
			await get_tree().create_timer(0.01).timeout
			hud.clock -= 1
			hud.update_time()
			hud.score += 50
			hud.update_score()
			
		if music.is_playing():
			await flag_area.finished

		await get_tree().create_timer(2).timeout
		fireworks.trigger(offset)
		
		if offset % 10 == 1:
			await fireworks.animation_finished
			await fireworks.finished
		elif offset % 10 == 3:
			await fireworks.get_node("../Fireworks3").animation_finished
			await fireworks.finished
		elif offset % 10 == 6:
			await fireworks.get_node("../Fireworks6").animation_finished
			await fireworks.finished
		
		ResourceLoad.changeLevel()

# ---------------- DAMAGE & DEATH ---------------- #
func hurt():
	if cooldown == false:
		if state == player_state.FIRE:
			call_deferred("change_state", player_state.BIG)
		elif state == player_state.BIG:
			call_deferred("change_state", player_state.SMALL)
			set_player_collision_shape(true)
		else:
			die(get_node("../.."))
			return

	# temporary invincibility
	cooldown = true
	is_controllable = false
	for i in range(5):
		sprite.visible = false
		await get_tree().create_timer(0.2).timeout
		sprite.visible = true
		await get_tree().create_timer(0.2).timeout
	is_controllable = true
	cooldown = false

func die(world):
	var l = ResourceLoad.LiveScene
	
	world.death = true
	
	if is_dying:
		return	

	is_dying = true
	is_controllable = false
	#velocity = Vector2.ZERO
	#set_physics_process(false)
	#set_collision_layer_value(1, false)

	# stop background music and play death sound
	music.playing = false
	play_sound("death")

	# play death animation
	play_animation("death")
	
	# jump up and fall down
	#position.y -= 250
	#await get_tree().create_timer(0.8).timeout
	#position.y += 300
	#await get_tree().create_timer(1.2).timeout
	#await sounds.finished
	var start_position = position
	var up_position = start_position + Vector2(0, -200)
	var down_position = start_position + Vector2(0, 400)
	
	while position.y > up_position.y:
		position.y -= 4
		await get_tree().create_timer(0.01).timeout

	while position.y < down_position.y:
		position.y += 4
		await get_tree().create_timer(0.01).timeout

		#if collision:
			#break
			
	# trigger game over
	
	if sounds.is_playing() == true:
		await sounds.finished
	elif position.y >= 400:
		death.emit()
		return
	
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
	elif direction != 0:
		sprite.flip_h = (direction < 0)
		play_animation("move")
	else:
		play_animation("idle")

# ---------------- LIFE MANAGEMENT ---------------- #
func _on_death() -> void:
	
	var l = ResourceLoad.LiveScene

	if l.lives == 0:
		play_sound("gameover")
		if sounds.is_playing():
			await sounds.finished
		await get_tree().create_timer(0.2).timeout
		var title = load("res://title_screen.tscn").instantiate()
		get_tree().root.add_child(title)
		get_tree().root.remove_child(l)
		l.queue_free()

	var tree = get_tree()
	l.lives -= 1
	l.update_lives()

	tree.root.add_child(l)
	l.triggered = true
	
	var string = ""
	
	if ResourceLoad.level == "map1-1":
		string = "world"
	else:
		string = "map" + str(ResourceLoad.world) + "-" + str(ResourceLoad.completed+1)
		
	var node = "/root/" + string
	
	tree.root.remove_child(get_node(node))

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Enemy:
		handle_enemy_collision(area)
		
	if area is Pickup:
		handle_pickup_collision(area)
		if world.death == true:
			return
		area.queue_free()
	
func handle_enemy_collision(enemy: Enemy):
	if enemy == null:
		return
	
	if is_instance_of(enemy, Koopa) && (enemy as Koopa).in_a_shell:
		(enemy as Koopa).on_stomp(global_position)
	
	else:
		var angle_of_collisison = rad_to_deg(position.angle_to_point(enemy.position))
		
		if angle_of_collisison == null:
			return
	
		if angle_of_collisison > min_stomp_degree && max_stomp_degree > angle_of_collisison and world.death == false: 
			enemy.die()
			on_enemy_stomped()
			spawn_enemy_points_label(enemy)
		else: 
			hurt()

func on_enemy_stomped():
	velocity.y = stomp_y_velocity
	await get_tree().create_timer(0.0001).timeout
	jumped_after_enemy = true
	
func handle_pickup_collision(pickup: Pickup):
	if pickup == null or world.death == true:
		return
		
	if pickup.item_type == pickup.ItemType.COIN:
		sounds.stream = load("res://sounds/coin.wav")
		sounds.playing = true
		hud.score += 200
		hud.update_score()
		var points_label = POINTS_LABEL_SCENE.instantiate()
		points_label.text = "200"
		points_label.position = self.position + Vector2(-20, -20)
		points_label.setPosition(points_label.position)
		get_tree().root.add_child(points_label)
	
	if pickup.item_type == pickup.ItemType.MUSHROOM or pickup.item_type == pickup.ItemType.ONEUP:
		handle_mushroom_collision(pickup)
	
	if pickup.item_type == pickup.ItemType.FIREPLANT:
		handle_fireplant_collision(pickup)
	
func handle_mushroom_collision(pickup: Pickup):
	if pickup.item_type == pickup.ItemType.ONEUP:
		ResourceLoad.LiveScene.lives += 1
		var points_label = POINTS_LABEL_SCENE.instantiate()
		points_label.text = "1-UP"
		points_label.position = pickup.position + Vector2(-20, -20)
		points_label.setPosition(points_label.position)
		get_tree().root.add_child(points_label)
		return
		
	if state == player_state.SMALL:
		sprite.play("level_up")
		level_up = true
		sounds.stream = load("res://sounds/mushroomeat.wav")
		sounds.playing = true
		await sprite.animation_finished
		level_up = false
		call_deferred("change_state", player_state.BIG)
		set_player_collision_shape(false)
		
		hud.score += 500
		hud.update_score()
		var points_label = POINTS_LABEL_SCENE.instantiate()
		points_label.text = "500"
		points_label.position = self.position + Vector2(-20, -20)
		points_label.setPosition(points_label.position)
		get_tree().root.add_child(points_label)

func handle_fireplant_collision(pickup: Pickup):
	if state == player_state.BIG:
		call_deferred("change_state", player_state.FIRE)
		hud.score += 1000
		hud.update_score()
		var points_label = POINTS_LABEL_SCENE.instantiate()
		points_label.text = "1000"
		points_label.position = self.position + Vector2(-20, -20)
		points_label.setPosition(points_label.position)
		get_tree().root.add_child(points_label)
	#elif state == player_state.SMALL:
		#call_deferred("change_state", player_state.BIG)
		#set_player_collision_shape(false)

func spawn_enemy_points_label(enemy):
	var points_label = POINTS_LABEL_SCENE.instantiate()
	if ResourceLoad.consecutive >= ResourceLoad.pointsArray.size():
		points_label.text = "1-UP"
	elif jumped_after_enemy == false and ResourceLoad.consecutive == 1:
		points_label.text = "400"
		enemy.kill_points = 400
	else:
		points_label.text = str(enemy.kill_points)
	points_label.position = enemy.position + Vector2(-20, -20)
	points_label.setPosition(points_label.position)
	get_tree().root.add_child(points_label)
	hud.score += enemy.kill_points
	hud.update_score()

func set_player_collision_shape(is_small: bool):
	var collision_shape = PLAYER_SMALL_COLLISION_SHAPE if is_small else PLAYER_BIG_COLLISION_SHAPE
	area_collision.set_deferred("shape", collision_shape)
	body_collision.set_deferred("shape", collision_shape)
