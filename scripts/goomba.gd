extends Enemy

func _ready():
	super._ready()
	kill_points = 100

func die():
	super.die()
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	get_tree().create_timer(1.5).timeout.connect(queue_free)
