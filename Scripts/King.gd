extends ChessPiece

signal Game_Over(king)
signal inCheck(king)
var isInCheck : bool = false

func pieceSpecificConnection():
	Game_Over.connect(main._on_Game_Over)

func getValidMoves():
	var tempMoves = []
	for col in range(-1, 2):
		for row in range(-1, 2):
			var checkTileResult = isMoveLegal(curTile.boardIndex.x + col, curTile.boardIndex.y + row)
			if checkTileResult == "OUT OF RANGE": continue
			var checkTile = chessBoard.board[curTile.boardIndex.x + col][curTile.boardIndex.y + row]
			#King piece can't move to a tile occupied by an ally
			if checkTile.heldPiece != null and checkTile.heldPiece.isWhite == isWhite: continue
			#King piece cannot move into a tile that is in range of an enemy piece
			elif isWhite and checkTile.inRangeOfBlack != []: continue
			elif !isWhite and checkTile.inRangeOfWhite != []: continue
			else: tempMoves.append(checkTile)
	
	#checks if the king is in check
	if isWhite and curTile.inRangeOfBlack != []: isInCheck = true
	elif !isWhite and curTile.inRangeOfWhite != []: isInCheck = true
	#The game ends if the king is in check and can't escape it.
	if tempMoves == [] and ((isWhite and curTile.inRangeOfBlack.size() > 1) or (!isWhite and curTile.inRangeOfWhite.size() > 1)):
		Game_Over.emit(self)
	
	return tempMoves
