extends ChessPiece

#Gets valid moves for a rook
func getValidMoves():
	#Algorithm is inside base class because it is also used by the queen
	return getCrossMoveTiles()
