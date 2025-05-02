extends Node2D

@onready var continue_button = $continue
@onready var exit_button = $exit
@onready var lives = $Lives

func _ready():
	continue_button.pressed.connect(on_continue_pressed)
	exit_button.pressed.connect(on_exit_pressed)

func on_continue_pressed():
	get_tree().change_scene_to_file("res://title_screen.tscn")
	
func on_exit_pressed():
	get_tree().quit()
