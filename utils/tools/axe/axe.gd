extends Node2D

var globalData;
var initialized : bool = false;

@export var Item_id = 0;
@export var Item_type = 0;
@export var Tool_id = 0;
const Item_name : String = "Siekiera"; 
const item_scale : Vector2 = Vector2(2,2);

func _ready():
	globalData = get_node("/root/GlobalData");
	
	Item_id = globalData.items.Axe;
	Tool_id = globalData.toolsId.Axe;
	Item_type = globalData.itemType.tool;
	initialized = true;
	
func init(globals):
	globalData = globals
	Item_id = globalData.items.Axe;
	Tool_id = globalData.toolsId.Axe;
	Item_type = globalData.itemType.tool;
	initialized = true;
