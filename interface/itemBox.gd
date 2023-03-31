extends Control




func _on_button_pressed():
	#print(get_name().lstrip("itemBox"));
	get_parent().get_parent().inventoryBoxClicked(get_name());
	#print("dsadsa")
