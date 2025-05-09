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

enum ColorType {
	BRICK,
	UNDERGROUD,
	CASTLE
}

const UNDERGROUND_BRICK_TEXTURE = preload("res://images/UndergroundBrick.png")

@export var item_type: ItemType = ItemType.EMPTY
@export var color_type: ColorType = ColorType.BRICK

const MUSHROOM_SCENE = preload("res://pickups/mushroom.tscn")
const FIREPLANT_SCENE = preload("res://pickups/fireplant.tscn")
const ONEUP_SCENE = preload("res://pickups/oneup.tscn")
const STAR_SCENE = preload("res://pickups/star.tscn")

@onready var player = get_node("../../TileMap/player")
@onready var brick = $Sprite2D
@onready var world = get_node("../..")

var piece_sprites = []
var hitpoints = 5
var touched = false

@onready var null_block = $Null_Block
@onready var animated_coin = $Coin_Animation
@onready var sound = get_node("../../Animation Sounds")

func _ready() -> void:
	if color_type == ColorType.UNDERGROUD:
		brick.texture = UNDERGROUND_BRICK_TEXTURE
		piece_sprites.append($Blue_Piece_Animation1)
		piece_sprites.append($Blue_Piece_Animation2)
		piece_sprites.append($Blue_Piece_Animation3)
		piece_sprites.append($Blue_Piece_Animation4)
		$Piece_Animation1.visible = false
		$Piece_Animation2.visible = false
		$Piece_Animation3.visible = false
		$Piece_Animation4.visible = false
	else:
		piece_sprites.append($Piece_Animation1)
		piece_sprites.append($Piece_Animation2)
		piece_sprites.append($Piece_Animation3)
		piece_sprites.append($Piece_Animation4)
		$Blue_Piece_Animation1.visible = false
		$Blue_Piece_Animation2.visible = false
		$Blue_Piece_Animation3.visible = false
		$Blue_Piece_Animation4.visible = false
	
	for sprite in piece_sprites:
		sprite.visible = false
	
	animated_coin.visible = false
	null_block.visible = false

func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if world.death == true or body.name != "player":
		return
	
	var HUD = get_node("../../HUD")
	if hitpoints <= 0:
		var sound = get_node("../../Animation Sounds")
		sound.stream = load("res://sounds/blockhit.wav")
		sound.playing = true
	else:
		match item_type:
				ItemType.EMPTY:
					if player.blocks_interacted == 0:
						if player.current_state == "small" and world.death == false:
							shift_block()
						elif player.current_state == "big" or player.current_state == "fire":
							delete_block()
				ItemType.COIN:
					print("Coin")
					hitpoints = 0
					HUD.score += 200
					HUD.update_score()
					HUD.coins += 1
					HUD.update_coins()
					shift_block()
					coin_animation()
				ItemType.COINS:
					print("Coins")
					hitpoints -= 1
					HUD.score += 200
					HUD.update_score()
					HUD.coins += 1
					HUD.update_coins()
					shift_block()
					coin_animation()
						
				ItemType.MUSHROOM:
					print("Mushroom")
					hitpoints = 0
					var mushroom = MUSHROOM_SCENE.instantiate()
					mushroom.global_position = global_position + Vector2(0,-10)
					get_tree().root.call_deferred("add_child", mushroom)
					shift_block()
				ItemType.FIREPLANT:
					print("Fire plant")
					hitpoints = 0
					if player.current_state == "small" and world.death == false:
						var mushroom = MUSHROOM_SCENE.instantiate()
						mushroom.global_position = global_position + Vector2(0,-10)
						get_tree().root.call_deferred("add_child", mushroom)
					elif player.current_state == "big" or player.current_state == "fire":
						var fireplant = FIREPLANT_SCENE.instantiate()
						fireplant.global_position = global_position + Vector2(0,-10)
						get_tree().root.call_deferred("add_child", fireplant)
					shift_block()
				ItemType.ONEUP:
					print("1UP")
					hitpoints = 0
					var oneup = ONEUP_SCENE.instantiate()
					oneup.global_position = global_position + Vector2(0,-10)
					get_tree().root.call_deferred("add_child", oneup)
					shift_block()
				ItemType.STAR:
					print("Star")
					hitpoints = 0
					var star = STAR_SCENE.instantiate()
					star.global_position = global_position + Vector2(0,-10)
					get_tree().root.call_deferred("add_child", star)
					shift_block()
	if hitpoints == 0:
		brick.visible = false
		null_block.visible = true

func shift_block():
	player.blocks_interacted += 1
	touched = true
	var sound = get_node("../../Animation Sounds")
	sound.stream = load("res://sounds/blockhit.wav")
	sound.playing = true
	brick.position.y -= 10
	await get_tree().create_timer(0.2).timeout
	brick.position.y += 10
	touched = false
	player.blocks_interacted -= 1

func delete_block():
	# Play Sounds
	var sound = get_node("../../Animation Sounds")
	sound.stream = load("res://sounds/blockbreak.wav")
	sound.playing = true
	touched = true
	# Setup
	player.blocks_interacted += 1
	for sprite in piece_sprites:
		sprite.visible = true
		sprite.play()
	
	brick.visible = not brick.visible
	for i in range(10):
		for j in range(len(piece_sprites)):
			piece_sprites[j].position.y -= 2
			if j < 2:
				piece_sprites[j].position.x -= 2
			else:
				piece_sprites[j].position.x += 2
		await get_tree().create_timer(0.01).timeout
	
	for i in range(20):
		for j in range(len(piece_sprites)):
			piece_sprites[j].position.y += 6
			if j < 2:
				piece_sprites[j].position.x -= 1
			else:
				piece_sprites[j].position.x += 1
		await get_tree().create_timer(0.01).timeout
	
	# Disable visibility, animation, and hitboxes
	$CollisionShape2D.set_deferred("disabled", true)
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
	for piece in piece_sprites:
		piece.visible = false
		piece.stop()
	player.blocks_interacted -= 1
	
	var hud = get_node("../../HUD")
	hud.score += 50
	hud.update_score()
	
	var points_label = preload("res://UI/points_label.tscn").instantiate()
	points_label.text = str(50)
	points_label.position = animated_coin.global_position + Vector2(-20, -5)
	points_label.setPosition(points_label.position)
	get_tree().root.add_child(points_label)
	
	touched = false

func coin_animation():
	sound.stream = load("res://sounds/blockhit.wav")
	sound.playing = true
	sound.stream = load("res://sounds/coin.wav")
	sound.playing = true
	
	animated_coin.visible = true
	animated_coin.play()
	
	for i in range(8):
		if i < 4:
			animated_coin.position.y -= 5
		else:
			animated_coin.position.y += 5
		await get_tree().create_timer(0.05).timeout
	
	animated_coin.stop()
	animated_coin.visible = false
	
	var points_label = preload("res://UI/points_label.tscn").instantiate()
	points_label.text = str(200)
	points_label.position = animated_coin.global_position + Vector2(-20, -5)
	points_label.setPosition(points_label.position)
	get_tree().root.add_child(points_label)
