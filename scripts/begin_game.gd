extends Node2D

func new_game():
	var flag = get_node("Area2D/Flag")

	while $HUD.clock > 0 and flag.touched != true:
		await get_tree().create_timer(1.0).timeout
		$HUD.clock -= 1
		$HUD.update_time()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD.start_game.emit() # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
