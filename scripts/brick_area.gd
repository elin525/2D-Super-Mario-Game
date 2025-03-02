extends Area2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	shift_block()

func shift_block():
	var temp_timer = get_tree().create_timer(0.05)
	await temp_timer.timeout
	
	position.y -= 10
	var timer = get_tree().create_timer(0.2)
	await timer.timeout
	position.y += 10

func delete_block():
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite2D.visible = not $Sprite2D.visible
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
