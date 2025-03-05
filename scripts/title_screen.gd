extends Node2D

var clickable = false

var lives_visible = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(event) -> void:
	if !lives_visible:
		$Lives.visible = false
	else:
		$Lives.visible = true
	
func _input(event):
	
	if event is InputEventMouse and event.position.x >= 648 and event.position.x <= 936 and event.position.y >= 428 and event.position.y <= 468:
		clickable = true
	else:
		clickable = false
		
	if event is InputEventMouseButton and event.is_pressed() and clickable:
		get_node("ColorRect").free()
		var HUD = preload("res://canvas_layer.tscn").instantiate()
		get_tree().root.add_child(HUD)
		
		lives_visible = true
			
		await get_tree().create_timer(3.0).timeout
		get_tree().root.remove_child(HUD)
		
		var world = preload("res://world.tscn").instantiate()
		get_tree().root.add_child(world)
		get_node(".").free()
