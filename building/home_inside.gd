extends Node2D


func _ready():
	$Player.building.connect(self.exitBuilding);
	pass;
	
func exitBuilding(val):
	get_tree().change_scene_to_file("res://game_level.tscn");
