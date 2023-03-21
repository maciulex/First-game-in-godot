extends "res://NPC/cows/cow/cow.gd"

var timeToChangeTuretState = [2,5];

@onready var turretDetection : RayCast2D = $Turret/turretDetection;
@onready var turretSprite : Sprite2D = $Turret;
enum turretStates {idle, rotateRight, rotateLeft}
var turretState : turretStates = turretStates.idle;
@export var turretRotationTime : float = 0.1
var bullet = preload("res://utils/bullet.tscn");
var rotationDegreesPerCycle : float = 5.625;#360/64

@onready var turretAimbotTimer : Timer = $aimbot;
var aimbotAt = null;
var aimbotActiveTime : float = 5;
var aimbotCooldownTime : float = 2;
var aimbotActive : bool = false;
var aimbotCooldown : bool = false;

@onready var turretCoolDownTimer : Timer = $bulletCoolDown;
@onready var turretTimer : Timer = $TimerForTurretRotation;
var turretCoolDown : bool = false;
var turretCoolDownTime : float = 0.2;

func shootBullet():
	var instanceOfBullet = bullet.instantiate();
	var offsetValue = 25;
	var pos = Vector2(position.x - offsetValue, position.y + offsetValue);
	var deg = (turretDetection.rotation)-1.57079633;
	instanceOfBullet.init($cow.get_rid(),pos, Vector2.from_angle(deg));
	get_tree().get_root().add_child(instanceOfBullet);
	turretCoolDown = true;
	turretCoolDownTimer.start(turretCoolDownTime);
	
	
func aimbot():
	if (aimbotAt == null):
		return;
	var angleToTarget = position.angle_to_point(Vector2(aimbotAt.position))
	turretDetection.rotation = angleToTarget+1.57079633;
	var frame = turretDetection.rotation_degrees/5.625;
	if (frame < 0):
		frame = 63 + frame;
	turretSprite.frame = frame;
	pass;

func rotateCannon(dir : turretStates):
	if (aimbotActive):
		return;
	match turretState:
		turretStates.rotateLeft:
			#sprite
			if (turretSprite.frame == 0): turretSprite.frame = 63;
			else:turretSprite.frame -= 1;
			#rayCast2d
			turretDetection.rotation_degrees -= rotationDegreesPerCycle;
		turretStates.rotateRight:
			if (turretSprite.frame == 63): turretSprite.frame = 0;		
			else: turretSprite.frame += 1;
			turretDetection.rotation_degrees += rotationDegreesPerCycle;

func _physics_process(delta):
	if (COW_STATE == COW_STATES.walk):
		move_and_collide(WalkDir)
	if ((aimbotActive && !turretCoolDown) || (!turretCoolDown && turretDetection.get_collider() != null && turretDetection.get_collider().is_in_group("CowEnemy"))):
		if (aimbotActive): aimbot();
		elif (!aimbotCooldown):
			aimbotActive = true;
			aimbotAt = turretDetection.get_collider();
			turretAimbotTimer.start(aimbotActiveTime);
		shootBullet();
		pass;


func _on_timer_for_turret_rotation_timeout():
	turretTimer.start(randi_range(timeToChangeTuretState[0], timeToChangeTuretState[1]));
	turretState = randi_range(0,2);


func _on_timer_to_cycle_of_rotation_timeout():
	rotateCannon(turretState);


func _on_bullet_cool_down_timeout():
	turretCoolDown = false;
	pass # Replace with function body.


func _on_aimbot_timeout():
	if aimbotActive:
		aimbotActive = false;
		aimbotCooldown = true;
		turretAimbotTimer.start(aimbotCooldownTime);
	else:
		aimbotCooldown = false;
	pass # Replace with function body.
