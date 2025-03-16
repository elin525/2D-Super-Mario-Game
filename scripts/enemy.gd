extends Area2D

class_name Enemy 

const POINTS_LABEL_SCENE = preload("res://UI/points_label.tscn")

var is_on_screen = false
var direction = -1
var cooldown = false
var just_on_screen = true
@export var horizontal_speed = 30 
@export var vertical_speed = 100
@export var kill_points = 100

@onready var ray_cast_2d = $RayCast2D as RayCast2D
@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D

func _process(delta):
	if is_on_screen:
		
		if direction == -1:
			position.x -= delta * horizontal_speed
		else:
			position.x += delta * horizontal_speed
	
		if !ray_cast_2d.is_colliding():
			if just_on_screen:
				position.y += delta * vertical_speed
			if just_on_screen == false and cooldown == false:
				cooldown = true
				flip_direction()
				await get_tree().create_timer(4).timeout
				cooldown = false
			just_on_screen = false
 
		await get_tree().process_frame
		if has_overlapping_areas() and cooldown == false:
			cooldown = true
			flip_direction()
			await get_tree().create_timer(1).timeout
			cooldown = false

func die():
	horizontal_speed = 0
	vertical_speed = 0 
	animated_sprite_2d.play("dead")
	var sound = get_node("../../Animation Sounds")
	sound.stream = load("res://sounds/smb_stomp.wav")
	sound.playing = true
	
func die_from_hit():
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(2, false)
	set_collision_mask_value(2, false)
	
	rotation_degrees = 180
	vertical_speed = 0
	horizontal_speed = 0
	
	var die_tween = get_tree().create_tween()
	die_tween.tween_property(self, "position", position + Vector2(0, -30), 0.2)
	die_tween.chain().tween_property(self, "position", position + Vector2(0, 500), 4)
	
	var points_label = POINTS_LABEL_SCENE.instantiate()
	points_label.position = self.position + Vector2(-20, -20)
	get_tree().root.add_child(points_label)
	
	var sound = get_node("../../Animation Sounds")
	sound.stream = load("res://sounds/smb_kick.wav")
	sound.playing = true

func _on_area_entered(area: Area2D) -> void:
	if area is Koopa && (area as Koopa).in_a_shell && (area as Koopa).horizontal_speed != 0:
		die_from_hit()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	is_on_screen = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func flip_direction():
	if direction == -1:
		direction = 1
	else:
		direction = -1

	await get_tree().create_timer(1).timeout
