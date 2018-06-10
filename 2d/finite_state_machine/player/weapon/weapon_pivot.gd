extends Position2D

var z_index_start = 0

func _ready():
	$"..".connect("direction_changed", self, '_on_Parent_direction_changed')
	z_index_start = z_index


func _on_Parent_direction_changed(direction):
	rotation = direction.angle()
	match direction:
		Vector2(0, -1):
			z_index = z_index_start - 1
		_:
			z_index = z_index_start
