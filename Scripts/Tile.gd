extends Area2D

var heldPiece : Area2D #Chess piece currently held by the tile. 
#facilitates the enpasse movement of pawns
var EnPasse : Area2D
var EnPasseTimeout : int = 0
var boardIndex : Vector2
#Stores pieces that can move to this tile
#[0] = black pieces, [1] = white pieces
var inRangeOfPieces = [[],[]]

var castle : bool = false

signal Tile_Clicked(tile, piece)

#Gets which piece has moved through it and holds it if it is the target tile
func _on_area_entered(body):
	if body.is_in_group("Pieces") and body.targetTile == self:
		heldPiece.curTile = self
		#EnPasse capture
		if body.pieceType == "Pawn" and EnPasse != null and EnPasse == body.canEnPasse:
			EnPasse.queue_free()

#Gets which piece has exited it
func _on_area_exited(body):
	if heldPiece == body:
		heldPiece = null

func _on_input_event(_viewport, event, _shape_idx):
	#Tells the board the tile has been clicked and passes on the information
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Tile_Clicked.emit(self, heldPiece)


func _on_mouse_shape_entered(shape_idx):
	$hoverIndicator.visible = true


func _on_mouse_shape_exited(shape_idx):
	$hoverIndicator.visible = false
