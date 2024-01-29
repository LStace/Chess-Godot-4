extends ChessPiece

signal Game_Over(king)
var isInCheck : bool = false

func pieceSpecificConnection():
	Game_Over.connect(main._on_Game_Over)

func getValidMoves():
	var tempMoves = []
	for col in range(-1, 2):
		if curTile.boardIndex.x + col < 0 or curTile.boardIndex.x + col >= 8: continue
		for row in range(-1, 2):
			#King can move one tile in any direction
			if curTile.boardIndex.y + row < 0 or curTile.boardIndex.y + row >= 8: continue
			var checkTile = chessBoard.board[curTile.boardIndex.x + col][curTile.boardIndex.y + row]
			if isWhite: checkTile.inRangeOfWhite.append(self)
			else: checkTile.inRangeOfBlack.append(self)
			if checkTile.heldPiece != null and checkTile.heldPiece.isWhite == isWhite: continue
			#King piece cannot move into a tile that is in range of an enemy piece
			elif isWhite and checkTile.inRangeOfBlack != []: continue
			elif !isWhite and checkTile.inRangeOfWhite != []: continue
			tempMoves.append(checkTile)
	
	#checks if the king is in check
	if isWhite and curTile.inRangeOfBlack != []: isInCheck = true
	elif !isWhite and curTile.inRangeOfWhite != []: isInCheck = true
	#The game ends if the king is in check and can't escape it.
	if tempMoves == [] and ((isWhite and curTile.inRangeOfBlack.size() > 1) or (!isWhite and curTile.inRangeOfWhite.size() > 1)):
		Game_Over.emit(self)
		print(curTile.inRangeOfBlack)
		print(curTile.inRangeOfWhite)
	
	return tempMoves
