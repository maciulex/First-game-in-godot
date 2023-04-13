extends Control

@onready var playerData = get_node("/root/PlayerData");
const inventorySize = 59;
var blockInventoryChange : bool = false;


var blockInventoryOpened = null;
var boxInventoryContainer =null;

@onready var InventoryBoxes = [
	$ToolBar/itemBox1,
	$ToolBar/itemBox2,
	$ToolBar/itemBox3,
	$ToolBar/itemBox4,
	$ToolBar/itemBox5
];

func selectItemInToolBar(inventoryObject):
	if (playerData.equipedTool > -1):
		#player inventory/toolbar
		InventoryBoxes[playerData.equipedTool].get_node("UnselectedItem/SelectedItem").visible = false;
	else:
		#inventory for blocks
		boxInventoryContainer.get_node("BlockInventory"+str(playerData.equipedTool*-1)).get_node("UnselectedItem/SelectedItem").visible = false;
		pass;
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
	if (index < 0):
		index = (index*-1)-1;
		loadSpriteForToolBarIndex(    blockInventoryOpened.inventory[index], boxInventoryContainer.get_node("BlockInventory"+str(index+1)));
		updateToolbarAmountValAtIndex(blockInventoryOpened.inventory[index], boxInventoryContainer.get_node("BlockInventory"+str(index+1)));
		return;
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



func openBlockInventory(BLOCK):
	openPlayerInventory();
	blockInventoryChange = true;
	blockInventoryOpened = BLOCK
	match blockInventoryOpened.displayPattern:
		"blockFuseTypeInventory":
			boxInventoryContainer = $blockFuseTypeInventory;
	updateBlockInventory();
	boxInventoryContainer.visible = true;
	
func updateBlockInventory():
	var counter = 1;
	for item in blockInventoryOpened.inventory:
		var inventoryBox = boxInventoryContainer.get_node("BlockInventory"+str(counter));
		updateToolbarAtIndex(counter*-1);
		counter += 1;
	
func closeBlockInventory():
	if (playerData.equipedTool  < 0):
		selectItemInToolBar(InventoryBoxes[0]);
	blockInventoryChange = false;
	closePlayerInventory();
	boxInventoryContainer.visible = false;
			
	boxInventoryContainer= null;
	blockInventoryOpened = null;
	
func inventoryBoxClicked(space):
	print(space, " | ", playerData.equipedTool);
	if (space.find("BlockInventory") != -1):
		#block inventory Clicked
		var blockInvIndex =int(space.lstrip("BlockInventory"));
		if(playerData.equipedTool > 0 && playerData.Items[playerData.equipedTool] != null):
			if (blockInventoryOpened.canBePlacedOnInv(blockInvIndex-1, playerData.Items[playerData.equipedTool].Item_id)):
				swapInventory(playerData.equipedTool, blockInvIndex*-1);				
		selectItemInToolBar(boxInventoryContainer.get_node(str(space)));
		return;
		
		
	space = int(space.lstrip("itemBox"))-1;
	if (	playerData.Items[space] == null && 
			(playerData.Items[playerData.equipedTool] != null || playerData.equipedTool < 0)):
		swapInventory(space, playerData.equipedTool);
	selectItemInToolBar(InventoryBoxes[space]);
#equipedToolOutsideMainInv
func swapInventory(from, to):
	if (from == to):
		return;
	if (from < 0):
		if (to < 0):
			var placeHolder = blockInventoryOpened.inventory[(from*-1)-1];
			blockInventoryOpened.inventory[(from*-1)-1] = blockInventoryOpened.inventory[(to*-1)-1];	
			blockInventoryOpened.inventory[(to*-1)-1] = placeHolder;		
		else:
			var placeHolder = blockInventoryOpened.inventory[(from*-1)-1];
			blockInventoryOpened.inventory[(from*-1)-1] = playerData.Items[to];
			playerData.Items[to] = placeHolder;
	else:
		if (to < 0):
			var placeHolder =playerData.Items[from];
			playerData.Items[from] = blockInventoryOpened.inventory[(to*-1)-1];
			blockInventoryOpened.inventory[(to*-1)-1] = placeHolder;	
		else:
			var placeHolder = playerData.Items[from];
			playerData.Items[from] = playerData.Items[to];
			playerData.Items[to] = placeHolder
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







