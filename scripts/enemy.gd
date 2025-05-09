extends Area2D

class_name Enemy

enum ColorType {
	NORMAL,
	UNDERGROUD
}

const POINTS_LABEL_SCENE = preload("res://UI/points_label.tscn")

var is_on_screen = false
var direction = -1
var cooldown = false
var shell = false
var once = false
@export var horizontal_speed = 30 
@export var vertical_speed = 100
@export var kill_points = 100
@export var color_type: ColorType = ColorType.NORMAL

@onready var ray_cast_2d = $RayCast2D as RayCast2D
@onready var animated_sprite_2d = $AnimatedSprite2D as AnimatedSprite2D
@onready var camera = get_node("../../TileMap/player/Camera2D")
@onready var world = get_node("../..")
@onready var player = get_node("../../TileMap/player")


func _ready():
	if color_type == ColorType.NORMAL:
		animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.play("walk_dark")
		
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
				if collider.get_parent().get_parent().name == "Bricks" or collider.get_parent().get_parent().name == "Question_Blocks":
					if collider.get_parent().touched == true and once == false:
						die_from_hit()
						once = true
						return
				
		#await get_tree().process_frame		
		
		if isKoopa():
			shell = (self as Koopa).in_a_shell
		
		if has_overlapping_areas() and cooldown == false and shell == false and ray_cast_2d.is_colliding():
			cooldown = true
			for i in get_overlapping_areas():
				if not i is Pickup:
					flip_direction()
					await get_tree().create_timer(1).timeout
					cooldown = false
					break
		elif has_overlapping_areas() and cooldown == false and shell == true:
			for i in get_overlapping_areas():
				if i.get_parent().name != "Enemies" and i.get_parent().name != "player":
					cooldown = true
					flip_direction()
					await get_tree().create_timer(0.5).timeout
					cooldown = false
					break
 
		if self == null or world.death == true:
			return

		if is_inside_tree():
			await get_tree().process_frame

func die():
	horizontal_speed = 0
	vertical_speed = 0 
	if color_type == ColorType.NORMAL:
		animated_sprite_2d.play("dead")
	else:
		animated_sprite_2d.play("dead_dark")
	var sound = get_node("../../Animation Sounds")
	sound.stream = load("res://sounds/smb_stomp.wav")
	sound.playing = true
	
	if ResourceLoad.checkpoint_reached == false:
		ResourceLoad.deadEnemiesList.append(name)
		
	if ResourceLoad.stomped:
		
		ResourceLoad.consecutive += 1
		if ResourceLoad.consecutive >= ResourceLoad.pointsArray.size():
			ResourceLoad.LiveScene.lives += 1
			var points_label = POINTS_LABEL_SCENE.instantiate()
			points_label.position = self.position + Vector2(-20, -20)
			points_label.setPosition(points_label.position)
			get_tree().root.add_child(points_label)
			return
		kill_points = ResourceLoad.pointsArray[ResourceLoad.consecutive]
		
	if not ResourceLoad.stomped:
		ResourceLoad.stomped = true
		
	
	
func die_from_hit():
	
	var pos = position
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(2, false)
	set_collision_mask_value(2, false)
	
	rotation_degrees = 180
	vertical_speed = 0
	horizontal_speed = 0
	
	if ResourceLoad.checkpoint_reached == false:
		ResourceLoad.deadEnemiesList.append(name)
	
	var die_tween = get_tree().create_tween()
	die_tween.tween_property(self, "position", pos + Vector2(0, -30), 0.2)
	die_tween.chain().tween_property(self, "position", pos + Vector2(0, min(pos.y, 30)), 0.2)
	die_tween.tween_callback(self.queue_free)
	
	var points_label = POINTS_LABEL_SCENE.instantiate()
	points_label.text = str(kill_points)
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
	if ResourceLoad.checkpoint_reached and name in ResourceLoad.deadEnemiesList:
		queue_free()
		return
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
