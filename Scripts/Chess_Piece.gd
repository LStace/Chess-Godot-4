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
@onready var main = get_node("/root/Main")
var validMoves = []

#Signal to deselect piece
signal Turn_Over()

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

func pieceSpecificConnection():
	pass

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
	#[0] = up, [1] = right, [2] = down, [3] = left
	var moveDir = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]
	#Loops for each direction
	for i in range(0, 4):
		#The maximum distance the piece can travel is 7 tiles
		for count in range(1, 8):
			var move = moveDir[i] * count
			#Breaks loop if the tile is not in the range of the board
			if curCol + move.x < 0 or curCol + move.x >= 8 or curRow + move.y < 0 or curRow + move.y >= 8: break
			#Gets tile to check
			var checkTile = chessBoard.board[curCol + move.x][curRow + move.y]
			#tells king pieces that it will be in check if moved to this tile
			if isWhite: checkTile.inRangeOfWhite.append(self)
			else: checkTile.inRangeOfBlack.append(self)
			#Piece cannot jump over other pieces
			if checkTile.heldPiece != null and checkTile.heldPiece != self:
				if checkTile.heldPiece.isWhite != isWhite and checkTile.heldPiece.pieceType != "King":
					tempMoves.append(checkTile)
				break
				
			tempMoves.append(checkTile)
		
		
	return tempMoves

#In base class to be accessed by both bishop and queen
func getDiagonalMoves():
	var tempMoves = []
	#[0] = NorthEast, [1] = SouthEast, [2] = SouthWest, [3] = NorthWest
	var moveDir = [[1,1],[1,-1],[-1,-1],[-1,1]]
	#Current tile's index
	var curCol = curTile.boardIndex.x
	var curRow = curTile.boardIndex.y
	
	for dir in range(0,4):
		for tile in range(1,8):
			#Index of ile to be checked
			var checkCol = curCol + (tile * moveDir[dir][0])
			var checkRow = curRow + (tile * moveDir[dir][1])
			#Check that tile is in range
			if checkCol < 0 or checkCol >= 8 or checkRow < 0 or checkRow >= 8: break
			
			var checkTile = chessBoard.board[checkCol][checkRow]
			#tells king pieces that it will be in check if moved to this tile
			if isWhite: checkTile.inRangeOfWhite.append(self)
			else: checkTile.inRangeOfBlack.append(self)
			#piece can't jump over other pieces.
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
