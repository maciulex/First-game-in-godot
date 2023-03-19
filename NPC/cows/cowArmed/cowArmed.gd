extends "res://NPC/cows/cow/cow.gd"

@export var timeToChangeTuretState = [2,5];
@onready var turretTimer : Timer = $TimerForTurretRotation;
@onready var turretDetection : RayCast2D = $Turret/turretDetection;
@onready var turretSprite : Sprite2D = $Turret;
var turretState = turretStates.idle;
enum turretStates {idle, rotateRight, rotateLeft}
@export var turretRotationTime : float = 0.1
var deltaTimeForTurretRotation : float = 0;
var turretCooldown = 0;

var rotationDegreesPerCycle : float = 5.625;#360/64

func rotateCannon(dir : turretStates):
	if turretState == turretStates.rotateLeft:
		#sprite
		if (turretSprite.frame == 0): turretSprite.frame = 63;
		else:turretSprite.frame -= 1;
		#rayCast2d
		turretDetection.rotation_degrees -= rotationDegreesPerCycle;
	elif turretState == turretStates.rotateRight:
		if (turretSprite.frame == 63): turretSprite.frame = 0;		
		else: turretSprite.frame += 1;
		turretDetection.rotation_degrees += rotationDegreesPerCycle;
	deltaTimeForTurretRotation = 0;


func _physics_process(delta):
	if (COW_STATE == COW_STATES.walk):
		move_and_collide(WalkDir)
	if (deltaTimeForTurretRotation > turretRotationTime):
		rotateCannon(turretState);
	else:
		deltaTimeForTurretRotation += delta;

func _on_timer_for_turret_rotation_timeout():
	turretTimer.start(randi_range(timeToChangeTuretState[0], timeToChangeTuretState[1]));
	turretState = randi_range(0,2);
