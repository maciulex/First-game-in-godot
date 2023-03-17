extends CharacterBody2D

@export var movement_speed : float = 100;
@export var knotbackStrength: float = 600;
@export var toolCoolDownTime : float = 1;
@onready var animation_tree = $AnimationTree;
var KnockbackRays : Array;
signal building;
signal health;
var playerData;

func _ready():
	playerData = get_node("/root/PlayerData");
	self.health.connect($Control/HPValLabel.updateHp);
	KnockbackRays = [
		[
			$RayCastsContainer/RayCast2D1,#bottom-middle					
			$RayCastsContainer/RayCast2D2,#bottom-left
			$RayCastsContainer/RayCast2D8#right-bottom
		],
		[
			$RayCastsContainer/RayCast2D7,#right-middle
			null,
			$RayCastsContainer/RayCast2D3#left-middle
		],
		[
			$RayCastsContainer/RayCast2D4,#left-top
			$RayCastsContainer/RayCast2D5,#top-middle
			$RayCastsContainer/RayCast2D6#top-right
		]
	];
	
func _physics_process(delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	if (playerData.movementBlock):
		return;	
	
	var toolUse = Input.get_action_strength("space");
	if (toolUse && !playerData.toolCoolDown):
		$Timer.start(toolCoolDownTime);
		playerData.toolCoolDown = true;
		useTool(input_direction);
	else:
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
	animation_tree.set("parameters/UseTool/UseAxe/blend_position", playerData.lookingDirection);	
	
	pass;

func update_animation(actionType : String, vector : Vector2):
	match actionType:
		"movement":
			animationForWalkOrIdle(vector);
		"toolUse":
			animationForTools();

func _on_area_2d_area_entered(area):
	match area.name:
		"House Entrance":
			building.emit("enter");
			#print("emitted")
		"HouseExit":
			building.emit("exit");
	pass # Replace with function body.

func getColliderFromVector(vector : Vector2):
	var index = 0;
	match vector.x:
		1, -1:
			pass;
	pass;
	

func blockPlayerMovement():
	playerData.movementBlock = true;
	update_animation("movement", Vector2.ZERO);

func useTool(lookingAt: Vector2):
	blockPlayerMovement();
	update_animation("toolUse", lookingAt);
	match playerData.equipedTool:
		playerData.tools.Axe:
			
			pass;

func getVectorOfColidedBody(body):
	var coll = null;
	for y in range(3):
		for x in range(3):
			if (KnockbackRays[y][x] != null && KnockbackRays[y][x].get_collider() == body):
				coll = 	Vector2(x,y);
				if (y==1): return coll;
	return coll;

func getFirstEmptyKnockBackRay():
	for y in range(3):
		for x in range(3):
			if (KnockbackRays[y][x] != null && KnockbackRays[y][x].get_collider() == null):
				return Vector2(x,y)

func _on_character_collision_body_entered(body):
	if (body.is_in_group("Enemys")):
		var collBody = getVectorOfColidedBody(body)
		print(collBody);
		collBody.x = (collBody.x-1);		
		collBody.y = (collBody.y-1);		
		if (KnockbackRays[collBody.y][collBody.x].get_collider() != null):
			getFirstEmptyKnockBackRay();
		print(collBody);
			
		velocity = collBody * knotbackStrength;
		move_and_slide();
		playerData.health -= 10;
		health.emit(playerData.health);
	pass # Replace with function body.


func _on_animation_tree_animation_finished(anim_name):
	print("1 ",anim_name);
	if (anim_name.contains("Use")):
		animation_tree.set("parameters/conditions/isIdle", true);
		animation_tree.set("parameters/conditions/useTool", false);
		playerData.movementBlock = false;

#function act as guard to ensure that 
func _on_timer_timeout():
	if (playerData.toolCoolDown):
		playerData.toolCoolDown = false;
	pass # Replace with function body.
