extends Node

@onready var globals = get_node("/root/GlobalData")


@export var health : int = 100;
@export var movementBlock : bool = false;
@export var toolCoolDown : bool =  false;
var lookingDirection : Vector2 = Vector2.ZERO;
var cordsBeforeEntringBuilding = Vector2(0,0);



#toolbar
@onready var Items = [];
var equipedTool = 0;

var itemsOnGround : Array = [];

func _ready():
	var axe = preload("res://utils/tools/axe/axe.tscn").instantiate();
	var hoe = preload("res://utils/tools/hoe/hoe.tscn").instantiate();
	axe.init(globals)
	hoe.init(globals)
	Items.resize(59);
	Items[0] = axe;
	Items[1] = hoe;



