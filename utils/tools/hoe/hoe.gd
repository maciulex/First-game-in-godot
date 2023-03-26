extends Node2D

var initialized :bool = false;

var globalData;

@export var Item_id = -1;
@export var Item_type = 0;
@export var Tool_id = 0;
const Item_name : String = "Motyka"; 
const item_scale : Vector2 = Vector2(2,2);

@export var Amount : int = 1;
@export var MaksStackSize : int = 1;
@export var DisplayAmount : bool = false;

func _ready():
	globalData = get_node("/root/GlobalData");
	
	Item_id = globalData.items.Hoe;
	Tool_id = globalData.toolsId.Hoe;
	Item_type = globalData.itemType.tool;
	initialized = true;

func init(globals):
	globalData = globals;
	
	Item_id = globalData.items.Hoe;
	Tool_id = globalData.toolsId.Hoe;
	Item_type = globalData.itemType.tool;
	
	initialized = true;
