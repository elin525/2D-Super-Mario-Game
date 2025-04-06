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
@onready var sound = get_node("/root/map1-2/Animation Sounds")

var allow_horizontal_movement = false
var vertical_speed = 0
var direction = 1
var cooldown = false

func _ready() -> void:
	if item_type != ItemType.COIN:
		var spawn_tween = get_tree().create_tween()
		spawn_tween.tween_property(self, "position", position + Vector2(0, -23), 0.6)
	
		if item_type == ItemType.MUSHROOM || item_type == ItemType.ONEUP:
			sound.stream = load("res://sounds/mushroomappear.wav")
			sound.playing = true
			spawn_tween.tween_callback(func (): allow_horizontal_movement = true)
	
func _process(delta: float) -> void:
	if item_type != ItemType.COIN:
		if allow_horizontal_movement:
			if direction == 1:
				position.x += delta * horizonal_speed
			else:
				position.x -= delta * horizonal_speed
	
		if !shape_cast_2d.is_colliding() && allow_horizontal_movement:
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
			
		if cooldown == true:
			await get_tree().create_timer(2.0).timeout
			cooldown = false
			
	#else
	
func flip_direction():
	if direction == 1:
		direction = -1
	else:
		direction = 1
