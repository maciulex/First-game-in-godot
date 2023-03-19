extends CharacterBody2D

@export var movement_speed : float = 0.1;
@onready var sprite = $Sprite2D;
@onready var animationTree = $AnimationTree;
@onready var timer = $Timer;
enum COW_STATES {idle, walk};
var COW_STATE : COW_STATES = COW_STATES.idle;
var WalkDir : Vector2 = Vector2(0,0);


func _ready():
	setNewState();
	setAnimation(true, true);
	


func _physics_process(delta):
	if (COW_STATE == COW_STATES.walk):
		move_and_collide(WalkDir)
	pass;


func getWalkDir():
	return Vector2(randi_range(-1,1),randi_range(-1,1))*movement_speed;


func setAnimation(idle: bool, right: bool):
	if (idle):
		animationTree.set("parameters/conditions/isIdle", true);
		animationTree.set("parameters/conditions/isWalking", false);
		WalkDir = Vector2(0,0);
	else:
		animationTree.set("parameters/conditions/isIdle", false);
		animationTree.set("parameters/conditions/isWalking", true);
		if (!right):
			sprite.flip_h = true;
		else:
			sprite.flip_h = false;


func setNewState():
	COW_STATE = randi_range(0,1);
	if (COW_STATE == COW_STATES.idle):
		setAnimation(true, true);
	else:
		WalkDir = getWalkDir();
		if (WalkDir == Vector2.ZERO):
			COW_STATE = COW_STATES.idle;
			setAnimation(true, true);
			return;
		setAnimation(false, (false if (WalkDir.x < 0) else true));
	timer.start(randi_range(1,3));	

func _on_timer_timeout():
	setNewState();


func _on_player_tool_action(target):
	print(target, target == self);
	if target == self:
		self.queue_free();
