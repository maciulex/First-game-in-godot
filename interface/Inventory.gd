extends Control

@onready var playerData = get_node("/root/PlayerData");
const inventorySize = 59;
@onready var InventoryBoxes = [
	$ToolBar/itemBox1,
	$ToolBar/itemBox2,
	$ToolBar/itemBox3,
	$ToolBar/itemBox4,
	$ToolBar/itemBox5
];

func selectItemInToolBar(index : int = -1):
	if (index == -1):
		InventoryBoxes[playerData.equipedTool].get_node("UnselectedItem/SelectedItem").visible = true;
		return;
	InventoryBoxes[playerData.equipedTool].get_node("UnselectedItem/SelectedItem").visible = false;
	playerData.equipedTool = index;
	InventoryBoxes[playerData.equipedTool].get_node("UnselectedItem/SelectedItem").visible = true;

func getSprite(textureName):
	match textureName:
		null:
			return null;
	var sprite = textureName.get_node("Sprite").duplicate()
	if (textureName.item_scale != null):
		sprite.scale *= textureName.item_scale
	return sprite;

func loadSpriteForToolBarIndex(i):
	var sprite = getSprite(playerData.Items[i]);
	if (sprite == null): 
		InventoryBoxes[i].get_node("UnselectedItem/spriteContainer").get_children()[0].texture = null;
		return;
	InventoryBoxes[i].get_node("UnselectedItem/spriteContainer").get_children()[0].queue_free();
	InventoryBoxes[i].get_node("UnselectedItem/spriteContainer").add_child(sprite);

func loadSpritesForToolBar():
	for i in range(59):
		loadSpriteForToolBarIndex(i);
	
func updateToolbarAmountValAtIndex(i):
	if (playerData.Items[i] == null): 
		InventoryBoxes[i].get_node("UnselectedItem/Amount").visible = false;
		return;			
	if (playerData.Items[i].get("DisplayAmount")):
		InventoryBoxes[i].get_node("UnselectedItem/Amount").visible = true;
		InventoryBoxes[i].get_node("UnselectedItem/Amount").text = str(playerData.Items[i].get("Amount"));
	else:
		InventoryBoxes[i].get_node("UnselectedItem/Amount").visible = false;

func updateToolBarAmountVals():
	for i in range(59):
		updateToolbarAmountValAtIndex(i);

func updateToolbarAtIndex(index):
	loadSpriteForToolBarIndex(index);
	updateToolbarAmountValAtIndex(index);
	pass;
	
var eqStateChange : bool = false;
func _physics_process(delta):
	if (Input.get_action_strength("eq") > 0 && !eqStateChange):
		$MainInventory.visible = !$MainInventory.visible;
		eqStateChange = true;
	if (Input.get_action_strength("eq") == 0): eqStateChange = false;
	
	for i in range(5):
		if (Input.get_action_strength(str(i+1)) == 1):
			selectItemInToolBar(i)
			
func inventoryBoxClicked(space):
	space = int(space.lstrip("itemBox"))-1;
	if (playerData.Items[space] == null && playerData.Items[playerData.equipedTool] != null):
		swapInventory(space, playerData.equipedTool);
	selectItemInToolBar(space);

func swapInventory(from, to):
	var placeHolder = playerData.Items[from];
	playerData.Items[from] = playerData.Items[to];
	playerData.Items[to] = placeHolder; 
	updateToolbarAtIndex(from);
	updateToolbarAtIndex(to);
func _ready():
	for i in range(6,60):
		InventoryBoxes.append($MainInventory.get_node("itemBox"+str(i)));
	selectItemInToolBar();
	loadSpritesForToolBar()
	updateToolBarAmountVals();







