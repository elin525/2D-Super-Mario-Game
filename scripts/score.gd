extends CanvasLayer

signal start_game

var clock: int = 400

var score: int = 000000

var coins: int = 0

func _ready():
	ResourceLoad.checkpointReached.connect(save_score)
	
	if ResourceLoad.checkpoint_reached:
		clock = 100
		#clock = ResourceLoad.clock
		update_time()
		score = ResourceLoad.score
		update_score()
		coins = ResourceLoad.coins
		update_coins()

func update_time():
	$Time.text = "TIME\n%d" % clock
	
func update_coins():
	$"Coin Count".text = "x%d" % coins

func update_score():
	$Score.text = "MARIO\n%06d" % score

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$"Coin Count/CoinAn1".play("default")
	
func add_score(points: int):
	score += points
	update_score()
	
func save_score():
	ResourceLoad.clock = clock
	ResourceLoad.score = score
	ResourceLoad.coins = coins
