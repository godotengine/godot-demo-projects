class_name GridEdgeVertices extends EdgeVertices

func _init(corner_1: Vector3 = Vector3(), corner_2: Vector3 = Vector3()):
	self.v1 = corner_1
	self.v2 = corner_1.lerp(corner_2, 0.25)
	self.v3 = corner_1.lerp(corner_2, 0.5)
	self.v4 = corner_1.lerp(corner_2, 0.75)
	self.v5 = corner_2

func terrace_lerp(b: EdgeVertices, step: int) -> EdgeVertices:
	var result: GridEdgeVertices = GridEdgeVertices.new()
	result.v1 = GridMetrics.terrace_lerp(v1, b.v1, step)
	result.v2 = GridMetrics.terrace_lerp(v2, b.v2, step)
	result.v3 = GridMetrics.terrace_lerp(v3, b.v3, step)
	result.v4 = GridMetrics.terrace_lerp(v4, b.v4, step)
	result.v5 = GridMetrics.terrace_lerp(v5, b.v5, step)
	return result
