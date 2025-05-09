extends Node2D

signal hurry_up

var death = false
var player

# Called at the start of every attempt
func new_game():
	
	var flag = get_node("Flag Pole/Flag")
	
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

# Called every time the Node enters the scene tree
func _ready() -> void:
	$"Animation Sounds".playing = false
	$HUD.start_game.emit()
	
	if $HUD.clock <= 100:
		hurry_up.emit()


# Called every frame.
func _process(_delta: float) -> void:
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
	var flag = get_node("Flag Pole/Flag")
	
	if $HUD.clock > 0 and flag.initial_touched != true:
		$AudioStreamPlayer2D.playing = true
	elif $HUD.clock < 100:
		$AudioStreamPlayer2D.playing = true


func _on_hurry_up() -> void:
	if ResourceLoad.level == "map1-1":
		$AudioStreamPlayer2D.stream = load("res://sounds/overworld-fast.wav")
	else:
		var file = FileAccess.open("res://sounds/underground-fast.mp3", FileAccess.READ)
		var mpsound = AudioStreamMP3.new()
		mpsound.data = file.get_buffer(file.get_length())
		$AudioStreamPlayer2D.stream = mpsound
		
	$AudioStreamPlayer2D.playing = true


func _on_invincible_finished() -> void:
	pass # Replace with function body.
