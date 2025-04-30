extends Node2D

var horizontal_speed = 100
var vertical_speed = 100

var cooldown = false

@onready var world

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ResourceLoad.level == "map1-1":
		world = get_node("/root/world/TileMap")
	else:
		var string = "/root/" + ResourceLoad.level + "/TileMap"
		world = get_node(string)


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
			
			if i.get_parent().name == "Enemies":
				
				if i.name != "Koopa":
					i.kill_points = 100
				else:
					i.kill_points = 200
					
				i.die_from_hit()
				
				self.queue_free()
	
	for i in $Area2D.get_overlapping_bodies():
		var collision_angle = rad_to_deg(global_position.angle_to_point(i.global_position))
		
		var tile_pos = Vector2i(floor(global_position.x/16), ceil(global_position.y/16))
		if i.name != "player" and global_position.y <= 0:
			cooldown = true
			
		if i.name == "TileMap":

			var coordinates = world.get_cell_atlas_coords(0, tile_pos)
			
			var tile_pos_16 = Vector2i(tile_pos.x*16, tile_pos.y*16)
				
			if coordinates == Vector2i(0,0) or coordinates == Vector2i(2,0):
				collision_angle = rad_to_deg(global_position.angle_to_point(tile_pos_16+Vector2i(16, 16)))
			elif coordinates == Vector2i(0,1) or coordinates == Vector2i(2,1):
				collision_angle = rad_to_deg(global_position.angle_to_point(tile_pos_16+Vector2i(16, 0)))
			elif coordinates == Vector2i(1,0) or coordinates == Vector2i(3,0):
				collision_angle = rad_to_deg(global_position.angle_to_point(tile_pos_16+Vector2i(0, 16)))
			elif coordinates == Vector2i(1,1) or coordinates == Vector2i(3,1):
				collision_angle = rad_to_deg(global_position.angle_to_point(tile_pos_16+Vector2i(0, 0)))
			elif coordinates == Vector2i(-1,-1) and world.get_cell_atlas_coords(0, tile_pos-Vector2i(-1, 0)) != Vector2i(-1, -1):
				collision_angle = rad_to_deg(global_position.angle_to_point(tile_pos_16+Vector2i(0, 16)))
			
			print(collision_angle)
				
			if abs(collision_angle) < 45 or abs(collision_angle) > 135:
				self.queue_free()
				
		if i.get_parent().get_parent().name == "Tubes":
			collision_angle = rad_to_deg(global_position.angle_to_point(Vector2i(i.global_position.x, -32)))
			
			if abs(collision_angle) < 45 or abs(collision_angle) > 135:
				self.queue_free()
			
		if i.name != "TileMap" and i.name != "player" and self != null and abs(collision_angle) < 45:
			self.queue_free()
