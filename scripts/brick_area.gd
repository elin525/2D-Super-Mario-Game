extends Area2D

class_name BrickBlock

enum ItemType {
	EMPTY,
	COIN,
	COINS,
	MUSHROOM,
	FIREPLANT,
	ONEUP,
	STAR
}

@export var item_type: ItemType = ItemType.EMPTY

@onready var player = get_node("../../TileMap/player")
@onready var brick = $Sprite2D
@onready var world = get_node("../..")

var piece_sprites = []

var touched = false

func _ready() -> void:
	piece_sprites.append($Piece_Animation1)
	piece_sprites.append($Piece_Animation2)
	piece_sprites.append($Piece_Animation3)
	piece_sprites.append($Piece_Animation4)
	
	for sprite in piece_sprites:
		sprite.visible = false

func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	match item_type:
			ItemType.EMPTY:
				if player.blocks_interacted == 0:
					if player.current_state == "small" and world.death == false:
						shift_block()
					elif player.current_state == "big" or player.current_state == "fire":
						delete_block()
			ItemType.COIN:
				print("Coin")
				shift_block()
			ItemType.COINS:
				print("Coins")
				shift_block()
			ItemType.MUSHROOM:
				print("Mushroom")
				shift_block()
			ItemType.FIREPLANT:
				print("Fire plant")
				shift_block()
			ItemType.ONEUP:
				print("1UP")
				shift_block()
			ItemType.STAR:
				print("Star")
				shift_block()

func shift_block():
	player.blocks_interacted += 1
	touched = true
	var sound = get_node("../../Animation Sounds")
	sound.stream = load("res://sounds/blockhit.wav")
	sound.playing = true
	var temp_timer = get_tree().create_timer(0.05)
	await temp_timer.timeout
	brick.position.y -= 10
	var timer = get_tree().create_timer(0.2)
	await timer.timeout
	brick.position.y += 10
	touched = false
	player.blocks_interacted -= 1

func delete_block():
	# Play Sounds
	var sound = get_node("../../Animation Sounds")
	sound.stream = load("res://sounds/blockbreak.wav")
	sound.playing = true
	
	# Setup
	player.blocks_interacted += 1
	for sprite in piece_sprites:
		sprite.visible = true
		sprite.play()
	
	brick.visible = not brick.visible
	for i in range(10):
		var temp_timer = get_tree().create_timer(0.01)
		for j in range(len(piece_sprites)):
			piece_sprites[j].position.y -= 2
			if j < 2:
				piece_sprites[j].position.x -= 2
			else:
				piece_sprites[j].position.x += 2
		await temp_timer.timeout
	
	for i in range(20):
		var temp_timer = get_tree().create_timer(0.01)
		for j in range(len(piece_sprites)):
			piece_sprites[j].position.y += 6
			if j < 2:
				piece_sprites[j].position.x -= 1
			else:
				piece_sprites[j].position.x += 1
		await temp_timer.timeout
	
	# Disable visibility, animation, and hitboxes
	$CollisionShape2D.set_deferred("disabled", true)
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
	for piece in piece_sprites:
		piece.visible = false
		piece.stop()
	player.blocks_interacted -= 1
