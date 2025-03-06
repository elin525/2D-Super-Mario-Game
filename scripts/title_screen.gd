extends Node2D

signal mouse_click

var clickable = false

@onready var lives = $Lives

func _ready():
	lives.visible = false
	
func _input(event):
	
	if event is InputEventMouse and event.position.x >= 648 and event.position.x <= 936 and event.position.y >= 428 and event.position.y <= 468:
		clickable = true
	else:
		clickable = false
		
	if event is InputEventMouseButton and event.is_pressed() and clickable:
		get_node("ColorRect").free()
		lives.visible = true
		mouse_click.emit()
