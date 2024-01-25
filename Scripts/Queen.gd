extends ChessPiece

func getValidMoves():
	#Scripts to get tiles exists in class
	var tempMoves = getCrossMoveTiles()
	var diagMove = getDiagonalMoves()
	
	#Combine arrays
	for i in diagMove: tempMoves.append(i)
	
	return tempMoves
