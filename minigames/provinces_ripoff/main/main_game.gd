extends Node2D

var GlobalData;

var AMOUNT_OF_POINTS : int = 5;
var BOARD_SIZE : Vector2;
var MARGIN_FOR_POINTS = 20;
var POINTS_MINIMUM_DISTANCE = 90;

var points  : Array;
var lines   : Array;
var centers : Array;
var triangles : Array;
enum CirclePosition {INSIDE, ON_EDGE, OUTSIDE}
var pointNode = preload("res://minigames/provinces_ripoff/utils/point/point.tscn");

class Polygon:
	var points : Array = [];
	var lines  : Array = [];
	var centerPoint : int;


func drawCross(point : Vector2, color : Color = Color(255,255,255)):
	var insta_pointNode = pointNode.instantiate();
	insta_pointNode.position = point;
	insta_pointNode.get_node("Line2D").default_color = color;
	insta_pointNode.get_node("Line2D2").default_color = color;
	$Points.add_child(insta_pointNode);

func quit():
	if (Input.get_action_strength("q")):
		get_tree().change_scene_to_file(GlobalData.CombackSceneFromArcade);


func checkForMargines(point) -> bool:
	for p in points:			
		if p.distance_to(point) < POINTS_MINIMUM_DISTANCE:
			return false;
	return true;

func generateRandomPoint(margin = true) -> Vector2:
	var point;
	while (true):
		point = Vector2(randi_range(MARGIN_FOR_POINTS, BOARD_SIZE.x-MARGIN_FOR_POINTS), 
							randi_range(MARGIN_FOR_POINTS, BOARD_SIZE.y-MARGIN_FOR_POINTS)
						);
		if (checkForMargines(point) || !margin):
			break;
	return point

func getDst(point1, point2):
	return (
		(point2.x-point1.x)*(point2.x-point1.x) +
		(point2.y-point1.y)*(point2.y-point1.y)
	)

func getClosestPointIndex(Point, exceptions) -> Array:
	var lowestDist	    = -1;
	var lowestDistIndex = -1;
	for i in range(AMOUNT_OF_POINTS):
		if (i == Point || exceptions.find(i) != -1):
			continue;
			
		var distance = getDst(points[Point],points[i])
		
		if (lowestDist == -1):
			lowestDist = distance;
			lowestDistIndex = i;
			continue;
		if (distance < lowestDist):
			lowestDist = distance;
			lowestDistIndex = i;
	return [lowestDistIndex, lowestDist];

func getPointDeg(point, point2, deg):
	var angle = deg_to_rad(deg);
	var cos = cos(angle);
	var sin = sin(angle);
	
	var x1 = point.x - point2.x;
	var y1 = point.y - point2.y;

	return Vector2(
		(cos * x1) - (sin * y1) + point2.x,
		(sin * x1) + (cos * y1) + point2.y
	)
	
func drawLine(point1, point2, color : Color = Color(255,255,255)):
	var line = $Line2D.duplicate();
	line.points = PackedVector2Array([point1, point2])
	line.default_color = color;
	$Lines.add_child(line);

func isOnEdgeOfCircle(point, S, r) -> CirclePosition:
	#(point.x*point.x) + (point.y*point.y) - 2*(S.x*point.x)-2*(S.y*point.y)
	var res = pow(point.x - S.x,2) + pow(point.y-S.y,2);
	print(res, " | ", r, " | ", res - r)
	
	if res == r:
		drawCross(point, Color(144,50,144));
		print("edge fund")
		return CirclePosition.ON_EDGE;
	if (res < r):
		return CirclePosition.INSIDE	
	return CirclePosition.OUTSIDE

func makeSuperTriangle():
	var H = 2500;
	var A = 4000;
	var margin = 40
	var a = Vector2(
		(1080/2)-A/2-margin,
		0-margin
	)
	var b = Vector2(
		(1080/2)+A/2+margin,
		0-margin
	)
	var c = Vector2(
		A/2,
		2500+margin
	)
	triangles.append([a,b,c]);
	#var monitor_center = Vector2(1920/2, 1080/2);
	#drawLine(monitor_center, a);
	#drawLine(monitor_center, b);
	#drawLine(monitor_center, c);



func isVectorEqual(v1,v2):
	if (v1.x == v2.x && v2.y == v1.y):
		return true;
	return false;

func getTriangleCircumcenterRadius(triangle):
	var a = triangle[0]
	var b = triangle[1]
	var c = triangle[2]
	
	var r = (a*b*c) / (
					(a+b+c)*(b+c-a)*
					(c+a-b)*(a+b-c)
				);
	
	return r;


func lineFromPoints(point1, point2):
	var a = point2.y - point1.y;
	var b = point1.x - point2.x;
	return [
			a,
			b,
			(a*point1.x) + (b*point1.y)
		];
func perpendicularBisectorFromLine(point1, point2, abc):
	var midpoint = [
			(point1.x+point2.x)/2,
			(point1.y+point2.y)/2
		];
	abc[2] = (abc[1]*(-1))*midpoint[0] + abc[0]*midpoint[1];
	var tmp = abc[0];
	abc[0] = abc[1] * (-1);
	abc[1] = tmp;
	return abc;
#stolen and translated from geeks for geeks
func getTriangleCircumcenterCenter(triangle):
	var abc = lineFromPoints(triangle[0], triangle[1]); 
	var efg = lineFromPoints(triangle[1], triangle[2]);
	
	abc = perpendicularBisectorFromLine(triangle[0], triangle[1], abc);
	efg = perpendicularBisectorFromLine(triangle[1], triangle[2], efg);
	
	var deter = abc[0]*efg[1] - efg[0]*abc[1];

	var x = (efg[1]*abc[2] - abc[1]*efg[2])/deter;
	var y = (abc[0]*efg[2] - efg[0]*abc[2])/deter;
	print("crc: ", x, ":",y);
	return [x,y];

func triangulation():
	makeSuperTriangle();
	for i in range(AMOUNT_OF_POINTS):
		var badTriangles : Array;
		for triangle in triangles:
			var S = getTriangleCircumcenterCenter(triangle);
			var R = getTriangleCircumcenterRadius(triangle);
			print("r: ", R)
			pass;


func drawLines(point):
	var donePoints : Array = [];
	for i in range(AMOUNT_OF_POINTS):
		if (i == point): continue;
		var closestPoint = getClosestPointIndex(point, donePoints);
		var closestDist = closestPoint[1];
		closestPoint = closestPoint[0];
		var center = Vector2((points[point].x+points[closestPoint].x)/2, (points[point].y+points[closestPoint].y)/2);
		donePoints.append(i);
		drawCross(center, Color(255,0,0));
		drawLine(points[point], points[closestPoint], Color(0,255,0))
		var noLine = false
		for z in range(AMOUNT_OF_POINTS):
			if (z == point || z == i):
				continue;
			if (isOnEdgeOfCircle(points[z], center, closestDist) == CirclePosition.INSIDE):
				noLine = true;
				break;
		if (noLine):
			continue;
		var rotated = getPointDeg(points[point], center, 90);
		var m = (rotated.y - center.y)/(rotated.x-center.x)
		var c = rotated.y - m * rotated.x
		var edgeone = Vector2(0,c)
		var edgetwo = Vector2(1920, m*1920+c)
		
		drawLine(edgeone, edgetwo);
		lines.append([m,c]);
		break;

func VernoiDiagram():
	triangulation()
	return;
	for i in range(AMOUNT_OF_POINTS):
		drawLines(i);
		
		

func getRandomPoints():
	for i in range(AMOUNT_OF_POINTS):
		var point = generateRandomPoint();
		drawCross(point)
		points.append(point);
		
		
# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalData = get_node("/root/GlobalData");
	BOARD_SIZE = Vector2(1920,1080);
	getRandomPoints()
	VernoiDiagram()
	#drawLine(points[0], points[1]);



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var useAction = Input.get_action_strength("space");
	var action = Input.get_action_strength("e");

	quit();
	pass
