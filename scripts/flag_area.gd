extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
		
	var flag = get_node("Flag")
	var HUD = get_node("../HUD")
	
	if body.position.y <= -305:
		HUD.score += 5000
		HUD.update_score()
	elif body.position.y <= -259:
		HUD.score += 4000
		HUD.update_score()
	elif body.position.y <= -177:
		HUD.score += 2000
		HUD.update_score()
	elif body.position.y <= -135:
		HUD.score += 800
		HUD.update_score()
	elif body.position.y <= -64:
		HUD.score += 400
		HUD.update_score()
	else:
		HUD.score += 100
		HUD.update_score()
	
	flag.initial_touched = true
	
	var music = get_node("../AudioStreamPlayer2D")
	music.stream = load("res://sounds/levelend.wav")
	music.playing = true
	
	await music.finished
	
	music.playing = false
