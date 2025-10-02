# Currently broken unless Godot makes this kind of thing possible:
# https://github.com/godotengine/godot/issues/21461
# https://github.com/godotengine/godot-proposals/issues/279

# Basis25D structure for performing 2.5D transform math.
# NOTE: All code assumes that Y is UP in 3D, and DOWN in 2D.
# Meaning, a top-down view has a Y axis component of (0, 0), with a Z axis component of (0, 1).
# For a front side view, Y is (0, -1) and Z is (0, 0).
# Remember that Godot's 2D mode has the Y axis pointing DOWN on the screen.

class_name Basis25D

var x: Vector2 = Vector2()
var y: Vector2 = Vector2()
var z: Vector2 = Vector2()

static func top_down():
	return init(1, 0, 0, 0, 0, 1)

static func front_side():
	return init(1, 0, 0, -1, 0, 0)

static func forty_five():
	return init(1, 0, 0, -0.70710678118, 0, 0.70710678118)

static func isometric():
	return init(0.86602540378, 0.5, 0, -1, -0.86602540378, 0.5)

static func oblique_y():
	return init(1, 0, -1, -1, 0, 1)

static func oblique_z():
	return init(1, 0, 0, -1, -1, 1)

# Creates a Dimetric Basis25D from the angle between the Y axis and the others.
# Dimetric(2.09439510239) is the same as Isometric.
# Try to keep this number away from a multiple of Tau/4 (or Pi/2) radians.
static func dimetric(angle):
	var sine = sin(angle)
	var cosine = cos(angle)
	return init(sine, -cosine, 0, -1, -sine, -cosine)

static func init(xx, xy, yx, yy, zx, zy):
	var xv = Vector2(xx, xy)
	var yv = Vector2(yx, yy)
	var zv = Vector2(zx, zy)
	return Basis25D.new(xv, yv, zv)

func _init(xAxis: Vector2, yAxis: Vector2, zAxis: Vector2):
	x = xAxis
	y = yAxis
	z = zAxis
