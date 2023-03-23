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
		toolbarBoxes[playerData.toolbarSelectedItem].get_node("SelectedItem").visible = true;
		return;
	toolbarBoxes[playerData.toolbarSelectedItem].get_node("SelectedItem").visible = false;
	playerData.toolbarSelectedItem = index;
	toolbarBoxes[playerData.toolbarSelectedItem].get_node("SelectedItem").visible = true;

func getTexture(textureName):
	match textureName:
		null:
			return null;
		"axe":
			$tools.frame = 1;
			return $tools.duplicate();	
		"hoe":
			$tools.frame = 2;
			return $tools.duplicate();	
	return null;
	
func loadSpritesForToolBar():
	for i in range(5):
		var sprite = getTexture(playerData.toolbarItems[i]);
		if (sprite == null): return;
		sprite.visible = true;
		sprite.name = "Sprite";
		toolbarBoxes[i].get_node("Sprite").queue_free();
		toolbarBoxes[i].add_child(sprite);
	pass;

func _physics_process(delta):
	for i in range(5):
		if (Input.get_action_strength(str(i+1)) == 1):
			selectItemInToolBar(i)

func _ready():
	selectItemInToolBar();
	loadSpritesForToolBar()
