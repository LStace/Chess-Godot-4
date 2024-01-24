extends CharacterBody2D
class_name ChessPiece

@export var startingTile : Area2D
@export var pieceType : String = "Template"
@export var pieceSprite : Texture2D
@export var isWhite : bool = true
@export var isSelected : bool = false

# Variables for moving the piece
@onready var targetTile = startingTile
var isMoving : bool = false

@onready var chessBoard : TileMap = get_node("/root/Main/Board")

#Signal to deselect piece
signal Turn_Over()

func _ready():
	#Sets piece up
	$Sprite.texture = pieceSprite
	global_position = startingTile.global_position
	Turn_Over.connect(chessBoard._on_Turn_Over)
	
	if !isWhite:
		$Sprite.modulate = "000000"


func _physics_process(delta):
	#Moves piece to new tile
	if isMoving == true:
		if targetTile.global_position == global_position:
			isMoving = false
			emit_signal("Turn_Over")
		else:
			global_position = global_position.move_toward(targetTile.global_position, 1000 * delta)
