extends Area2D

var heldPiece : Area2D #Chess piece currently held by the tile. 
#facilitates the enpasse movement of pawns
var EnPasse : Area2D
var EnPasseTimeout : int = 0
var boardIndex : Vector2
#Stores pieces that can move to this tile
var inRangeOfWhite = []
var inRangeOfBlack = []

@onready var chessBoard : TileMap = get_node("/root/Main/Board")

signal Tile_Clicked(tile, piece)

# Called when the node enters the scene tree for the first time.
func _ready():
	#Connects signal to board
	Tile_Clicked.connect(chessBoard._on_Tile_Clicked)


#Gets which piece has moved through it and holds it if it is the target tile
func _on_area_entered(body):
	if heldPiece == null and body.is_in_group("Pieces") and body.targetTile == self:
		heldPiece = body
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
		print("%s clicked" % self.name)
		Tile_Clicked.emit(self, heldPiece)
