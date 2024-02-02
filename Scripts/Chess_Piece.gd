extends Area2D
class_name ChessPiece

#References to game manager and the board
@onready var chessBoard : TileMap = get_node("/root/Main/Board")
@onready var main = get_node("/root/Main")
#General information about the piece
@export var startingTile : Area2D
var curTile : Area2D
@export var pieceType : String = "Template"
@export var isWhite : bool
var king : Area2D
#Used for check rules
var isHoldingKing : bool = false
var pathToKing : Array
# Variables for moving the piece
@onready var targetTile = startingTile
var isMoving : bool = false
var isSelected : bool = false
var toBeCaptured = false
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
	var king = chessBoard.kings[int(isWhite)]
	isHoldingKing = false
	pathToKing = []
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
		checkTile.inRangeOfPieces[int(isWhite)].append(self)
		
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
		var tempPath = []
		for tile in range(1,8):
			#Index of tile to be checked
			var checkCol = curCol + (tile * moveDir[dir][0])
			var checkRow = curRow + (tile * moveDir[dir][1])
			#Check move legality
			var checkTileResults = isMoveLegal(checkCol, checkRow)
			#Piece can only move within the board
			if checkTileResults == "OUT OF RANGE": break
			var checkTile = chessBoard.board[checkCol][checkRow]
			tempPath.append(checkTile)
			#Piece can move to empty spaces and capture enemy pieces
			if checkTileResults == "EMPTY" or checkTileResults == "HOLDS ENEMY":
				tempMoves.append(checkTile)
			#Piece cannot jump over other pieces
			if checkTileResults == "HOLDS ALLY" or checkTileResults == "HOLDS ENEMY":
				break
			elif checkTileResults == "HOLDS ENEMY KING":
				pathToKing = tempPath
				break
	
	return tempMoves

#Piece is captured
func _on_area_entered(area):
	if area.is_in_group("Pieces") and toBeCaptured:
		queue_free()
