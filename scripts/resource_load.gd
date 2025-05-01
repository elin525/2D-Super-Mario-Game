extends Node

signal checkpointReached
signal level_changed

static var checkpoint_reached = false
static var saved = false
var LiveScene: Node
var clock: int
var score: int
var coins: int
var deadEnemiesList: Array[String]
var hitQuestionBlocks: Array[String]
static var level = "map1-1"
static var completed = 0
static var world = 1

static var stomped = false
static var consecutive = 0
var pointsArray = [100, 200, 400, 500, 800, 1000, 2000, 4000, 5000, 8000]

func changeLevel():
	level_changed.emit()
	completed += 1
	var prevLevel = level
	level = "map" + str(world) + "-" + str(completed+1)
	
	if completed % 4 == 0:
		world += 1
		completed = 0
		
	checkpoint_reached = false
		
	var l = LiveScene
	
	var tree = get_tree()
	
	l.get_node("./Label").text = "WORLD " + str(world) + "-" + str(completed+1)
	
	tree.root.add_child(l)
	l.triggered = true
	if prevLevel == "map1-1":
		tree.root.remove_child(get_node("/root/world"))
	else:
		var string = "/root/" + str(prevLevel)
		tree.root.remove_child(get_node(string))
