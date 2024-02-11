extends Area2D
class_name ChessPiece

#References to game manager and the board
@onready var chessBoard : TileMap = get_node("/root/Main/Board")
@onready var main = get_node("/root/Main")
#General information about the piece
@export var startingTile : Area2D
var hasMoved : bool = false
var curTile : Area2D
@export var pieceType : String = "Template"
@export var isWhite : bool
var king : Area2D
#Used for check rules
var isHoldingKing : bool = false
var pathToKing : Array
var blocking : Array
# Variables for moving the piece
@onready var targetTile = startingTile
var isMoving : bool = false
var isSelected : bool = false
var toBeCaptured = false
var potentialMoves = []
var validMoves : Array

#Signal to deselect piece
signal Turn_Over
signal Check_Pawn_Promotion

func _ready():
	#Sets piece up
	global_position = startingTile.global_position
	
	curTile = startingTile
	curTile.heldPiece = self
	
	if !isWhite:
		$Sprite.modulate = "000000"
		
	pieceSpecificConnection()	

func _physics_process(delta):
	#Moves piece to new tile
	if isMoving == true:
		if targetTile.global_position == global_position:
			isMoving = false
			main.hasMoved = true
			hasMoved = true
			if pieceType == "Pawn": Check_Pawn_Promotion.emit()
			#Tell castling rook to move
			elif pieceType == "King" and targetTile.castle:
				self.tileToRook[targetTile][0].targetTile = self.tileToRook[targetTile][1]
				self.tileToRook[targetTile][0].isMoving = true
				self.tileToRook[targetTile][1].heldPiece = self.tileToRook[targetTile][0]
			else: emit_signal("Turn_Over")
		else:
			global_position = global_position.move_toward(targetTile.global_position, 1000 * delta)

func pieceSpecificConnection():
	pass

#Gets all valid moves
func _on_prepare_next_turn():
	potentialMoves = getValidMoves()

#Gets valid moves (script is overwritten in child scripts)
func getValidMoves():
	var tempMoves = []
	for col in range(-1, 2):
		if curTile.boardIndex.x + col < 0 or curTile.boardIndex.x + col >= 8: continue
		for row in range(-1, 2):
			if curTile.boardIndex.y + row < 0 or curTile.boardIndex.y + row >= 8: continue
			tempMoves.append(chessBoard.board[curTile.boardIndex.x + col][curTile.boardIndex.y + row])
	
	return tempMoves

func isMoveLegal(column, row, pathBlocked):
	#Check if the move is out of range
	if column >= 8 or column < 0 or row >= 8 or row < 0:
		return "OUT OF RANGE"
	else:
		#Gets tile to check
		var checkTile = chessBoard.board[column][row]
		#tells king pieces that it will be in check if moved to this tile
		if !pathBlocked: checkTile.inRangeOfPieces[int(isWhite)].append(self)
		
		#check if the tile is holding another piece
		if checkTile.heldPiece != null and checkTile.heldPiece != self:
			#Check if the piece belongs to the other player
			if checkTile.heldPiece.isWhite != isWhite:
				#Check if the piece is a king
				if checkTile.heldPiece.pieceType == "King" and pieceType!= "King":
					if !pathBlocked:
						isHoldingKing = true
						checkTile.heldPiece.potentialMoves = checkTile.heldPiece.getValidMoves()
					return "HOLDS ENEMY KING"
				else:
					return "HOLDS ENEMY"
			else:
				return "HOLDS ALLY"
		else:
			return "EMPTY"

#Used by rook, bishop & queen
func get_Tile_Path(moveDir : Array):
	var tempMoves = []
	#Current index on board
	var curCol = curTile.boardIndex.x
	var curRow = curTile.boardIndex.y
	
	for dir in range(0,len(moveDir)):
		var tempPath = []
		var pathBlock : Area2D = null
		for tile in range(1,8):
			#Index of tile to be checked
			var checkCol = curCol + (tile * moveDir[dir][0])
			var checkRow = curRow + (tile * moveDir[dir][1])
			#Check move legality
			var checkTileResults = isMoveLegal(checkCol, checkRow, pathBlock != null)
			#Piece can only move within the board
			if checkTileResults == "OUT OF RANGE": break
			var checkTile = chessBoard.board[checkCol][checkRow]
			tempPath.append(checkTile)
			#Piece can move to empty spaces and capture enemy pieces
			if checkTileResults == "EMPTY" and pathBlock == null: tempMoves.append(checkTile)
			elif checkTileResults == "HOLDS ENEMY":
				if pathBlock == null:
					tempMoves.append(checkTile)
					pathBlock = checkTile.heldPiece
				else:
					break
				
			#Piece cannot jump over other pieces
			elif checkTileResults == "HOLDS ALLY":
				break
			elif checkTileResults == "HOLDS ENEMY KING":
				pathToKing = tempPath
				if pathBlock != null:
					pathBlock.blocking.append(self)
				break
	
	return tempMoves

#Piece is captured
func _on_area_entered(area):
	if area.is_in_group("Pieces") and toBeCaptured:
		queue_free()
