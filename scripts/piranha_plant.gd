extends Area2D

@onready var sprite := $AnimatedSprite2D
@onready var timer := $Timer

var base_position: Vector2
var up_distance := -76       
var move_speed := 50.0       
var is_up := false
var target_position: Vector2
var moving := false
var tube

func _ready():
	base_position = position
	target_position = base_position
	timer.timeout.connect(_on_timer_timeout)
	sprite.play("piranha_plant")
	timer.start()

func _on_timer_timeout() -> void:
	if is_up:
		move_down()
	else:
		move_up()

func move_up() -> void:
	is_up = true
	target_position = base_position + Vector2(0, up_distance)
	moving = true
	timer.start(3.8)
	
func move_down() -> void:
	is_up = false
	target_position = base_position
	moving = true

func _physics_process(delta: float) -> void:
	if moving:
		var direction = (target_position - position).normalized()
		var distance = move_speed * delta
		var new_position = position + direction * distance

		if position.distance_to(target_position) < distance:
			position = target_position
			moving = false
			timer.start(3.5)
		else:
			position = new_position


func _on_area_entered(area: Area2D) -> void:
	
	for i in get_overlapping_areas():
		if i.get_parent().name == "Tubes":
			tube = i
			
	if area.get_parent().name == "player" and tube.get_node("StaticBody2D/CollisionShape2D").disabled == false:
		area.get_parent().hurt()
