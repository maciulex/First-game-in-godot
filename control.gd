extends Control

signal itemClicked

func _on_items_on_ground_item_clicked(index):
	itemClicked.emit(index)


func _on_player_item_picked():
	$ToolBar.loadSpritesForToolBar()
