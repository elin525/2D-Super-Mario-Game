extends Node2D

static var lives = 3

var triggered = false

func update_lives():
	get_node("LivesLeft").text = "x%d" % lives
	
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if lives < 3 and triggered == true:
		ResourceLoad.LiveScene = self.duplicate()
		await get_tree().create_timer(3.0).timeout
		var world = preload("res://world.tscn").instantiate()
		get_tree().root.add_child(world)
		
		triggered = false
		
		get_node(".").free()

func _on_title_screen_mouse_click() -> void:
	var HUD = preload("res://canvas_layer.tscn").instantiate()
	get_tree().root.add_child(HUD)
	
	ResourceLoad.LiveScene = self.duplicate()
	
	await get_tree().create_timer(3.0).timeout
	
	get_tree().root.remove_child(HUD)

	var world = preload("res://world.tscn").instantiate()
	get_tree().root.add_child(world)
	get_node(".").free()
