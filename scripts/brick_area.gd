extends Area2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	shift_block()

func shift_block():
	var sound = get_node("../Animation Sounds")
	sound.stream = load("res://sounds/blockhit.wav")
	sound.playing = true
	var temp_timer = get_tree().create_timer(0.05)
	await temp_timer.timeout
	
	position.y -= 10
	var timer = get_tree().create_timer(0.2)
	await timer.timeout
	position.y += 10

func delete_block():
	var sound = get_node("../Animation Sounds")
	sound.stream = load("res://sounds/blockbreak.wav")
	sound.playing = true
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.visible = not $Sprite2D.visible
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
