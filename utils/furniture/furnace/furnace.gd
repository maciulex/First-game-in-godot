extends StaticBody2D

@onready var globalData = get_node("/root/GlobalData");
@export var PrimaryName = "Furnace"
@export var active :bool = false;
@export var inventory = [null,null,null];
@export var displayPattern = "blockFuseTypeInventory";

func canBePlacedOnInv(index, item_id):
	match index:
		0:
			match item_id:
				globalData.items.Coal:
					return true;
		1:
			match item_id:
				globalData.items.Porkchop:
					return true;

		
	return false;
	

func _ready():
	var coal = preload("res://utils/items/coal/coal.tscn").instantiate();
	coal.Amount = 10;  
	coal.Item_id = globalData.items.Coal
	coal.Item_type = globalData.itemType.item
	
	inventory[0] = coal;
