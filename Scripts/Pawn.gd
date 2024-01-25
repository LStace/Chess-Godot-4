extends ChessPiece


#Get valid moves for a pawn
func getValidMoves():
	var tempMoves = []
	var moveDir : int
	if isWhite: moveDir = 1
	else: moveDir = -1
	
	if curTile.boardIndex.y != 0 and curTile.boardIndex.y != 7: 
		for i in range(-1, 2):
			if chessBoard.board[curTile.boardIndex.x][curTile.boardIndex.y + moveDir].heldPiece != null and chessBoard.board[curTile.boardIndex.x][curTile.boardIndex.y + moveDir].heldPiece.isWhite == isWhite: break
			elif curTile.boardIndex.x + i < 0 or curTile.boardIndex.x + i >= 8: continue
			#Pawns can move one space forward
			elif i == 0: tempMoves.append(chessBoard.board[curTile.boardIndex.x][curTile.boardIndex.y + moveDir])
			#Pawns can move one space diagonally if there is an enemy piece
			else:
				var checkTile = chessBoard.board[curTile.boardIndex.x + i][curTile.boardIndex.y + moveDir]
				if checkTile.heldPiece != null: tempMoves.append(checkTile)

	#Pawns can move an extra space if they haven't been moved yet
	if startingTile == curTile:
		tempMoves.append(chessBoard.board[curTile.boardIndex.x][curTile.boardIndex.y + (moveDir*2)])
	
	return tempMoves
