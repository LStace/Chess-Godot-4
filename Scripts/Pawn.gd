extends ChessPiece

var canEnPasse : Area2D
var pieceToPromoteTo : PackedScene

func pieceSpecificConnection():
	$promotionButtons.visible = false
	Check_Pawn_Promotion.connect(_on_Check_Pawn_Promotion)

#Get valid moves for a pawn
func getValidMoves():
	var tempMoves = []
	var moveDir : int
	if isWhite: moveDir = 1
	else: moveDir = -1
	
	if curTile.boardIndex.y != 0 and curTile.boardIndex.y != 7: 
		for i in range(-1, 2):
			var checkTileResult = isMoveLegal(curTile.boardIndex.x + i, curTile.boardIndex.y + moveDir)
			#Prevents index out of range
			if checkTileResult == "OUT OF RANGE": continue
			var checkTile = chessBoard.board[curTile.boardIndex.x + i][curTile.boardIndex.y + moveDir]
			
			if i == 0:
				#Pawns can move one space forward
				if checkTileResult == "EMPTY" or checkTileResult == "HOLDS ENEMY":
					tempMoves.append(checkTile)
				#Pawns can move spaces if they haven't moved yet
				if checkTileResult != "HOLDS ENEMY" and checkTileResult != "HOLDS ALLY" and checkTileResult != "HOLDS ALLY" and startingTile == curTile:
					var firstMoveCheck = isMoveLegal(curTile.boardIndex.x, curTile.boardIndex.y + (moveDir*2))
					if firstMoveCheck == "EMPTY" or firstMoveCheck == "HOLDS ENEMY":
						tempMoves.append(chessBoard.board[curTile.boardIndex.x][curTile.boardIndex.y + (moveDir*2)])
						#Facilitates EnPasse
						chessBoard.board[curTile.boardIndex.x][curTile.boardIndex.y + moveDir].EnPasse = self
						chessBoard.board[curTile.boardIndex.x][curTile.boardIndex.y + moveDir].EnPasseTimeout = 1
			#Pawn can move diagonally if there is an enemy piece or it can enpasse
			else:
				#Checks for enemy in diagonal
				if checkTileResult == "HOLDS ENEMY":
					tempMoves.append(checkTile)
				#Checks for EnPasse
				#If there is a piece that can be enpasse'd through that tile, that piece is an enemy piece and that piece is left or right of the curent piece
				if checkTile.EnPasse != null and checkTile.EnPasse.isWhite != isWhite and chessBoard.board[curTile.boardIndex.x + i][curTile.boardIndex.y].heldPiece == checkTile.EnPasse:
					tempMoves.append(checkTile)
					canEnPasse = checkTile.EnPasse
				else:
					canEnPasse = null
	
	return tempMoves


func _on_Check_Pawn_Promotion():
	if (curTile.boardIndex.y == 7 or curTile.boardIndex.y == 0) and curTile != startingTile:
		$promotionButtons.visible = true
	else: emit_signal("Turn_Over")

func _on_Promotion_Pressed(newPiece):
	#Instantiate new piece based on the button that was clicked
	pieceToPromoteTo = ResourceLoader.load(newPiece)
	var promotedPiece = pieceToPromoteTo.instantiate()
	#Sets up the new piece
	promotedPiece.startingTile = curTile
	promotedPiece.isWhite = self.isWhite
	#Adds the new pice to pieces
	chessBoard.get_node("Pieces").add_child(promotedPiece)
	#removes the pawn
	queue_free()
	emit_signal("Turn_Over")
