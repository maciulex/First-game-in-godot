extends "res://NPC/cows/cow/cow.gd"

var timeToChangeTuretState = [2,5];
@onready var turretTimer : Timer = $TimerForTurretRotation;
@onready var turretDetection : RayCast2D = $Turret/turretDetection;
@onready var turretSprite : Sprite2D = $Turret;
enum turretStates {idle, rotateRight, rotateLeft}
var turretState : turretStates = turretStates.idle;
@export var turretRotationTime : float = 0.1
var turretCooldown = 0;
var bullet = preload("res://utils/bullet.tscn");

var rotationDegreesPerCycle : float = 5.625;#360/64

func rotateCannon(dir : turretStates):
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
	if (turretDetection.get_collider() != null && turretDetection.get_collider().is_in_group("CowEnemy")):
		var instanceOfBullet = bullet.instantiate();
		var offsetValue = 25;
		var pos = Vector2(position.x - offsetValue, position.y + offsetValue);
		print("da",turretDetection.rotation)
		print(turretDetection.rotation_degrees);
		var deg = (turretDetection.rotation)-1.57079633;
		instanceOfBullet.init(pos, Vector2.from_angle(deg));
		get_tree().get_root().add_child(instanceOfBullet);
		pass;

func _physics_process(delta):
	if (COW_STATE == COW_STATES.walk):
		move_and_collide(WalkDir)


func _on_timer_for_turret_rotation_timeout():
	turretTimer.start(randi_range(timeToChangeTuretState[0], timeToChangeTuretState[1]));
	turretState = randi_range(0,2);


func _on_timer_to_cycle_of_rotation_timeout():
	rotateCannon(turretState);
