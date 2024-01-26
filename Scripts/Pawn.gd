extends ChessPiece


#Get valid moves for a pawn
func getValidMoves():
	var tempMoves = []
	var moveDir : int
	if isWhite: moveDir = 1
	else: moveDir = -1
	
	if curTile.boardIndex.y != 0 and curTile.boardIndex.y != 7: 
		for i in range(-1, 2):
			if curTile.boardIndex.x + i >= 0 and curTile.boardIndex.x + i < 8:
				var checkTile = chessBoard.board[curTile.boardIndex.x + i][curTile.boardIndex.y + moveDir]
				if checkTile.heldPiece != null and checkTile.heldPiece.isWhite == isWhite: continue
				#Pawns can move one space forward
				#Pawns can move one space diagonally if an enemy piece is present 
				elif i == 0 or (checkTile.heldPiece != null and checkTile.heldPiece.isWhite != isWhite):
					tempMoves.append(checkTile)

	#Pawns can move an extra space if they haven't been moved yet, but can't jump over other pieces
	if startingTile == curTile and chessBoard.board[curTile.boardIndex.x][curTile.boardIndex.y + moveDir].heldPiece == null:
		tempMoves.append(chessBoard.board[curTile.boardIndex.x][curTile.boardIndex.y + (moveDir*2)])
	
	return tempMoves
