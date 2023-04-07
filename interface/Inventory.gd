extends Control

@onready var playerData = get_node("/root/PlayerData");
const inventorySize = 59;
var blockInventoryChange : bool = false;


@onready var InventoryBoxes = [
	$ToolBar/itemBox1,
	$ToolBar/itemBox2,
	$ToolBar/itemBox3,
	$ToolBar/itemBox4,
	$ToolBar/itemBox5
];

func selectItemInToolBar(inventoryObject):
	print(inventoryObject.index);
	InventoryBoxes[playerData.equipedTool].get_node("UnselectedItem/SelectedItem").visible = false;
	playerData.equipedTool = inventoryObject.index;
	inventoryObject.get_node("UnselectedItem/SelectedItem").visible = true;

func getSprite(textureName):
	match textureName:
		null:
			return null;
	var sprite = textureName.get_node("Sprite").duplicate()
	if (textureName.item_scale  != null):
		sprite.scale *= textureName.item_scale
	return sprite;

func loadSpriteForToolBarIndex(item, inventoryBox):
	var sprite = getSprite(item);
	if (sprite == null): 
		inventoryBox.get_node("UnselectedItem/spriteContainer").get_children()[0].texture = null;
		return;
	inventoryBox.get_node("UnselectedItem/spriteContainer").get_children()[0].queue_free();
	inventoryBox.get_node("UnselectedItem/spriteContainer").add_child(sprite);

func loadSpritesForToolBar():
	for i in range(59):
		loadSpriteForToolBarIndex(playerData.Items[i], InventoryBoxes[i]);
	
func updateToolbarAmountValAtIndex(item, itemBox):
	if (item == null): 
		itemBox.get_node("UnselectedItem/Amount").visible = false;
		return;			
	if (item.get("DisplayAmount")):
		itemBox.get_node("UnselectedItem/Amount").visible = true;
		itemBox.get_node("UnselectedItem/Amount").text = str(item.get("Amount"));
	else:
		itemBox.get_node("UnselectedItem/Amount").visible = false;

func updateToolBarAmountVals():
	for index in range(59):
		updateToolbarAmountValAtIndex(playerData.Items[index], InventoryBoxes[index]);

func updateToolbarAtIndex(index):
	loadSpriteForToolBarIndex(playerData.Items[index], InventoryBoxes[index]);
	updateToolbarAmountValAtIndex(playerData.Items[index], InventoryBoxes[index]);
	pass;
	
var eqStateChange : bool = false;

func openPlayerInventory():
	if (blockInventoryChange):
		return -1;
	$MainInventory.visible = true;	
	eqStateChange = true;

func closePlayerInventory():
	if (blockInventoryChange):
		return -1;
	$MainInventory.visible = false;	
	eqStateChange = true;
	pass;
	
func togglePlayerInventory():
	if (blockInventoryChange):
		return -1;
	$MainInventory.visible = !$MainInventory.visible;
	eqStateChange = true;

func _physics_process(delta):
	if (Input.get_action_strength("eq") > 0 && !eqStateChange):
		togglePlayerInventory();
	if (Input.get_action_strength("eq") == 0): 
		eqStateChange = false;
	
	for i in range(5):
		if (Input.get_action_strength(str(i+1)) == 1):
			selectItemInToolBar(InventoryBoxes[i])
			
var boxInventoryPattern = null;
var boxInventory = null;

func openBlockInventory(inventory, pattern):
	openPlayerInventory();
	blockInventoryChange = true;
	boxInventoryPattern = pattern;
	boxInventory = inventory;
	match pattern:
		"blockFuseTypeInventory":
			$blockFuseTypeInventory.visible = true;
	pass;

func updateBlockInventory():
	pass;
	
func closeBlockInventory():
	blockInventoryChange = false;
	closePlayerInventory();
	match boxInventoryPattern:
		"blockFuseTypeInventory":
			$blockFuseTypeInventory.visible = false;
	boxInventoryPattern = null;
	boxInventory = null;
	
func inventoryBoxClicked(space):
	if (space.find("BlockInventory") != -1):
		#block inventory Clicked
		
		return;
	space = int(space.lstrip("itemBox"))-1;
	if (playerData.Items[space] == null && playerData.Items[playerData.equipedTool] != null):
		swapInventory(space, playerData.equipedTool);
	selectItemInToolBar(InventoryBoxes[space]);

func swapInventory(from, to):
	var placeHolder = playerData.Items[from];
	playerData.Items[from] = playerData.Items[to];
	playerData.Items[to] = placeHolder; 
	updateToolbarAtIndex(from);
	updateToolbarAtIndex(to);
	
func _ready():
	for i in range(0,5):
		InventoryBoxes[i].index = i;
	for i in range(6,60):
		InventoryBoxes.append($MainInventory.get_node("itemBox"+str(i)));
		InventoryBoxes[i-1].index = i-1;
	selectItemInToolBar(InventoryBoxes[0]);
	loadSpritesForToolBar()
	updateToolBarAmountVals();







