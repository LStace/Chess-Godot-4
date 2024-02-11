extends ChessPiece

signal Game_Over(king)
var isInCheck : bool = false
var kingHolder : Area2D
#If the king can castle
var kingSideCastling : bool = false
var queenSideCastling : bool = false
var tileToRook : Dictionary
#Tile the king would castle to
@onready var kingSideCastlingTile : Area2D
@onready var queenSideCastlingTile : Area2D

func getValidMoves():
	var tempMoves = []
	
	#Tile that a castling king would move to
	kingSideCastlingTile = chessBoard.board[startingTile.boardIndex.x + 2][startingTile.boardIndex.y]
	queenSideCastlingTile = chessBoard.board[startingTile.boardIndex.x - 2][startingTile.boardIndex.y]
	#Check if the king can castle
	queenSideCastling = check_castling(-1, chessBoard.board[startingTile.boardIndex.x - 4][startingTile.boardIndex.y])
	kingSideCastling = check_castling(1, chessBoard.board[startingTile.boardIndex.x + 3][startingTile.boardIndex.y])
	#Tell the tile if it could be castled to.
	queenSideCastlingTile.castle = queenSideCastling
	kingSideCastlingTile.castle = kingSideCastling
	
	#Tile for king to move to: [rook that will castle, tile the rook will move to]
	tileToRook = {
		kingSideCastlingTile : [chessBoard.board[startingTile.boardIndex.x + 3][startingTile.boardIndex.y].heldPiece, chessBoard.board[startingTile.boardIndex.x + 1][startingTile.boardIndex.y]],
		queenSideCastlingTile : [chessBoard.board[startingTile.boardIndex.x - 4][startingTile.boardIndex.y].heldPiece, chessBoard.board[startingTile.boardIndex.x + -1][startingTile.boardIndex.y]]
	}
	
	if queenSideCastling:
		tempMoves.append(queenSideCastlingTile)
	
	if kingSideCastling:
		tempMoves.append(kingSideCastlingTile)
	
	for col in range(-1, 2):
		for row in range(-1, 2):
			var checkTileResult = isMoveLegal(curTile.boardIndex.x + col, curTile.boardIndex.y + row, false)
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
	else: kingHolder == null
	
	return tempMoves

#Check if the king can castle
#direction and the tile the rook would occupy
func check_castling(direction, castleRookTile):
	##King can castle if:
	#It hasn't moved and it's not in check
	#The rook has not moved
	#The spaces it would move through are not in range of enemy pieces
	#There are no other spaces between itself and the rook
	if !hasMoved and !isInCheck\
	and castleRookTile.heldPiece != null\
	and castleRookTile.heldPiece.pieceType == "Rook"\
	and castleRookTile.heldPiece.hasMoved == false\
	and castleRookTile.heldPiece.isWhite == isWhite:
		var tileDistance = abs(curTile.boardIndex.x - castleRookTile.boardIndex.x)
		for i in range(1, 3):
			if !chessBoard.board[curTile.boardIndex.x + (i * direction)][curTile.boardIndex.y].inRangeOfPieces[int(!isWhite)].is_empty()\
			or chessBoard.board[curTile.boardIndex.x + (i * direction)][curTile.boardIndex.y].heldPiece != null:
				return false
		
		if tileDistance == 4 and chessBoard.board[curTile.boardIndex.x + (3 * direction)][curTile.boardIndex.y].heldPiece != null:
				return false
		
		return true
		
	else: return false
