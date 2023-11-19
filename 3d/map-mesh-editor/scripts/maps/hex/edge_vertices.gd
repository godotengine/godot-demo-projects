class_name EdgeVertices

var v1: Vector3
var v2: Vector3
var v3: Vector3
var v4: Vector3
var v5: Vector3

func _init(corner_1: Vector3 = Vector3(), corner_2: Vector3 = Vector3()):
	self.v1 = corner_1
	self.v2 = corner_1.lerp(corner_2, 0.25)
	self.v3 = corner_1.lerp(corner_2, 0.5)
	self.v4 = corner_1.lerp(corner_2, 0.75)
	self.v5 = corner_2

func terrace_lerp(b: EdgeVertices, step: int) -> EdgeVertices:
	var result: EdgeVertices = EdgeVertices.new()
	result.v1 = HexMetrics.terrace_lerp(v1, b.v1, step)
	result.v2 = HexMetrics.terrace_lerp(v2, b.v2, step)
	result.v3 = HexMetrics.terrace_lerp(v3, b.v3, step)
	result.v4 = HexMetrics.terrace_lerp(v4, b.v4, step)
	result.v5 = HexMetrics.terrace_lerp(v5, b.v5, step)
	return result
