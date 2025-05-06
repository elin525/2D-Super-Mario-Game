extends Node2D

signal mouse_click

var clickable = false

@onready var lives = $Lives
@onready var music = get_node("AudioStreamPlayer2D")
@onready var mario = get_node("ColorRect/Features/Mario")


func _ready():
	lives.visible = false
	music.play()
	
	mario.play("walk")
	
func _input(event):
	
	if event is InputEventMouse and event.position.x >= 648 and event.position.x <= 936 and event.position.y >= 428 and event.position.y <= 468:
		clickable = true
	else:
		clickable = false
		
	if event is InputEventMouseButton and event.is_pressed() and clickable and get_node("ColorRect") != null:
		get_node("ColorRect").free()
		lives.visible = true
		music.stop()
		mouse_click.emit()
