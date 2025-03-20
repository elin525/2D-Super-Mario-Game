extends Node

signal checkpointReached

static var checkpoint_reached = false
static var saved = false
var LiveScene: Node
var clock: int
var score: int
var coins: int
var deadEnemiesList: Array[String]
var hitQuestionBlocks: Array[String]

static var stomped = false
static var consecutive = 0
var pointsArray = [100, 200, 400, 500, 800, 1000, 2000, 4000, 5000, 8000]
