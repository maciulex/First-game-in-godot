extends Node
enum tools {Axe, Hoe};

@export var health : int = 100;
@export var movementBlock : bool = false;
@export var toolCoolDown : bool =  false;
var lookingDirection : Vector2 = Vector2.ZERO;
var cordsBeforeEntringBuilding = Vector2(0,0);



#toolbar
var toolbarItems = [tools.Axe, tools.Hoe];
var equipedTool = 0;

var itemsOnGround : Array = [];

func _ready():
	toolbarItems.resize(5);



