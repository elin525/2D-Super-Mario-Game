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
