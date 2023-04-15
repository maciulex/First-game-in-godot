extends Node2D

var GlobalData;

func quit():
	if (Input.get_action_strength("q")):
		get_tree().change_scene_to_file(GlobalData.CombackSceneFromArcade);
	

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalData = get_node("/root/GlobalData");

	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var useAction = Input.get_action_strength("space");
	var action = Input.get_action_strength("e");
	
	quit();
	pass
