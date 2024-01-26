extends ChessPiece

var canEnPasse : Area2D

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
				#Pawns can EnPasse
				#If there is a piece that can bee enpasse'd through that tile, that piece is an enemy piece and that piece is left or right of the cuurent piece
				if checkTile.EnPasse != null and checkTile.EnPasse.isWhite != isWhite and chessBoard.board[curTile.boardIndex.x + i][curTile.boardIndex.y].heldPiece == checkTile.EnPasse:
					tempMoves.append(checkTile)
					canEnPasse = checkTile.EnPasse
				else:
					canEnPasse = null
				#Pawns can move one space forward
				#Pawns can move one space diagonally if an enemy piece is present 
				
				if i == 0 or (checkTile.heldPiece != null and checkTile.heldPiece.isWhite != isWhite):
					tempMoves.append(checkTile)
				#King can't move into a space diagonal from a pawn. 
				else:
					if isWhite: checkTile.inRangeOfWhite.append(self)
					else: checkTile.inRangeOfBlack.append(self)

	#Pawns can move an extra space if they haven't been moved yet, but can't jump over other pieces
	if startingTile == curTile and chessBoard.board[curTile.boardIndex.x][curTile.boardIndex.y + moveDir].heldPiece == null:
		tempMoves.append(chessBoard.board[curTile.boardIndex.x][curTile.boardIndex.y + (moveDir*2)])
		chessBoard.board[curTile.boardIndex.x][curTile.boardIndex.y + moveDir].EnPasse = self
		chessBoard.board[curTile.boardIndex.x][curTile.boardIndex.y + moveDir].EnPasseTimeout = 1
	
	return tempMoves
