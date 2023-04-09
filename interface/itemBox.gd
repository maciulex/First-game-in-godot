extends Control

@export var index : int = -1; 

func _ready():
	if (get_name().find("BlockInventory") != -1):
		index = int(get_name().lstrip("BlockInventory"))*-1;
		print(index)
		
	

func _on_button_pressed():
	#print(get_name().lstrip("itemBox"));
	get_parent().get_parent().inventoryBoxClicked(get_name());
	#print("dsadsa")





