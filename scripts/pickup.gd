extends Area2D

class_name Pickup

enum ItemType {
	COIN,
	MUSHROOM,
	FIREPLANT,
	ONEUP,
	STAR
}

@export var item_type: ItemType = ItemType.COIN

@export var horizonal_speed = 35
@export var max_vertical_speed = 150
@export var vertical_velocity_gain = 0.1
@onready var shape_cast_2d = $ShapeCast2D
@onready var sound

var allow_horizontal_movement = false
var vertical_speed = 0
var direction = 1
var cooldown = false

func _ready() -> void:
	if ResourceLoad.level == "map1-1":
		sound = get_node("/root/world/Animation Sounds")
	else:
		sound = get_node("/root/" + ResourceLoad.level + "/Animation Sounds")
	
	if item_type != ItemType.COIN:
		var spawn_tween = get_tree().create_tween()
		spawn_tween.tween_property(self, "position", position + Vector2(0, -23), 0.6)
	
		if item_type == ItemType.MUSHROOM || item_type == ItemType.ONEUP || item_type == ItemType.STAR:
			sound.stream = load("res://sounds/item_appear.wav")
			sound.playing = true
			spawn_tween.tween_callback(func (): allow_horizontal_movement = true)
		elif item_type == ItemType.FIREPLANT:
			sound.stream = load("res://sounds/item_appear.wav")
			sound.playing = true
	
func _process(delta: float) -> void:
	if item_type != ItemType.COIN:
		if item_type == ItemType.FIREPLANT:
			$AnimatedSprite2D.play()

		if allow_horizontal_movement:
			if item_type == ItemType.STAR:
				var star_speed = horizonal_speed * 1.4
				position.x += delta * star_speed * direction
			else:
				position.x += delta * horizonal_speed * direction

			if item_type == ItemType.STAR:
				vertical_speed += vertical_velocity_gain * 45
				if vertical_speed > max_vertical_speed:
					vertical_speed = max_vertical_speed
				position.y += delta * vertical_speed

				if shape_cast_2d.is_colliding():
					vertical_speed = -180
			elif item_type == ItemType.MUSHROOM or item_type == ItemType.ONEUP:
				if !shape_cast_2d.is_colliding():
					vertical_speed = lerpf(vertical_speed, max_vertical_speed, vertical_velocity_gain)
					position.y += delta * vertical_speed
				else:
					vertical_speed = 0

			if has_overlapping_areas() and cooldown == false:
				for i in get_overlapping_areas():
					if i.get_parent().name != "Question_Blocks" and i.get_parent().name != "Bricks":
						flip_direction()
						cooldown = true
						break

			if cooldown:
				await get_tree().create_timer(0.2).timeout
				cooldown = false

	else:
		$AnimatedSprite2D.play()

func on_block_below_hit():
	if allow_horizontal_movement and item_type == ItemType.MUSHROOM:
		flip_direction()

func flip_direction():
	if direction == 1:
		direction = -1
	else:
		direction = 1
