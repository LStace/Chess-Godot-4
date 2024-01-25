extends TileMap

#Data about the chess board setup
@export var A1Centre : Vector2 = Vector2(-224, 224)
@export var tileSize : int = 64
#Stores references to all board tiles
#Board[column][row]
@onready var board  = [
	[$Tiles/A1, $Tiles/A2, $Tiles/A3, $Tiles/A4, $Tiles/A5, $Tiles/A6, $Tiles/A7, $Tiles/A8],
	[$Tiles/B1, $Tiles/B2, $Tiles/B3, $Tiles/B4, $Tiles/B5, $Tiles/B6, $Tiles/B7, $Tiles/B8],
	[$Tiles/C1, $Tiles/C2, $Tiles/C3, $Tiles/C4, $Tiles/C5, $Tiles/C6, $Tiles/C7, $Tiles/C8],
	[$Tiles/D1, $Tiles/D2, $Tiles/D3, $Tiles/D4, $Tiles/D5, $Tiles/D6, $Tiles/D7, $Tiles/D8],
	[$Tiles/E1, $Tiles/E2, $Tiles/E3, $Tiles/E4, $Tiles/E5, $Tiles/E6, $Tiles/E7, $Tiles/E8],
	[$Tiles/F1, $Tiles/F2, $Tiles/F3, $Tiles/F4, $Tiles/F5, $Tiles/F6, $Tiles/F7, $Tiles/F8],
	[$Tiles/G1, $Tiles/G2, $Tiles/G3, $Tiles/G4, $Tiles/G5, $Tiles/G6, $Tiles/G7, $Tiles/G8],
	[$Tiles/H1, $Tiles/H2, $Tiles/H3, $Tiles/H4, $Tiles/H5, $Tiles/H6, $Tiles/H7, $Tiles/H8]]

#White starts first
var whiteTurn : bool = true

#Stores reference to piece player is currently moving
var selectedPiece : Area2D

#Stores whether a piece is being clicked on in that frame
#prevents player from moving to occupied space.
var pieceInClickedTile : bool = false

signal prepare_next_turn

# Called when the node enters the scene tree for the first time.
func _ready():
	#Tell all tiles their indexes
	for i in range(0, len(board)):
		for j in range(0, len(board)):
			board[i][j].boardIndex = Vector2(i, j)
	
	StartTurn()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		#Deselect selected piece if right mouse button is clicked
		if event.button_index == MOUSE_BUTTON_RIGHT:
			DeselectPiece()

func _on_Tile_Clicked(tile, tilePiece):
	if tilePiece != null:
		#Player can only select their pieces
		if selectedPiece == null and whiteTurn == tilePiece.isWhite:
			SelectPiece(tilePiece)
		elif selectedPiece != null and whiteTurn != tilePiece.isWhite and tilePiece.pieceType != "King":
			tilePiece.toBeCaptured = true
			tile.heldPiece = null
			movePiece(tile)
	elif tilePiece == null and selectedPiece != null:
		movePiece(tile)

func StartTurn():
	prepare_next_turn.emit()

#Signal connect from chess piece script
#Deselects and changes turn
func _on_Turn_Over():
	DeselectPiece()
	whiteTurn = !whiteTurn
	prepare_next_turn.emit()

#Selects piece
func SelectPiece(chessPiece):
	selectedPiece = chessPiece
	chessPiece.isSelected = true

#Deselects piece
func DeselectPiece():
	if selectedPiece != null and !selectedPiece.isMoving:
		selectedPiece.isSelected = false
		selectedPiece = null

#Sets piece's destination
func movePiece(tile):
	if tile in selectedPiece.validMoves:
		selectedPiece.isMoving = true
		selectedPiece.targetTile = tile
