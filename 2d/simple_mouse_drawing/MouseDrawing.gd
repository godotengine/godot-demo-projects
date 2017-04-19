extends Node2D

const line_width = 10

var pos_track = 0
var pos0 = Vector2()
var pos1 = Vector2()

func _input(event):
	if (event.type == InputEvent.MOUSE_BUTTON):
		if (event.pressed):
		
			var mpos = get_viewport().get_mouse_pos()
			if (pos_track == 0):
				pos0 = mpos
			else:
				# on second click, create the "line"
				pos1 = mpos
				gen_poly_line()
			# XOR flips 1 to 0 and 0 to 1, for switching states
			pos_track ^= 1


func gen_poly_line():
	# create a new Polygon2D node.
	var node = Polygon2D.new()
	
	# do maths to produce a line shape (rectangle) 
	node.set_polygon(create_poly_coords_for_line(pos0, pos1, line_width))
	
	# attach the node to this object, and therfore include it in the scene
	add_child(node)
	
	# basic way to keep track of the added lines
	node.add_to_group("DrawLines")


func create_poly_coords_for_line(start, end, width):
	# Creates 2 points each for start and end point of a line;
	# these points make up the corners of the rectangle that is the line representation.
	
	width = width / 2
	
	# Take the difference between start and end, make it a unit vector (normalized),
	# make it perpendicular (tangent), make it half the line width long (* width) , finally
	# offset it by adding it to start or end.
	var s1 = start + ((start - end).normalized().tangent()  * width)
	var s2 = start + ((start - end).normalized().tangent()  * -width)
	var e1 = end + ((end - start).normalized().tangent() * width)
	var e2 = end + ((end - start).normalized().tangent() * -width)
	
	# This array of 2D points will make up the path of the polygon
	return Vector2Array([s1, s2, e1, e2])


func _ready():
	set_process_input(true)
