extends ChessPiece

func getValidMoves():
	var tempMoves = []
	#Current index on board
	var curCol = curTile.boardIndex.x
	var curRow = curTile.boardIndex.y
	#Vector stores pairs to show how it moves in [x, y]
	#[/][/][/][/][/][/][/]
	#[/][/][0][/][1][/][/]
	#[/][7][/][/][/][2][/]
	#[/][/][/][K][/][/][/]
	#[/][6][/][/][/][3][/]
	#[/][/][5][/][4][/][/]
	#[/][/][/][/][/][/][/]
	var movement = [[-1, 2],[1, 2],[2, 1],[2,-1],[1, -2],[-1, -2],[-2, -1],[-2, 1]]
	
	for i in range(0, 8):
		#Prevents out of range index
		if curCol + movement[i][0] < 0 or curCol + movement[i][0] >= 8 or curRow + movement[i][1] < 0 or curRow + movement[i][1] >= 8:
			continue
		else:
			#Checks that the tile to jump to does not contain an ally piece
			var checkTile = chessBoard.board[curCol + movement[i][0]][curRow + movement[i][1]]
			if isWhite: checkTile.inRangeOfWhite.append(self)
			else: checkTile.inRangeOfBlack.append(self)
			
			if checkTile.heldPiece != null:
				if checkTile.heldPiece.isWhite == isWhite:
					continue
			#adds tile to moves
			tempMoves.append(checkTile)

	return tempMoves

