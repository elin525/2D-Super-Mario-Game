extends Label

var label_position: Vector2

func _ready() -> void:
	
	var label_tween = get_tree().create_tween()
	label_tween.tween_property(self, "position", label_position + Vector2(0, -10), 0.4).from(label_position)
	label_tween.tween_callback(queue_free)

func setPosition(position_l):
	label_position = position_l
