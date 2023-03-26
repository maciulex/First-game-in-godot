extends CharacterBody2D

@export var movement_speed : float = 100;
@export var knotbackStrength: float = 1400;
@export var toolCoolDownTime : float = 1;
@export var itemCoolDownTime : float = 0.2;

@onready var animation_tree = $AnimationTree;
var KnockbackRays : Array;

signal itemsOngroundUpdate;
signal building;
signal health;
signal toolAction;
signal itemPicked;
var playerData;



func _ready():
	self.health.connect($Control/HPValLabel.updateHp);
	self.itemsOngroundUpdate.connect($Control/ItemsOnGround.updateItemList);
	
	playerData = get_node("/root/PlayerData");
	KnockbackRays = [
		[
			$RayCastsContainer/RayCast2D2,	#bottom-left
			$RayCastsContainer/RayCast2D1,	#bottom-middle					
			$RayCastsContainer/RayCast2D8	#bottom-right
		],
		[
			$RayCastsContainer/RayCast2D3,	#left-middle,
			null,
			$RayCastsContainer/RayCast2D7	#right-middle
		],
		[
			$RayCastsContainer/RayCast2D4,#left-top
			$RayCastsContainer/RayCast2D5,#top-middle
			$RayCastsContainer/RayCast2D6#top-right
		]
	];

func dropItem():
	if (playerData.itemsOnGround.size() == 8 || playerData.toolbarItems[playerData.equipedTool] == null):
		return;
	playerData.toolbarItems[playerData.equipedTool].position = (position - Vector2(25,-25));
	get_tree().get_root().add_child(playerData.toolbarItems[playerData.equipedTool].duplicate());
	playerData.toolbarItems[(playerData.equipedTool)] = null;
	itemPicked.emit(playerData.equipedTool);
	pass;

func fastPickupFirstItem():
	pass;

func _physics_process(delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	var useAction = Input.get_action_strength("space");
	var itemDrop = Input.get_action_strength("q");
	var action = Input.get_action_strength("e");
	
	if (itemDrop > 0):
		dropItem();
	if (useAction && !playerData.toolCoolDown):
		useFromToolBar();
	if (playerData.movementBlock):
		return;	
		
	velocity = input_direction * movement_speed;
	update_animation("movement",input_direction)
	move_and_slide();


func animationForWalkOrIdle(move_input : Vector2):
	if (move_input != Vector2.ZERO):
		animation_tree.set("parameters/conditions/IsMoving", true);
		animation_tree.set("parameters/conditions/isIdle", false);
		playerData.lookingDirection = move_input;
		animation_tree.set("parameters/walk/blend_position", playerData.lookingDirection);
		animation_tree.set("parameters/idle/blend_position", playerData.lookingDirection);
		
	else:
		animation_tree.set("parameters/conditions/IsMoving", false);		
		animation_tree.set("parameters/conditions/isIdle", true);

func animationForTools():
	animation_tree.set("parameters/conditions/IsMoving", false);
	animation_tree.set("parameters/conditions/isIdle", false);
	animation_tree.set("parameters/conditions/useTool", true);
	animation_tree.set("parameters/UseTool/UseTool/blend_position", playerData.toolbarItems[playerData.equipedTool].get("Tool_id"));	
	animation_tree.set("parameters/UseTool/UseTool/"+str(playerData.toolbarItems[playerData.equipedTool].get("Tool_id"))+"/blend_position", playerData.lookingDirection);	
	
	pass;

func update_animation(actionType : String, vector : Vector2):
	match actionType:
		"movement":
			animationForWalkOrIdle(vector);
		"toolUse":
			animationForTools();
		"item":
			pass;

func _on_area_2d_area_entered(area):
	match area.name:
		"House Entrance":
			building.emit("enter");
			#print("emitted")
		"HouseExit":
			building.emit("exit");
		"bullet":
			takeDamage(10);
		"item":
			itemsOngroundUpdate.emit(area.get_parent(), "add");
	pass # Replace with function body.

func _on_character_collision_area_exited(area):
	match area.name:
		"item":
			itemsOngroundUpdate.emit(area.get_parent(), "remove");

func getColliderFromVector(vector : Vector2):
	match int(vector.y):
		-1:
			return KnockbackRays[2][1].get_collider();
		1:
			return KnockbackRays[0][1].get_collider();
	match int(vector.x):
		1: 
			return KnockbackRays[1][2].get_collider();
		-1:
			return KnockbackRays[1][0].get_collider();
	return null;
	

func blockPlayerMovement():
	playerData.movementBlock = true;
	update_animation("movement", Vector2.ZERO);

func useFromToolBar():
	if playerData.toolbarItems[playerData.equipedTool] == null:
		return;
	match playerData.toolbarItems[playerData.equipedTool].get("Item_type"):
		playerData.globals.itemType.tool:
			useTool();
		playerData.globals.itemType.item:
			useItem();
			
func useItem():
	$Timer.start(itemCoolDownTime);
	playerData.toolCoolDown = true;
	match playerData.toolbarItems[playerData.equipedTool].get("Item_id"):
		playerData.globals.items.Porkchop:
			pass;
	pass;	
	
func useTool():
	$Timer.start(toolCoolDownTime);
	playerData.toolCoolDown = true;
	match playerData.toolbarItems[playerData.equipedTool].get("Item_id"):
		playerData.globals.items.Axe:
			blockPlayerMovement();
			update_animation("toolUse", Vector2.ZERO);
			var collider = getColliderFromVector(playerData.lookingDirection);
			if (collider != null && collider.is_in_group("tool_axe_action_group")):
				get_tree().call_group("tool_axe_action_group", "_on_player_tool_action",collider)
				pass;
		playerData.globals.items.Hoe:
			blockPlayerMovement();
			update_animation("toolUse", Vector2.ZERO);
			pass;




func takeDamage(damage:int):
	playerData.health -= damage;
	health.emit(playerData.health);

func _on_character_collision_body_entered(body):
	if (body.is_in_group("Enemys")):
		var angle = position.angle_to_point(body.position)+3.14159265;
		var vector = Vector2.from_angle(angle);
		velocity = vector * knotbackStrength;
		(move_and_slide());
		takeDamage(10);
	pass # Replace with function body.\
	

func _on_animation_tree_animation_finished(anim_name):
	if (anim_name.contains("Use")):
		animation_tree.set("parameters/conditions/isIdle", true);
		animation_tree.set("parameters/conditions/useTool", false);
		playerData.movementBlock = false;

#function act as guard to ensure that 
func _on_timer_timeout():
	if (playerData.toolCoolDown):
		playerData.toolCoolDown = false;
	pass # Replace with function body.


func freeInventorySpace() -> int:
	return playerData.toolbarItems.find(null);

func findNotFullInventoryStack(object) -> int:
	for	i in range(5):
		if (playerData.toolbarItems[i] == null):
			continue;
		if (playerData.toolbarItems[i].get("Item_id") != object.get("Item_id")):
			continue;
		if (playerData.toolbarItems[i].get("MaksStackSize") > playerData.toolbarItems[i].get("Amount") + object.get("Amount")):
			return i;
	return -1;

func addItemToInventoryStack(invIndex, amount):
	playerData.toolbarItems[invIndex].Amount += amount;
	itemPicked.emit(invIndex);	
	pass;

func addNewItemToInventoryFromGround(itemGroundIndex):
	var invSpace = freeInventorySpace();
	if invSpace == -1:
		return;
	playerData.toolbarItems[invSpace] = playerData.itemsOnGround[itemGroundIndex].duplicate();
	freeItemOnGround(itemGroundIndex);
	itemPicked.emit(invSpace);

func freeItemOnGround(itemGroundIndex):
	playerData.itemsOnGround[itemGroundIndex].queue_free();
	playerData.itemsOnGround.remove_at(itemGroundIndex);

func pickUpItemToInventory(onGroundIndex):
	var stackSpace = findNotFullInventoryStack(playerData.itemsOnGround[onGroundIndex]);
	if (stackSpace != -1):
		addItemToInventoryStack(stackSpace, playerData.itemsOnGround[onGroundIndex].get("Amount"));
		freeItemOnGround(onGroundIndex);	
		return;
	addNewItemToInventoryFromGround(onGroundIndex);


func _on_control_item_clicked(index):
	pickUpItemToInventory(index);
	pass;
