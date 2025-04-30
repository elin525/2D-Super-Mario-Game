extends Node

enum TubeType {
	dull_pipe,
	w1_1_1,
	w1_1_2,
	w1_2_1,
	w1_2_2,
	w1_2_3,
	w1_2_4
}

@export var tube_type: TubeType = TubeType.dull_pipe
@onready var player = get_node("../../TileMap/player")
@onready var sound = get_node("../../Animation Sounds")
@onready var camera = get_node("../../TileMap/player/Camera2D")

var accessable = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	
	if accessable and Input.is_action_pressed("ui_down"):
		match tube_type:
			TubeType.w1_1_1:
				await enter_pipe()
				camera.limit_top = 260
				camera.limit_bottom = 760
				camera.limit_left = 3000
				camera.limit_right = 3740
				camera.furthest_x = 3202
				await exit_pipe(3277, 400)
			TubeType.w1_2_3:
				await enter_pipe()
				camera.limit_top = 125
				camera.limit_bottom = 625
				camera.limit_left = 3000
				camera.limit_right = 3740
				camera.furthest_x = 3000
				await exit_pipe(3200, 250)
				
	elif accessable and Input.is_action_pressed("ui_right"):
		match tube_type:
			TubeType.w1_1_2:
				await enter_pipe()
				camera.limit_top = -470
				camera.limit_bottom = 48
				camera.limit_left = 4867
				camera.limit_right = 6650
				camera.furthest_x = 5177
				await exit_pipe(5174, -64)
			TubeType.w1_2_1:
				await enter_pipe()
				camera.limit_top = -470
				camera.limit_bottom = 48
				camera.limit_left = -65
				camera.furthest_x = 0
				await exit_pipe(50, -345)
			TubeType.w1_2_2:
				await enter_pipe()
				camera.limit_top = -1420
				camera.limit_bottom = -897
				camera.limit_left = 4795
				camera.furthest_x = 4795
				await exit_pipe(4860, -1020)
			TubeType.w1_2_4:
				await enter_pipe()
				camera.limit_top = -470
				camera.limit_bottom = 48
				camera.limit_left = -65
				camera.limit_right = 6650
				camera.furthest_x = 0
				await exit_pipe(3640, -70)

func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.get_parent().name == "player":
		accessable = true

func _on_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	accessable = false

func enter_pipe():
	player.is_controllable = false
	var sound = get_node("../../Animation Sounds")
	sound.stream = load("res://sounds/pipe.wav")
	sound.playing = true
	player.velocity.x = 0
	
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
	for i in range(8):
		match tube_type:
			TubeType.w1_1_1:
				player.position.y += 1.5
			TubeType.w1_1_2:
				player.position.x += 1
			TubeType.w1_2_1:
				player.position.x += 1
			TubeType.w1_2_2:
				player.position.x += 1
			TubeType.w1_2_3:
				player.position.y += 1.5
			TubeType.w1_2_4:
				player.position.x += 1
		await get_tree().create_timer(0.04).timeout
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", false)
	await get_tree().create_timer(0.05).timeout

func exit_pipe(target_x, target_y):
	var sound = get_node("../../Animation Sounds")
	sound.stream = load("res://sounds/pipe.wav")
	sound.playing = true
	
	player.position.x = target_x
	player.position.y = target_y
	player.is_controllable = true
	player.cooldown = true
	for i in range(5):
		await get_tree().create_timer(0.2).timeout
		await get_tree().create_timer(0.2).timeout
	player.cooldown = false
