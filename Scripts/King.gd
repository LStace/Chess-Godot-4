extends ChessPiece

signal Game_Over(king)
var isInCheck : bool = false
var kingHolder : Area2D

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
			elif checkTile.inRangeOfPieces[int(!isWhite)] != []: continue
			else: tempMoves.append(checkTile)
	
	#checks if the king is in check
	if curTile.inRangeOfPieces[int(!isWhite)] != []: isInCheck = true
	else: isInCheck = false
	#The game ends if the king is in check and can't escape it.
	if tempMoves == [] and curTile.inRangeOfPieces[int(!isWhite)].size() > 1:
		Game_Over.emit(self)
	elif curTile.inRangeOfPieces[int(!isWhite)].size() == 1:
		kingHolder = curTile.inRangeOfPieces[int(!isWhite)][0]
		print(self.name + " " + kingHolder.name) #debug
	else: kingHolder == null
	
	return tempMoves
