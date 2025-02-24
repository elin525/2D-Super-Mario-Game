extends Sprite2D

var initial_touched = false

var touched = false

var initial_pos = position.y

func _physics_process(delta):
	if initial_touched:
		touched = true
	
	if touched:
		position.y += 5
	if position.y > 300:
		position.y = initial_pos
		touched = false
		initial_touched = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
