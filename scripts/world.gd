extends TileMap

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(446, 50000):
		if i % 2 == 0:
			self.set_cell(0, Vector2i(i, 0), 0, Vector2i(0, 0), 0)
			self.set_cell(0, Vector2i(i, 1), 0, Vector2i(0, 1), 0)
			self.set_cell(0, Vector2i(i, 2), 0, Vector2i(0, 0), 0)
			self.set_cell(0, Vector2i(i, 3), 0, Vector2i(0, 1), 0)
		else:
			self.set_cell(0, Vector2i(i,0), 0, Vector2i(1,0), 0)
			self.set_cell(0, Vector2i(i,1), 0, Vector2i(1,1), 0)
			self.set_cell(0, Vector2i(i,2), 0, Vector2i(1,0), 0)
			self.set_cell(0, Vector2i(i,3), 0, Vector2i(1,1), 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
