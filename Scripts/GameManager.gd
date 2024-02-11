extends Node2D

#Manages which player can move
var isWhiteTurn : bool = true
var hasMoved : bool = false # Prevents player from moving another piece while waiting to promote

@onready var chessPieces = get_tree().get_nodes_in_group("Pieces")

signal prepare_next_turn
# Called when the node enters the scene tree for the first time.
func _ready():
	$UI/gameOverDisplay.visible = false
	
	for piece in chessPieces:
		piece.Turn_Over.connect(_on_Turn_Over)
		prepare_next_turn.connect(piece._on_prepare_next_turn)
		
		if piece.pieceType == "Pawn":
			piece.Pawn_Promotion.connect(_on_Pawn_Promotion)
		elif piece.pieceType == "King":
			piece.Game_Over.connect(_on_Game_Over)
	
	StartTurn()

func _process(delta):
	if $Board.kings[1].isInCheck: $UI/whiteCheckIndicator.visible = true
	else: $UI/whiteCheckIndicator.visible = false
	
	if $Board.kings[0].isInCheck: $UI/blackCheckIndicator.visible = true
	else: $UI/blackCheckIndicator.visible = false

#Signal connect from chess piece script
#Deselects and changes turn
func _on_Turn_Over():
	hasMoved = false
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
			tile.inRangeOfPieces = [[],[]]
			if tile.EnPasseTimeout == 0:
				tile.EnPasse = null
			else: tile.EnPasseTimeout = 0
			
			if tile.heldPiece != null:
				tile.heldPiece.isHoldingKing = false
				tile.heldPiece.blocking.clear()
				tile.heldPiece.pathToKing.clear()
	#Tells pieces to check where they can move
	prepare_next_turn.emit()

func _on_Pawn_Promotion(pawn, newPiece):
	#Instantiate new piece based on the button that was clicked
	var promotedPiece = ResourceLoader.load(newPiece).instantiate()
	#Sets up the new piece
	promotedPiece.startingTile = pawn.curTile
	promotedPiece.isWhite = pawn.isWhite
	promotedPiece.Turn_Over.connect(_on_Turn_Over)
	prepare_next_turn.connect(promotedPiece._on_prepare_next_turn)
	#Adds the new pice to pieces
	$Board.get_node("Pieces").add_child(promotedPiece)
	pawn.queue_free()
