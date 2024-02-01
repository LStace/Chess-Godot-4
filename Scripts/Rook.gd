extends ChessPiece

#Gets valid moves for a rook
func getValidMoves():
	#Algorithm is inside base class because it is also used by the queen
	return get_Tile_Path([[0, 1],[1, 0],[0, -1],[-1, 0]])
