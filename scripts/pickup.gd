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

var allow_horizontal_movement = false
var vertical_speed = 0

func _ready() -> void:
	if item_type != ItemType.COIN:
		var spawn_tween = get_tree().create_tween()
		spawn_tween.tween_property(self, "position", position + Vector2(0, -23), 0.6)
	
		if item_type == ItemType.MUSHROOM || item_type == ItemType.ONEUP:
			spawn_tween.tween_callback(func (): allow_horizontal_movement = true)
	
func _process(delta: float) -> void:
	if item_type != ItemType.COIN:
		if allow_horizontal_movement:
			position.x += delta * horizonal_speed
	
		if !shape_cast_2d.is_colliding() && allow_horizontal_movement:
			vertical_speed = lerpf(vertical_speed, max_vertical_speed, vertical_velocity_gain)
			position.y += delta * vertical_speed
		else:
			vertical_speed = 0
	#else
