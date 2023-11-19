class_name MapCoordinates

var x: int
var y: int
var z: int

func _to_string() -> String:
	return "(" + str(self.x) + ", " + str(self.y) + ", " + str(self.z) + ")"
	
func _to_string_on_separate_lines() -> String:
	return str(self.x) + "\n" + str(self.y) + "\n" + str(self.z)

func to_vec3() -> Vector3:
	return Vector3(self.x, self.y, self.z)
