extends Area2D

signal finished

var block_touched = false
var end = false

@onready var player = get_node("../TileMap/player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ResourceLoad.level_changed.connect(end_finished)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if end:
		self.finished.emit()
	

func _on_body_entered(body: Node2D) -> void:
	
	var score = 0
		
	var flag = get_node("Flag")
	var HUD = get_node("../HUD")
	
	if body.position.y <= -305:
		score = 5000
	elif body.position.y <= -259:
		score = 4000
	elif body.position.y <= -177:
		score = 2000
	elif body.position.y <= -135:
		score = 800
	elif body.position.y <= -64:
		score = 400
	else:
		score = 100
	
	HUD.score += score
	HUD.update_score()
	
	if block_touched == false:
		display_points(player.global_position, score)
	
	flag.initial_touched = true
	
	var music = get_node("../AudioStreamPlayer2D")
	music.stream = load("res://sounds/levelend.wav")
	music.playing = true
	
	await music.finished
	
	music.playing = false
	
	end = true
	
func display_points(object_position, score):
	var points_label = preload("res://UI/points_label.tscn").instantiate()
	points_label.text = str(score)
	points_label.position = object_position + Vector2(10, 0)
	points_label.setPosition(points_label.position)
	get_tree().root.add_child(points_label)
	
func end_finished():
	end = false
