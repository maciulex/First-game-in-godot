extends StaticBody2D

@export var PrimaryName = "Furnace"

@export var active :bool = false;
signal boxClicked;

func clickAction():
	if (!active):
		$Control.visible = true;
		active = true;	
		return;
	$Control.visible = false;
	active = false;
	
func inventoryBoxClicked(box_name):
	print("HUEHUE")
	boxClicked.emit("wurur")
	pass;
