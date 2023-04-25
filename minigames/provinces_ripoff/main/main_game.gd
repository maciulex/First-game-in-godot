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

func getRandomPoints():
	#points = [Vector2(1595, 999), Vector2(1498, 142), Vector2(178, 77), Vector2(559, 904),Vector2(1879, 882), Vector2(1619, 330), Vector2(1448, 596)];
	#for i in range(AMOUNT_OF_POINTS):
	#	drawCross(points[i])
	#return;
	for i in range(AMOUNT_OF_POINTS):
		var point = generateRandomPoint();
		points.append(point);
		drawCross(points[i])
		continue

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
	var cosd = cos(angle);
	var sind = sin(angle);
	
	var x1 = point.x - point2.x;
	var y1 = point.y - point2.y;

	return Vector2(
		(cosd * x1) - (sind * y1) + point2.x,
		(sind * x1) + (cosd * y1) + point2.y
	)
	
func drawLine(point1, point2, color : Color = Color(255,255,255)):
	var line = $Line2D.duplicate();
	line.points = PackedVector2Array([point1, point2])
	line.default_color = color;
	$Lines.add_child(line);

func isOnEdgeOfCircle(point : Vector2, S : Vector2, r) -> CirclePosition:
	#(point.x*point.x) + (point.y*point.y) - 2*(S.x*point.x)-2*(S.y*point.y)
	var res = pow(point.x - S.x,2) + pow(point.y - S.y,2);
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
	var a1 = t1.find(t2[0]);
	var a2 = t1.find(t2[1]);
	var a3 = t1.find(t2[2]);
	if (a1 != -1 && a2 != -1 && a3 != -1):
		return true;
	return false;

func fundTriantgleIndex(triangle):
	var counter = 0;
	for tri in triangles:
		if triangleEquality(tri, triangle):
			return counter;
		counter += 1;
		pass;

func isSharedEdge(arr, triangle, edge, second = false) -> bool:
	for tri in arr:
		if (triangleEquality(triangle, tri)):
			continue
		var a1 = tri.find(edge[0]);
		var a2 = tri.find(edge[1]);
		if (a1 != -1 && a2 != -1):
			return true;
	if (!second):
		isSharedEdge(arr, triangle, [edge[1], edge[0]], true)
	return false;
		

func triangulation():
	makeSuperTriangle();
	for point in points:
		var badTriangles : Array = [];
		for triangle in triangles:
			var S = getTriangleCircumcenterCenter(triangle);
			var R = getTriangleCircumcenterRadius(triangle);
			drawCross(S, Color(255,0,255))
			drawCircle(S,R)
			print("outside: ", isOnEdgeOfCircle(point, S, R), ", " ,point, ", ", S, ", ", R);
			var positionOnCircle = isOnEdgeOfCircle(point, S, R);
			if (positionOnCircle == CirclePosition.INSIDE || positionOnCircle == CirclePosition.ON_EDGE):
				print("inside")
				badTriangles.append(triangle);
			pass;
				
		var polygon = [];
		print("here ", badTriangles)
		for triangle in badTriangles:
			if (!isSharedEdge(badTriangles, triangle, [triangle[0], triangle[1]])):
				polygon.append([triangle[0], triangle[1]]);
			if (!isSharedEdge(badTriangles, triangle, [triangle[0], triangle[2]])):
				polygon.append([triangle[0], triangle[2]]);
			if (!isSharedEdge(badTriangles, triangle, [triangle[1], triangle[2]])):
				polygon.append([triangle[1], triangle[2]]);
				
		print("poly",polygon)		
		for triangle in badTriangles:
			var index = fundTriantgleIndex(triangle)
			print(index);
			triangles.remove_at(index);
		
		for edge in polygon:
			var newTriangle = [
				point,
				Vector2(edge[0]),
				Vector2(edge[1])
			]
			triangles.append(newTriangle);
			drawLine(newTriangle[0], newTriangle[1], Color("CORAL"));
			drawLine(newTriangle[1], newTriangle[2], Color("CORAL"));
			drawLine(newTriangle[0], newTriangle[2], Color("CORAL"));
		#await get_tree().create_timer(2).timeout
	var oryginalSuper =  getBigTriangle();
	removeWithSuper(oryginalSuper);
	
	for tri in triangles:
		drawLine(tri[0], tri[1]);
		drawLine(tri[1], tri[2]);
		drawLine(tri[2], tri[0]);
		pass;

func removeWithSuper(oryginalSuper):
	var Clean = false;
	while !Clean:
		Clean = true;
		for tri in triangles:
			if (tri[0] == oryginalSuper[0] || tri[0] == oryginalSuper[1] || tri[0] == oryginalSuper[2] ||
				tri[1] == oryginalSuper[0] || tri[1] == oryginalSuper[1] || tri[1] == oryginalSuper[2] ||
				tri[2] == oryginalSuper[0] || tri[2] == oryginalSuper[1] || tri[2] == oryginalSuper[2] 
				):
				triangles.remove_at(fundTriantgleIndex(tri));
				Clean = false;
			
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
		
		


		
		
# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalData = get_node("/root/GlobalData");
	BOARD_SIZE = Vector2(1920,1080);

	getRandomPoints()
	VernoiDiagram()
	print(points);
	
	return;
	var point1 = Vector2(500,412);
	var point2 = Vector2(123,412);
	var point3 = Vector2(500,1000);
	
	drawLine(point1, point2);
	drawLine(point1, point3);
	drawLine(point3, point2);
	
	
	var triangle = [point1,point2,point3];
	
	var S = getTriangleCircumcenterCenter(triangle);
	var R = getTriangleCircumcenterRadius(triangle);
	drawCross(S, Color(255,0,255))
	drawCircle(S,R)
	#drawLine(points[0], points[1]);



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var useAction = Input.get_action_strength("space");
	var action = Input.get_action_strength("e");

	quit();
	pass
