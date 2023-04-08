extends StaticBody2D

@export var PrimaryName = "Furnace"

@export var active :bool = false;
@export var inventory = [null,null,null];
@export var displayPattern = "blockFuseTypeInventory";


func _ready():
	var coal = preload("res://utils/items/coal/coal.tscn").instantiate();
	coal.Amount = 10;
	inventory[0] = coal;
