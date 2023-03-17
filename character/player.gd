extends CharacterBody2D

@export var movement_speed : float = 100;
@export var knotbackStrength: float = 400;
@onready var animation_tree = $AnimationTree;
var KnockbackRays : Array;
signal building;
signal health;
var playerData;

func _ready():
	playerData = get_node("/root/PlayerData");
	self.health.connect($Control/HPValLabel.updateHp);
	KnockbackRays = [
		$RayCastsContainer/RayCast2D1,#bottom-middle
		$RayCastsContainer/RayCast2D2,#next going clockwise by 45 deg
		$RayCastsContainer/RayCast2D3,
		$RayCastsContainer/RayCast2D4,
		$RayCastsContainer/RayCast2D5,
		$RayCastsContainer/RayCast2D6,
		$RayCastsContainer/RayCast2D7,
		$RayCastsContainer/RayCast2D8
	];
	
func _physics_process(delta):
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	var toolUse = Input.get_action_strength("space");
	if (toolUse):
		useTool(input_direction);
		
	if (!playerData.movementBlock):
		velocity = input_direction * movement_speed;
		update_animation("movement",input_direction)
		move_and_slide();


func animationForWalkOrIdle(move_input : Vector2):
	if (move_input != Vector2.ZERO):
		animation_tree.set("parameters/conditions/IsMoving", true);
		animation_tree.set("parameters/conditions/isIdle", false);
		animation_tree.set("parameters/walk/blend_position", move_input);
	else:
		animation_tree.set("parameters/conditions/IsMoving", false);		
		animation_tree.set("parameters/conditions/isIdle", true);

func animationForTools(vector : Vector2):
	animation_tree.set("parameters/conditions/IsMoving", false);
	animation_tree.set("parameters/conditions/isIdle", false);
	animation_tree.set("parameters/conditions/useTool", true);
	animation_tree.set("parameters/UseTool/UseAxe/blend_position", vector);	
	
	pass;

func update_animation(actionType : String, vector : Vector2):
	match actionType:
		"movement":
			animationForWalkOrIdle(vector);
		"toolUse":
			animationForTools(vector);

func _on_area_2d_area_entered(area):
	match area.name:
		"House Entrance":
			building.emit("enter");
			#print("emitted")
		"HouseExit":
			building.emit("exit");
	pass # Replace with function body.

func getOpposingColidingVector():
	var object = null;
	for i in 8:
		if (object == null && KnockbackRays[i].get_collider() == null):		
			object = i;
		elif KnockbackRays[i].get_collider() != null && KnockbackRays[(i+4)%8].get_collider() == null:
			return (i+4)%8;
			pass;
	return object;

func blockPlayerMovement():
	playerData.movementBlock = true;
	update_animation("movement", Vector2.ZERO);

func useTool(lookingAt: Vector2):
	blockPlayerMovement();
	update_animation("toolUse", lookingAt);
	
	pass;

	

func _on_character_collision_body_entered(body):
	if (body.is_in_group("Enemys")):
		var knotbackDir = getOpposingColidingVector();
		var knotbackVector = Vector2(0,0);
		match knotbackDir:
			0,1,7: 
				knotbackVector.y += 4;
			3,4,5:
				knotbackVector.y -= 4;
		match knotbackDir:
			1,2,3: 
				knotbackVector.x -= 4;
			5,6,7:
				knotbackVector.x += 4;
		velocity = knotbackVector * knotbackStrength;
		move_and_slide();
		playerData.health -= 10;
		health.emit(playerData.health);
	pass # Replace with function body.


func _on_animation_tree_animation_finished(anim_name):
	print("1 ",anim_name);
	if (anim_name.contains("Use")):
		animation_tree.set("parameters/conditions/useTool", false);
		
		playerData.movementBlock = false;


