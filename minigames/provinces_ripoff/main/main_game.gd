extends Node2D

var GlobalData;

var AMOUNT_OF_POINTS : int = 7;
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

func drawCircle(s, r):
	var circle_inst = $Circle.duplicate();
	circle_inst.update(s,r);
	$Circles.add_child(circle_inst);

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

func isOnEdgeOfCircle(point : Vector2, S : Vector2, r) -> CirclePosition:
	#(point.x*point.x) + (point.y*point.y) - 2*(S.x*point.x)-2*(S.y*point.y)
	var res = pow(point.x - S.x,2) + pow(point.y-S.y,2);
	print(res, " | ", r, " | ", res - r)
	r = r*r
	#print(r, " | ",res)
	
	if res == r:
		drawCross(point, Color(144,50,144));
		#print("edge fund")
		return CirclePosition.ON_EDGE;
	if (res < r):
		return CirclePosition.INSIDE	
	return CirclePosition.OUTSIDE

func getBigTriangle():
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
	return[a,b,c];
	
func makeSuperTriangle():

	triangles.append(getBigTriangle());
	#var monitor_center = Vector2(1920/2, 1080/2);
	#drawLine(monitor_center, a);
	#drawLine(monitor_center, b);
	#drawLine(monitor_center, c);



func isVectorEqual(v1,v2):
	if (v1.x == v2.x && v2.y == v1.y):
		return true;
	return false;

func get_distanced(point1, point2):
	#print(point1, point2);
	return sqrt(
		(( point2.x - point1.x) * (point2.x - point1.x)) + 
		(( point2.y - point1.y) * (point2.y - point1.y))
	)

func getTriangleCircumcenterRadius(triangle):
	var a = get_distanced(triangle[0], triangle[1])
	var b = get_distanced(triangle[1], triangle[2])
	var c = get_distanced(triangle[2], triangle[0])
	#print(a ," || ", b," || ",c)
	var r = (a*b*c) / sqrt((a+b+c)*(b+c-a)*(c+a-b)*(a+b-c));
	#print("..",r,"..")
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
	return Vector2(x,y);

func triangleEquality(t1, t2):
	if (t1[0] == t2[0] && t1[1] == t2[1] && t1[2] == t2[2]):
		return true;
	return false;

func fundTriantgleIndex(triangle):
	var counter = 0;
	for tri in triangles:
		if triangleEquality(tri, triangle):
			return counter;
		counter += 1;
		pass;


func triangulation():
	makeSuperTriangle();
	for i in range(AMOUNT_OF_POINTS):
		var badTriangles : Array = [];
		for triangle in triangles:
			var S = getTriangleCircumcenterCenter(triangle);
			drawCross(S, Color(255,0,255))
			var R = getTriangleCircumcenterRadius(triangle);
			drawCircle(S,R)
			drawLine(triangle[0], triangle[1], Color(0,255,0));
			drawLine(triangle[1], triangle[2], Color(0,255,0));
			drawLine(triangle[0], triangle[2], Color(0,255,0));
			
			print("outside: ", isOnEdgeOfCircle(points[i], S, R), ", " ,points[i], ", ", S, ", ", R);
			if (isOnEdgeOfCircle(points[i], S, R) == CirclePosition.INSIDE):
				print("inside")
				badTriangles.append(triangle);
				break;
		var polygon = [];
		print("here ", badTriangles)
		for triangle in badTriangles:
			var edges = [false, false, false]; 
			for t2 in badTriangles:
				if (triangleEquality(t2, triangle)):
					continue;
				if (t2[0] == triangle[0] && t2[1] == triangle[1]):
					edges[0] = true;
				if (t2[1] == triangle[1] && t2[2] == triangle[2]):
					edges[1] = true;
				if (t2[2] == triangle[2] && t2[0] == triangle[0]):
					edges[2] = true;
			if (!edges[0]):
				polygon.append([triangle[0], triangle[1]]);
			if (!edges[1]):
				polygon.append([triangle[1], triangle[2]]);		
			if (!edges[2]):
				polygon.append([triangle[2], triangle[0]]);
		print("poly",polygon)		
		for triangle in badTriangles:
			var index = fundTriantgleIndex(triangle)
			triangles.remove_at(index);
		
		for edge in polygon:
			var newTriangle = [
				points[i],
				Vector2(edge[1]),
				Vector2(edge[0])
			]
			triangles.append(newTriangle);
			
	var oryginalSuper =  getBigTriangle();
	removeWithSuper(oryginalSuper);
	
	for tri in triangles:
		drawLine(tri[0], tri[1]);
		drawLine(tri[1], tri[2]);
		drawLine(tri[2], tri[0]);

func removeWithSuper(oryginalSuper):
	for tri in triangles:
		if (tri[0] == oryginalSuper[0] || tri[0] == oryginalSuper[1] || tri[0] == oryginalSuper[2] ||
			tri[1] == oryginalSuper[0] || tri[1] == oryginalSuper[1] || tri[1] == oryginalSuper[2] ||
			tri[2] == oryginalSuper[0] || tri[2] == oryginalSuper[1] || tri[2] == oryginalSuper[2] 
			):
			var index = fundTriantgleIndex(tri)
			triangles.remove_at(index);
			return removeWithSuper(oryginalSuper);
			
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
