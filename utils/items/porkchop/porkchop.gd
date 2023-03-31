extends Node2D

@onready var globalData = get_node("/root/GlobalData");

@export var Item_id = 0;
@export var Item_type = 0;
const Item_name : String = "Mięsko"; 
const item_scale : Vector2 = Vector2(4,4);

@export var Amount : int = 1;
@export var MaksStackSize : int = 64
@export var DisplayAmount : bool = true;

func _ready():
	Item_id = globalData.items.Porkchop;
	Item_type = globalData.itemType.item;
