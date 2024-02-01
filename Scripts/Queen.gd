extends ChessPiece

func getValidMoves():
	
	return get_Tile_Path([[0, 1],[1, 1],[1, 0],[1, -1],[0, -1],[-1, -1],[-1, 0],[-1, 1]])
