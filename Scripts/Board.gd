extends TileMap

@onready var main = get_node("/root/Main")
@onready var kings = [get_node("Pieces/BlackKing"),get_node("Pieces/WhiteKing")]
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

#Stores reference to piece player is currently moving
var selectedPiece : Area2D

#Stores whether a piece is being clicked on in that frame
#prevents player from moving to occupied space.
var pieceInClickedTile : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#Tell all tiles their indexes
	for i in range(0, len(board)):
		for j in range(0, len(board)):
			board[i][j].boardIndex = Vector2(i, j)
			board[i][j].Tile_Clicked.connect(_on_Tile_Clicked)

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		#Deselect selected piece if right mouse button is clicked
		if event.button_index == MOUSE_BUTTON_RIGHT:
			DeselectPiece()

func _on_Tile_Clicked(tile, tilePiece):
	if tilePiece != null:
		#Player can only select their pieces
		if selectedPiece == null and main.isWhiteTurn == tilePiece.isWhite:
			SelectPiece(tilePiece)
		#Player captures enemy piece
		elif selectedPiece != null and main.isWhiteTurn != tilePiece.isWhite and tilePiece.pieceType != "King":
			tilePiece.toBeCaptured = true
			tile.heldPiece = null
			movePiece(tile)
	elif tilePiece == null and selectedPiece != null:
		movePiece(tile)

#Selects piece
func SelectPiece(chessPiece):
	selectedPiece = chessPiece
	selectedPiece.validMoves.clear()
	chessPiece.isSelected = true
	
	#Indicates places player can move their piece
	for tile in selectedPiece.potentialMoves:
		var king = kings[int(selectedPiece.isWhite)]
		#Prevents player from making moves that won't take the king out of check when in check
		#Check that this piece isn't the king and the player's king is in check
		#Pawns and Knights can't have their path blocked by other pieces
		#Will the move block the path to the king
		#Will the move capture the piece that is holding the king in check
		#Prevents the king from moving into a space that would result in check
		if selectedPiece.pieceType != "King" and king.isInCheck and\
		((king.kingHolder != null and tile.heldPiece == null and (king.kingHolder.pieceType == "Pawn" or king.kingHolder.pieceType == "Knight")) 
		or king.kingHolder == null
		or (tile.heldPiece == null and (tile not in king.kingHolder.pathToKing)) 
		or (tile.heldPiece != null and tile.heldPiece != king.kingHolder))\
		or (selectedPiece.pieceType == "King" and not tile.inRangeOfPieces[int(!selectedPiece.isWhite)].is_empty()):
			continue
		elif !selectedPiece.blocking.is_empty():
			for piece in selectedPiece.blocking:
				if tile not in piece.pathToKing and tile.heldPiece != piece:
					break
				else:
					tile.get_node("legalTileIndicator").visible = true
					selectedPiece.validMoves.append(tile)
		else: selectedPiece.validMoves.append(tile)

	for tile in selectedPiece.validMoves:
		tile.get_node("legalTileIndicator").visible = true

#Deselects piece
func DeselectPiece():
	if selectedPiece != null and !selectedPiece.isMoving and !main.hasMoved:
		#removes legal move indicator
		for legalTile in selectedPiece.potentialMoves:
			legalTile.get_node("legalTileIndicator").visible = false
		selectedPiece.isSelected = false
		selectedPiece = null
		

#Sets piece's destination
func movePiece(tile):
	if tile in selectedPiece.validMoves:
		#removes legal move indicator
		for legalTile in selectedPiece.potentialMoves:
			legalTile.get_node("legalTileIndicator").visible = false
		selectedPiece.isMoving = true
		selectedPiece.targetTile = tile
		tile.heldPiece = selectedPiece
