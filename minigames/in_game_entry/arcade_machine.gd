extends Node2D

@export var PrimaryName = "Arcade_machine"
@export var gameName = "dsa";



func _on_area_2d_area_entered(area):
	if (area.get_parent().name == "Player"):
		$DisplayName.visible = true;

func _on_area_2d_area_exited(area):
	if (area.get_parent().name == "Player"):
		$DisplayName.visible = false;



func _on_display_name_tree_entered():
	$DisplayName.text = gameName;
