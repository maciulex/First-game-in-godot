extends Node2D

var movementVector;
var shooter;
var speedModifier: float = 3;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(shooterRid,vectorStart, vectorMovement):
	position = vectorStart;
	movementVector = vectorMovement;
	shooter = shooterRid
	

func _physics_process(delta):
	position += (movementVector*speedModifier);
	pass



func _on_area_2d_area_entered(area):
	if (area.get_rid() != shooter):
		queue_free();


func _on_area_2d_body_entered(body):
	if (body.name == "TileMap"):
		queue_free();
	pass # Replace with function body.
