extends Area2D

var activate = true
#var coordinate: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if activate == true:
		activate = false
		$Sprite2D.frame = 1
		position.y -= 10
		var timer = get_tree().create_timer(0.2)
		await timer.timeout
		position.y += 10
		#position = coordinate
