extends Area2D

@onready var animated_coin = $"../Coin_Animation"
var activate = true

func _ready() -> void:
	animated_coin.visible = false
	pass

func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if activate == true:
		animated_coin.position.x = position.x
		animated_coin.position.x += 466
		animated_coin.position.y = position.y
		animated_coin.position.y -= 146
		
		activate = false
		
		coin_animation()
		shift_block()

func shift_block():
	$Sprite2D.frame = 1
	position.y -= 10
	var timer = get_tree().create_timer(0.2)
	await timer.timeout
	position.y += 10

func coin_animation():
	animated_coin.visible = true
	animated_coin.play("block_coin")
	
	for i in range(8):
		var timer = get_tree().create_timer(0.05)
		if i < 4:
			animated_coin.position.y -= 5
		else:
			animated_coin.position.y += 5
		await timer.timeout
	
	animated_coin.visible = false
