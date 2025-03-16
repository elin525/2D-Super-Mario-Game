extends CanvasLayer

signal start_game

var clock: int = 400

var score: int = 000000

var coins: int = 0

func update_time():
	$Time.text = "TIME\n%d" % clock
	
func update_coins():
	$"Coin Count".text = "x%d" % coins

func update_score():
	$Score.text = "MARIO\n%06d" % score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$"Coin Count/CoinAn1".play("default")
