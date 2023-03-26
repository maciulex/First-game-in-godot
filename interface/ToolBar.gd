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
	var sprite = textureName.get_node("Sprite").duplicate()
	if (textureName.item_scale != null):
		sprite.scale *= textureName.item_scale
	return sprite;

func loadSpriteForToolBarIndex(i):
	var sprite = getSprite(playerData.toolbarItems[i]);
	if (sprite == null): 
		toolbarBoxes[i].get_node("spriteContainer").get_children()[0].texture = null;
		return;
	toolbarBoxes[i].get_node("spriteContainer").get_children()[0].queue_free();
	toolbarBoxes[i].get_node("spriteContainer").add_child(sprite);

func loadSpritesForToolBar():
	for i in range(5):
		loadSpriteForToolBarIndex(i);
	
func updateToolbarAmountValAtIndex(i):
	if (playerData.toolbarItems[i] == null): 
		toolbarBoxes[i].get_node("Amount").visible = false;
		return;			
	if (playerData.toolbarItems[i].get("DisplayAmount")):
		toolbarBoxes[i].get_node("Amount").visible = true;
		toolbarBoxes[i].get_node("Amount").text = str(playerData.toolbarItems[i].get("Amount"));
	else:
		toolbarBoxes[i].get_node("Amount").visible = false;

func updateToolBarAmountVals():
	for i in range(5):
		updateToolbarAmountValAtIndex(i);

func updateToolbarAtIndex(index):
	loadSpriteForToolBarIndex(index);
	updateToolbarAmountValAtIndex(index);
	pass;

func _physics_process(delta):
	for i in range(5):
		if (Input.get_action_strength(str(i+1)) == 1):
			selectItemInToolBar(i)

func _ready():
	selectItemInToolBar();
	loadSpritesForToolBar()
	updateToolBarAmountVals();
