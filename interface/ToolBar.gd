extends Control


@onready var playerData = get_node("/root/PlayerData");
@onready var toolbarBoxes = [
	$UnselectedItem1,
	$UnselectedItem2,
	$UnselectedItem3,
	$UnselectedItem4,
	$UnselectedItem5
];

func selectItemInToolBar(index : int = -1):
	if (index == -1):
		toolbarBoxes[playerData.equipedTool].get_node("SelectedItem").visible = true;
		return;
	toolbarBoxes[playerData.equipedTool].get_node("SelectedItem").visible = false;
	playerData.equipedTool = index;
	toolbarBoxes[playerData.equipedTool].get_node("SelectedItem").visible = true;

func getSprite(textureName):
	match textureName:
		null:
			return null;
		playerData.items.Axe:
			return  $icons/axe.duplicate();				
		playerData.items.Hoe:
			return $icons/hoe.duplicate();	
	print( textureName.get_node("Sprite"));
	var sprite = textureName.get_node("Sprite").duplicate()
	if (textureName.item_scale != null):
		sprite.scale *= textureName.item_scale
	return sprite;
	
func loadSpritesForToolBar():
	for i in range(5):
		var sprite = getSprite(playerData.toolbarItems[i]);
		if (sprite == null): return;
		print(sprite);
		toolbarBoxes[i].get_node("spriteContainer").get_children()[0].queue_free();
		toolbarBoxes[i].get_node("spriteContainer").add_child(sprite);
	pass;

func _physics_process(delta):
	for i in range(5):
		if (Input.get_action_strength(str(i+1)) == 1):
			selectItemInToolBar(i)

func _ready():
	selectItemInToolBar();
	loadSpritesForToolBar()

