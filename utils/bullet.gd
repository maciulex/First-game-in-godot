extends Node2D

var movementVector;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(vectorStart, vectorMovement):
	position = vectorStart;
	movementVector = vectorMovement;
	

func _physics_process(delta):
	position += movementVector;
	pass

