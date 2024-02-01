extends ChessPiece

func getValidMoves():
	return get_Tile_Path([[1, 1],[1, -1],[-1, -1],[-1, 1]])
