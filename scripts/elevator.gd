extends Area2D

var entered = false
@onready var world = get_node("../..")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	if entered == true:
		return
	
	entered = true
	
	if area.get_parent().name == "player":
		
		if self.name == "ElevatorDown":
			await get_tree().create_timer(1).timeout
			while global_position.y < 5 and world.death == false:
				position.y += area.get_parent().gravity
				await get_tree().create_timer(0.1).timeout
				
		else:
			await get_tree().create_timer(1).timeout
			while global_position.y > -384 and world.death == false:
				position.y -= 3
				await get_tree().create_timer(0.1).timeout
