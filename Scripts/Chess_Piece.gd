extends Area2D
class_name ChessPiece

@export var startingTile : Area2D
var curTile : Area2D
@export var pieceType : String = "Template"
@export var isWhite : bool = true
var isSelected : bool = false
var toBeCaptured = false

# Variables for moving the piece
@onready var targetTile = startingTile
var isMoving : bool = false

@onready var chessBoard : TileMap = get_node("/root/Main/Board")
var validMoves = []

#Signal to deselect piece
signal Turn_Over()

func _ready():
	#Sets piece up
	global_position = startingTile.global_position
	Turn_Over.connect(chessBoard._on_Turn_Over)
	
	curTile = startingTile
	curTile.heldPiece = self
	
	if !isWhite:
		$Sprite.modulate = "000000"
	
	chessBoard.prepare_next_turn.connect(_on_prepare_next_turn)

#Gets all valid moves
func _on_prepare_next_turn():
	validMoves = getValidMoves()

#Gets valid moves (overwritten in child scripts)
func getValidMoves():
	var tempMoves = []
	for col in range(-1, 2):
		if curTile.boardIndex.x + col < 0 or curTile.boardIndex.x + col >= 8: continue
		for row in range(-1, 2):
			if curTile.boardIndex.y + row < 0 or curTile.boardIndex.y + row >= 8: continue
			tempMoves.append(chessBoard.board[curTile.boardIndex.x + col][curTile.boardIndex.y + row])
	
	return tempMoves

#used by queen & rook to get tiles
#Breaks in for loops exist to prevent pieces from jumping over other pieces
func getCrossMoveTiles():
	var tempMoves = []
	#Current index on board
	var curCol = curTile.boardIndex.x
	var curRow = curTile.boardIndex.y
	#[0] = up & right, [1] = down & left
	var moveDir = [1, -1]
	
	#Check up and down
	for i in range(0, 2):
		for j in range(1, 8):
			if curCol + (j * moveDir[i]) >= 8 or curCol + (j * moveDir[i]) < 0: break
			
			var checkTile = chessBoard.board[curCol + (j * moveDir[i])][curRow]
			
			if checkTile.heldPiece != null  and checkTile.heldPiece != self:
				if checkTile.heldPiece.isWhite != isWhite and checkTile.heldPiece.pieceType != "King":
					tempMoves.append(checkTile)
				break
			
			tempMoves.append(checkTile)
	
	#Check right and left
	for i in range(0, 2):
		for j in range(1, 8):
			if curRow + (j * moveDir[i]) >= 8 or curRow + (j * moveDir[i]) < 0: break
			
			var checkTile = chessBoard.board[curCol][curRow + (j * moveDir[i])]
			
			if checkTile.heldPiece != null and checkTile.heldPiece != self:
				if checkTile.heldPiece.isWhite != isWhite and checkTile.heldPiece.pieceType != "King":
					tempMoves.append(checkTile)
				break
			
			tempMoves.append(checkTile)
	return tempMoves

func getDiagonalMoves():
	var tempMoves = []
	#[0] = NorthEast, [1] = SouthEast, [2] = SouthWest, [3] = NorthWest
	var moveDir = [[1,1],[1,-1],[-1,-1],[-1,1]]
	#Current tile's index
	var curCol = curTile.boardIndex.x
	var curRow = curTile.boardIndex.y
	
	for dir in range(0,4):
		for tile in range(1,8):
			var checkCol = curCol + (tile * moveDir[dir][0])
			var checkRow = curRow + (tile * moveDir[dir][1])
			#Check that tile is in range
			if checkCol < 0 or checkCol >= 8 or checkRow < 0 or checkRow >= 8: break
			
			var checkTile = chessBoard.board[checkCol][checkRow]
			
			if checkTile.heldPiece != null and checkTile.heldPiece != self:
				if checkTile.heldPiece.isWhite != isWhite and checkTile.heldPiece.pieceType != "King":
					tempMoves.append(checkTile)
				break
			tempMoves.append(checkTile)
				
	return tempMoves

func _physics_process(delta):
	#Moves piece to new tile
	if isMoving == true:
		if targetTile.global_position == global_position:
			isMoving = false
			emit_signal("Turn_Over")
		else:
			global_position = global_position.move_toward(targetTile.global_position, 1000 * delta)

#Piece is captured
func _on_area_entered(area):
	if area.is_in_group("Pieces") and toBeCaptured:
		queue_free()
