extends Node2D

var horizontal_speed = 100
var vertical_speed = 100

var cooldown = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += delta * horizontal_speed
	
	if cooldown:
		position.y -= delta * vertical_speed
		await get_tree().create_timer(0.5).timeout
		cooldown = false
	else:
		position.y += delta * vertical_speed
	
	for i in $Area2D.get_overlapping_areas():
		if i.get_parent().name != "player":
			if position.y > 0:
				self.queue_free()
			elif i.get_parent().name == "Enemies":
				
				if i.name != "Koopa":
					i.kill_points = 100
				else:
					i.kill_points = 200
					
				i.die_from_hit()
				
				self.queue_free()
	
	for i in $Area2D.get_overlapping_bodies():
		if i.name != "player" and position.y <= 0:
			cooldown = true
