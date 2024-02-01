extends Area2D
class_name ChessPiece

@export var startingTile : Area2D
var curTile : Area2D
var isHoldingKing : bool = false
@export var pieceType : String = "Template"
@export var isWhite : bool
var isSelected : bool = false
var toBeCaptured = false

# Variables for moving the piece
@onready var targetTile = startingTile
var isMoving : bool = false

@onready var chessBoard : TileMap = get_node("/root/Main/Board")
@onready var main = get_node("/root/Main")
var validMoves = []

#Signal to deselect piece
signal Turn_Over
signal Check_Pawn_Promotion

func _ready():
	#Sets piece up
	global_position = startingTile.global_position
	Turn_Over.connect(main._on_Turn_Over)
	
	curTile = startingTile
	curTile.heldPiece = self
	
	if !isWhite:
		$Sprite.modulate = "000000"
	
	main.prepare_next_turn.connect(_on_prepare_next_turn)
	pieceSpecificConnection()	

func _physics_process(delta):
	#Moves piece to new tile
	if isMoving == true:
		if targetTile.global_position == global_position:
			isMoving = false
			main.hasMoved = true
			if pieceType == "Pawn": Check_Pawn_Promotion.emit()
			else: emit_signal("Turn_Over")
		else:
			global_position = global_position.move_toward(targetTile.global_position, 1000 * delta)

func pieceSpecificConnection():
	pass

#Gets all valid moves
func _on_prepare_next_turn():
	isHoldingKing = false
	validMoves = getValidMoves()

#Gets valid moves (script is overwritten in child scripts)
func getValidMoves():
	var tempMoves = []
	for col in range(-1, 2):
		if curTile.boardIndex.x + col < 0 or curTile.boardIndex.x + col >= 8: continue
		for row in range(-1, 2):
			if curTile.boardIndex.y + row < 0 or curTile.boardIndex.y + row >= 8: continue
			tempMoves.append(chessBoard.board[curTile.boardIndex.x + col][curTile.boardIndex.y + row])
	
	return tempMoves

func isMoveLegal(column, row):
	#Check if the move is out of range
	if column >= 8 or column < 0 or row >= 8 or row < 0:
		return "OUT OF RANGE"
	else:
		#Gets tile to check
		var checkTile = chessBoard.board[column][row]
		#tells king pieces that it will be in check if moved to this tile
		if isWhite: 
			checkTile.inRangeOfWhite.append(self)
		else: 
			checkTile.inRangeOfBlack.append(self)
		
		#check if the tile is holding another piece
		if checkTile.heldPiece != null and checkTile.heldPiece != self:
			#Check if the piece belongs to the other player
			if checkTile.heldPiece.isWhite != isWhite:
				#Check if the piece is a king
				if checkTile.heldPiece.pieceType == "King":
					isHoldingKing = true
					checkTile.heldPiece.validMoves = checkTile.heldPiece.getValidMoves()
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
		for tile in range(1,8):
			#Index of tile to be checked
			var checkCol = curCol + (tile * moveDir[dir][0])
			var checkRow = curRow + (tile * moveDir[dir][1])
			#Check move legality
			var checkTileResults = isMoveLegal(checkCol, checkRow)
			#Piece can only move within the board
			if checkTileResults == "OUT OF RANGE": break
			var checkTile = chessBoard.board[checkCol][checkRow]
			#Piece can move to empty spaces and capture enemy pieces
			if checkTileResults == "EMPTY" or checkTileResults == "HOLDS ENEMY":
				tempMoves.append(checkTile)
			#Piece cannot jump over other pieces
			if checkTileResults == "HOLDS ALLY" or checkTileResults == "HOLDS ENEMY" or checkTileResults == "HOLDS ENEMY KING":
				break
	
	return tempMoves

#Piece is captured
func _on_area_entered(area):
	if area.is_in_group("Pieces") and toBeCaptured:
		queue_free()
