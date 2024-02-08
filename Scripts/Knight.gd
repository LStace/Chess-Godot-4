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
		#Checks the legality of the tile
		var checkTileResults = isMoveLegal(curCol + movement[i][0], curRow + movement[i][1], false)
		#Prevents out of range index
		if checkTileResults == "OUT OF RANGE": continue
		var checkTile = chessBoard.board[curCol + movement[i][0]][curRow + movement[i][1]]
		#Knight can move to empty tiles and tiles holding enemy pieces
		if checkTileResults == "EMPTY" or checkTileResults == "HOLDS ENEMY":
			tempMoves.append(checkTile)

	return tempMoves

