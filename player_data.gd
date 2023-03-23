extends Node
enum tools {Axe};

@export var health : int = 100;
@export var movementBlock : bool = false;
@export var toolCoolDown : bool =  false;
var lookingDirection : Vector2 = Vector2.ZERO;
var equipedTool = tools.Axe;
var cordsBeforeEntringBuilding = Vector2(0,0);



#toolbar
var toolbarItems = ["axe", "hoe"];
var toolbarSelectedItem = 0;

func _ready():
	toolbarItems.resize(5);



