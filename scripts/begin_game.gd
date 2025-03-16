extends Node2D

signal hurry_up

var death = false
var player

func new_game():
	var flag = get_node("Area2D/Flag")
	
	player = get_node("TileMap/player")
	
	$AudioStreamPlayer2D.playing = true

	while $HUD.clock > 0 and flag.initial_touched != true:
		await get_tree().create_timer(0.4).timeout
		$HUD.clock -= 1
		$HUD.update_time()
		
		if $HUD.clock == 100:
			hurry_up.emit()
			
		if death == true:
			break
		
	if $HUD.clock == 0:
		$AudioStreamPlayer2D.playing = false
		player.die(self)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD.start_game.emit() # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$AudioStreamPlayer2D.position.x = player.position.x


func _on_question_block_12_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_Brick_Block_1_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_brick_block_1_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_audio_stream_player_2d_finished() -> void:
	var flag = get_node("Area2D/Flag")
	
	if $HUD.clock > 0 and flag.initial_touched != true:
		$AudioStreamPlayer2D.playing = true
	elif $HUD.clock < 100:
		$AudioStreamPlayer2D.playing = true


func _on_hurry_up() -> void:
	$AudioStreamPlayer2D.stream = load("res://sounds/overworld-fast.wav")
	$AudioStreamPlayer2D.playing = true # Replace with function body.
