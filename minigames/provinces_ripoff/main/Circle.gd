extends Node2D

var center : Vector2 = Vector2(0,0);
var radius : int = 0; 

func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 2048
	var points_arc = [];

	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.append(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color)

func _draw():
	var angle_from = 0
	var angle_to = 360
	var color = Color(1.0, 0.0, 0.0)
	draw_circle_arc(center, radius, angle_from, angle_to, color)

func update(centeri, radiusi):
	center = centeri;
	radius = radiusi;
	_draw();
