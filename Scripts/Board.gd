extends TileMap

#Data about the chess board setup
@export var A1Centre : Vector2 = Vector2(-224, 224)
@export var tileSize : int = 64

#White starts first
var whiteTurn : bool = true

#Stores reference to piece player is currently moving
var selectedPiece : Area2D

#Stores whether a piece is being clicked on in that frame
#prevents player from moving to occupied space.
var pieceInClickedTile : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


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

#Signal connect from chess piece script
#Deselects and changes turn
func _on_Turn_Over():
	DeselectPiece()
	whiteTurn = !whiteTurn

#Selects piece
func SelectPiece(chessPiece):
	selectedPiece = chessPiece
	chessPiece.isSelected = true
	print(chessPiece.name + " selected") #Debug

#Deselects piece
func DeselectPiece():
	if selectedPiece != null and !selectedPiece.isMoving:
		selectedPiece.isSelected = false
		print(selectedPiece.name + " Deselected") #Debug
		selectedPiece = null

#Sets piece's destination
func movePiece(tile):
	selectedPiece.isMoving = true
	selectedPiece.targetTile = tile
	print(selectedPiece.name + " move to ", tile) #debug
