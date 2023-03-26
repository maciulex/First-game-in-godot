extends Node2D


func _ready():
	$Player.building.connect(self.exitBuilding);
	pass;
	
func exitBuilding(val):
	print("exiting");
	get_tree().change_scene_to_file("res://gameLevels/mainLevel/game_level.tscn");
