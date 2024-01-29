extends Node2D

#Manages which player can move
var isWhiteTurn : bool = true

signal prepare_next_turn
# Called when the node enters the scene tree for the first time.
func _ready():
	$UI/gameOverDisplay.visible = false
	StartTurn()

#Signal connect from chess piece script
#Deselects and changes turn
func _on_Turn_Over():
	$Board.DeselectPiece()
	isWhiteTurn = !isWhiteTurn
	StartTurn()

func _on_Game_Over(losingKing):
	if losingKing.isWhite: $UI/gameOverDisplay/winningPiece.text = "Black Wins"
	else: $UI/gameOverDisplay/winningPiece.text = "White Wins"
	$UI/gameOverDisplay.visible = true

func StartTurn():
	if isWhiteTurn: $UI/playerIndicator.text = "White"
	else: $UI/playerIndicator.text = "Black"
	for row in $Board.board:
		for tile in row:
			tile.inRangeOfBlack.clear()
			tile.inRangeOfWhite.clear()
			if tile.EnPasseTimeout == 0:
				tile.EnPasse = null
			else: tile.EnPasseTimeout = 0
	#Tells pieces to check where they can move
	prepare_next_turn.emit()
