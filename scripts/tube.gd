extends Node

enum TubeType {
	dull_pipe,
	w1_1_1,
	w1_1_2,
	w1_2_1
}

@export var tube_type: TubeType = TubeType.dull_pipe
@onready var player = get_node("../../TileMap/player")

var accessable = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if accessable and Input.is_action_pressed("ui_down"):
		match tube_type:
			TubeType.dull_pipe:
				pass
			TubeType.w1_1_1:
				player.is_controllable = false
				player.position.x = 5702
				player.position.y = -64
				player.is_controllable = true

func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print("Entered")
	accessable = true


func _on_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print("Exited")
	accessable = false
