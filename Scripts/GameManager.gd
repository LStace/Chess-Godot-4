extends Node2D

#Manages which player can move
var isWhiteTurn : bool = true

signal prepare_next_turn
# Called when the node enters the scene tree for the first time.
func _ready():
	StartTurn()

#Signal connect from chess piece script
#Deselects and changes turn
func _on_Turn_Over():
	$Board.DeselectPiece()
	isWhiteTurn = !isWhiteTurn
	StartTurn()

func StartTurn():
	if isWhiteTurn: $CanvasLayer/playerIndicator.text = "White"
	else: $CanvasLayer/playerIndicator.text = "Black"
	#Tells pieces to check where they can move
	prepare_next_turn.emit()
