extends Control

var playerData;
signal itemClicked;
# Called when the node enters the scene tree for the first time.
func _ready():
	playerData = get_node("/root/PlayerData");
	updateList()
	
func updateList():
	$ItemList.clear();
	for i in range(playerData.itemsOnGround.size()):
		$ItemList.add_item(playerData.itemsOnGround[i].Item_name);

func updateItemList(item, action):
	match action:
		"add":
			playerData.itemsOnGround.append(item)
		"remove":
			playerData.itemsOnGround.erase(item);
					
	updateList();
	pass;




func _on_item_list_item_activated(index):
	itemClicked.emit(index);
