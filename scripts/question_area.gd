extends Area2D

@onready var animated_coin = $Coin_Animation
@onready var animated_block = $Flashing_Block
@onready var null_block = $Null_Block
@onready var sound = get_node("../../Animation Sounds")
@onready var world = get_node("../..")
@onready var player = get_node("../../TileMap/player")
var activate = true

func _ready() -> void:
	animated_coin.visible = false
	null_block.visible = false
	animated_block.play()

func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	
	if activate == true and world.death == false:
		var HUD = get_node("../../HUD")
		HUD.score += 200
		HUD.update_score()
		HUD.coins += 1
		HUD.update_coins()
		
		activate = false
		coin_animation()
		shift_block()

func shift_block():
	null_block.visible = true
	animated_block.stop()
	animated_block.visible = false
	
	position.y -= 10
	var timer = get_tree().create_timer(0.2)
	await timer.timeout
	position.y += 10

func coin_animation():
	sound.stream = load("res://sounds/blockhit.wav")
	sound.playing = true
	sound.stream = load("res://sounds/coin.wav")
	sound.playing = true
	
	animated_coin.visible = true
	animated_coin.play()
	
	for i in range(8):
		var timer = get_tree().create_timer(0.05)
		if i < 4:
			animated_coin.position.y -= 5
		else:
			animated_coin.position.y += 5
		await timer.timeout
	
	animated_coin.stop()
	animated_coin.visible = false
	
	var points_label = preload("res://UI/points_label.tscn").instantiate()
	points_label.text = str(200)
	points_label.position = animated_coin.global_position + Vector2(10, 0)
	points_label.setPosition(points_label.position)
	get_tree().root.add_child(points_label)
