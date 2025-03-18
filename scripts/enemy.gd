extends Area2D

class_name Enemy

const POINTS_LABEL_SCENE = preload("res://UI/points_label.tscn")

var is_on_screen = false
var direction = -1
var cooldown = false
var shell = false
var once = false
@export var horizontal_speed = 30 
@export var vertical_speed = 100
@export var kill_points = 100

@onready var ray_cast_2d = $RayCast2D as RayCast2D
@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D
@onready var camera = get_node("../../TileMap/player/Camera2D")
@onready var world = get_node("../..")

func _process(delta):
	if is_on_screen:
		
		animated_sprite_2d.flip_h = (direction == 1)
		
		if direction == -1:
			position.x -= delta * horizontal_speed
		else:
			position.x += delta * horizontal_speed
	
		if !ray_cast_2d.is_colliding():
			position.y += delta * vertical_speed
		else:
			var collider = ray_cast_2d.get_collider()
			if collider.is_class("StaticBody2D"):
				if collider.get_parent().touched == true and once == false:
					die_from_hit()
					once = true
					return
				
		#await get_tree().process_frame		
		
		if isKoopa():
			shell = (self as Koopa).in_a_shell
		
		if has_overlapping_areas() and cooldown == false and shell == false and ray_cast_2d.is_colliding():
			cooldown = true
			flip_direction()
			await get_tree().create_timer(1).timeout
			cooldown = false
		elif has_overlapping_areas() and cooldown == false and shell == true:
			for i in get_overlapping_areas():
				if i.get_parent().name != "Enemies" and i.get_parent().name != "player":
					cooldown = true
					flip_direction()
					await get_tree().create_timer(1).timeout
					cooldown = false
					break
 
		if self == null or world.death == true:
			return

		await get_tree().process_frame

func die():
	horizontal_speed = 0
	vertical_speed = 0 
	animated_sprite_2d.play("dead")
	var sound = get_node("../../Animation Sounds")
	sound.stream = load("res://sounds/smb_stomp.wav")
	sound.playing = true
	
func die_from_hit():
	
	var pos = position.y
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(2, false)
	set_collision_mask_value(2, false)
	
	rotation_degrees = 180
	vertical_speed = 0
	horizontal_speed = 0
	
	var die_tween = get_tree().create_tween()
	die_tween.tween_property(self, "position", position + Vector2(0, -30), 0.2)
	die_tween.chain().tween_property(self, "position", position + Vector2(0, min(pos+30, 500)), 4)
	
	var points_label = POINTS_LABEL_SCENE.instantiate()
	points_label.position = self.position + Vector2(-20, -20)
	points_label.setPosition(points_label.position)
	get_tree().root.add_child(points_label)
	
	var HUD = get_node("../../HUD")
	HUD.add_score(kill_points)
	HUD.update_score()
	
	var sound = get_node("../../Animation Sounds")
	sound.stream = load("res://sounds/smb_kick.wav")
	sound.playing = true

func _on_area_entered(area: Area2D) -> void:
	if area is Koopa && (area as Koopa).in_a_shell && (area as Koopa).horizontal_speed != 0:
		die_from_hit()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	is_on_screen = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if position.x < camera.limit_left:
		queue_free()

func flip_direction():
	if direction == -1:
		direction = 1
	else:
		direction = -1

	await get_tree().create_timer(1).timeout

func isKoopa():
	if self == null:
		return false
		
	if self is Koopa:
		return true
	else:
		return false
