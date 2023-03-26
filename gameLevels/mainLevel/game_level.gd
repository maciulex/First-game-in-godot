extends Node2D

var PlayerData;

func _ready():
	PlayerData = get_node("/root/PlayerData");
	$Player.building.connect(self.changeSceneToHome)
	if (PlayerData.cordsBeforeEntringBuilding != Vector2.ZERO):
		$Player.position = PlayerData.cordsBeforeEntringBuilding;
		$Player.position.y += 4
		PlayerData.cordsBeforeEntringBuilding = Vector2.ZERO;
	pass;

func changeSceneToHome(val):
	print("entring....", val)
	
	PlayerData.cordsBeforeEntringBuilding = $Player.position;
	get_tree().change_scene_to_file("res://building/home_inside.tscn");
	pass;
