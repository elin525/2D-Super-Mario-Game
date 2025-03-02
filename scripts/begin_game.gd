extends Node2D

func new_game():
	var flag = get_node("Area2D/Flag")

	while $HUD.clock > 0 and flag.initial_touched != true:
		await get_tree().create_timer(0.4).timeout
		$HUD.clock -= 1
		$HUD.update_time()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD.start_game.emit() # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_question_block_12_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_Brick_Block_1_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_brick_block_1_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
