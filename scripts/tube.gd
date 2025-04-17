extends Node

enum TubeType {
	dull_pipe,
	w1_1_1,
	w1_1_2,
	w1_2_1
}

@export var tube_type: TubeType = TubeType.dull_pipe
@onready var player = get_node("../../TileMap/player")
@onready var sound = get_node("../../Animation Sounds")

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
				await enter_pipe()
				await get_tree().create_timer(0.05).timeout
				exit_pipe(get_node("../../Tubes/Tube5/StaticBody2D/CollisionShape2D"), 5174, -64)
				player.is_controllable = true

func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	accessable = true


func _on_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	accessable = false

func enter_pipe():
	var sound = get_node("../../Animation Sounds")
	sound.stream = load("res://sounds/pipe.wav")
	sound.playing = true
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
	
	for i in range(24):
		await get_tree().create_timer(0.04).timeout
		player.position.y += 1
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", false)

func exit_pipe(target_pipe, target_x, target_y):
	var sound = get_node("../../Animation Sounds")
	sound.stream = load("res://sounds/pipe.wav")
	sound.playing = true
	
	#target_pipe.set_deferred("disabled", true)
	player.position.x = target_x
	player.position.y = target_y
	"""
	for i in range(24):
		await get_tree().create_timer(0.04).timeout
		player.position.y -= 1
	target_pipe.set_deferred("disabled", false)
	"""
